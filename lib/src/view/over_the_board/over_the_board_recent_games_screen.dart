import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/perf.dart';
//import 'package:lichess_mobile/src/model/analysis/opening_explorer_mixin.dart';
import 'package:lichess_mobile/src/model/over_the_board/over_the_board_game_storage.dart';
import 'package:lichess_mobile/src/styles/icon_extensions.dart';
import 'package:lichess_mobile/src/utils/l10n.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:material_ui/material_ui.dart';

class const OverTheBoardRecentGamesScreen({super.key}) extends ConsumerWidget {
  static Route<void> buildRoute() {
    return buildScreenRoute(screen: const OverTheBoardRecentGamesScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedGamesAsync = ref.watch(savedOtbGamesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.recentGames)),
      body: savedGamesAsync.when(
        data: (games) {
          if (games.isEmpty) {
            return Center(
              child: Text(
                context.l10n.none,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final savedGame = games[index];

              return ListTile(
                leading: savedGame.game.meta.perf == Perf.correspondence
                    ? const Icon(Icons.all_inclusive)
                    : Icon(savedGame.game.meta.perf.icon),
                title: Text(relativeDate(context.l10n, savedGame.game.meta.createdAt)),
                subtitle: Text('${context.l10n.timeControl}: ${savedGame.timeIncrement.display}'),
                trailing: const Icon(Icons.expand_more), // change to game result
                onTap: () {
                  // load finished game in analysis screen, unfinished in OTB game screen
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Failed to load recent games: $error')),
      ),
    );
  }
}
