import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../features/home/presentation/home_game.dart';
import '../features/home/presentation/home_menu_overlay.dart';

class EndOfWorldApp extends StatelessWidget {
  const EndOfWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = EndOfWorldGame();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: game,
          overlayBuilderMap: {
            'Menu': (context, game) => const HomeMenuOverlay(),
          },
          initialActiveOverlays: const ['Menu'],
        ),
      ),
    );
  }
}
