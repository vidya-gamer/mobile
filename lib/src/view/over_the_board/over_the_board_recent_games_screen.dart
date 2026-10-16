import 'dart:async';
import 'dart:convert';
import 'dart:math';

//import 'package:chessground/chessground.dart';
//import 'package:cupertino_ui/cupertino_ui.dart';
//import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:lichess_mobile/src/model/account/account_preferences.dart';
//import 'package:lichess_mobile/src/model/analysis/analysis_controller.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
//import 'package:lichess_mobile/src/model/common/id.dart';
//import 'package:lichess_mobile/src/model/game/game_board_params.dart';
//import 'package:lichess_mobile/src/model/over_the_board/over_the_board_clock.dart';
//import 'package:lichess_mobile/src/model/over_the_board/over_the_board_game_controller.dart';
import 'package:lichess_mobile/src/model/over_the_board/over_the_board_game_storage.dart';
//import 'package:lichess_mobile/src/model/over_the_board/over_the_board_preferences.dart';
//import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/styles/icon_extensions.dart';
//import 'package:lichess_mobile/src/utils/chessboard.dart';
//import 'package:lichess_mobile/src/utils/focus_detector.dart';
//import 'package:lichess_mobile/src/utils/immersive_mode.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
//import 'package:lichess_mobile/src/utils/string.dart';
//import 'package:lichess_mobile/src/view/analysis/analysis_screen.dart';
//import 'package:lichess_mobile/src/view/game/game_player.dart';
//import 'package:lichess_mobile/src/view/game/game_result_dialog.dart';
//import 'package:lichess_mobile/src/view/over_the_board/configure_over_the_board_game.dart';
import 'package:lichess_mobile/src/view/over_the_board/over_the_board_screen.dart';
//import 'package:lichess_mobile/src/widgets/adaptive_action_sheet.dart';
//import 'package:lichess_mobile/src/widgets/bottom_bar.dart';
//import 'package:lichess_mobile/src/widgets/buttons.dart';
//import 'package:lichess_mobile/src/widgets/clock.dart';
//import 'package:lichess_mobile/src/widgets/game_layout.dart';
//import 'package:lichess_mobile/src/widgets/yes_no_dialog.dart';
import 'package:material_ui/material_ui.dart';

class const OverTheBoardRecentGamesScreen({super.key}) extends ConsumerWidget {
  
  static Route<void> buildRoute() {
    return buildScreenRoute(
      screen: const OverTheBoardRecentGamesScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedGamesAsync = ref.watch(savedOtbGamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.recentGames),
      ),
      body: savedGamesAsync.when(
        data: (games) {
          if (games.isEmpty) {
            return Center(
              child: Text(
                'No recent games saved.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: games.length,
itemBuilder: (context, index) {
  final savedGame = games[index];

  final jsonString = const JsonEncoder.withIndent('  ')
      .convert(savedGame.toJson());

  return ExpansionTile(
    leading: Icon(savedGame.game.meta.perf.icon), //meta.perf.icon
    title: Text('Game #${index + 1}'),
    subtitle: Text('Time Control: ${savedGame.timeIncrement}'),
    trailing: const Icon(Icons.expand_more),
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: SelectableText(
          jsonString,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
},
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Failed to load recent games: $error'),
        ),
      ),
    );
  }
}
