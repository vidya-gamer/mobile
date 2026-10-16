import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/common/time_increment.dart';
import 'package:lichess_mobile/src/model/game/over_the_board_game.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

part 'over_the_board_game_storage.freezed.dart';
part 'over_the_board_game_storage.g.dart';

final _logger = Logger('OverTheBoardGameStorage');

@Freezed(fromJson: true, toJson: true)
sealed class const SavedOtbGame._() with _$SavedOtbGame {
  factory({
    required OverTheBoardGame game,
    required TimeIncrement timeIncrement,
    Duration? whiteTimeLeft,
    Duration? blackTimeLeft,
  }) = _SavedOtbGame;

  factory fromJson(Map<String, dynamic> json) => _$SavedOtbGameFromJson(json);
}

/// A provider for [OverTheBoardGameStorage].
final overTheBoardGameStorageProvider = Provider<OverTheBoardGameStorage>((Ref ref) {
  return OverTheBoardGameStorage(ref);
}, name: 'OverTheBoardGameStorageProvider');

final savedOtbGamesProvider = FutureProvider.autoDispose<List<SavedOtbGame>>((Ref ref) {
  final storage = ref.watch(overTheBoardGameStorageProvider);
  return storage.fetchGames();
}, name: 'SavedOtbGamesProvider');

const kOtbGameFileName = 'otb_games.json';
const kMaxSavedGames = 10;

class const OverTheBoardGameStorage(final Ref ref) {
  Future<File> _getFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$kOtbGameFileName');
  }

  /// Fetches saved OTB games from storage.
  /// Returns a list of [SavedOtbGame] ordered from most recent to oldest.
  Future<List<SavedOtbGame>> fetchGames() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents);

      if (json is List) {
        return json.whereType<Map<String, dynamic>>().map(SavedOtbGame.fromJson).toList();
      }

      // Migration fallback for existing single-game schema
      if (json is Map<String, dynamic>) {
        return [SavedOtbGame.fromJson(json)];
      }

      throw const FormatException('[OtbGameStorage] cannot fetch games: expected a JSON list');
    } catch (e, st) {
      _logger.warning('[OtbGameStorage] failed to fetch games:', e, st);
      return [];
    }
  }

  /// Persist an OTB game to storage. Prepends the game to the list
  /// and keeps only the 10 most recent games.
  Future<void> save(
    OverTheBoardGame game, {
    required TimeIncrement timeIncrement,
    required Duration? whiteTimeLeft,
    required Duration? blackTimeLeft,
  }) async {
    try {
      final currentGames = await fetchGames();

      final newGame = SavedOtbGame(
        game: game,
        timeIncrement: timeIncrement,
        whiteTimeLeft: whiteTimeLeft,
        blackTimeLeft: blackTimeLeft,
      );

      final updatedGames = [newGame, ...currentGames].take(kMaxSavedGames).toList();

      final file = await _getFile();
      await file.writeAsString(jsonEncode(updatedGames.map((g) => g.toJson()).toList()));
    } catch (e, st) {
      _logger.warning('[OtbGameStorage] failed to save game:', e, st);
    }
  }
}
