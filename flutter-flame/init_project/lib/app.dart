import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:init_project/constants.dart';
import 'package:init_project/game/go_green_game.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoGreenGame game;

  @override
  void initState() {
    // Initial others first
    super.initState();
    // Initial game
    game = GoGreenGame();
  }

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Build a Material App with an empty Scaffold as its home.
  /// This is a minimal implementation of a Flutter app.
  ///
  /*******  e6c403b6-d55b-41cd-b7de-eb2c6d0437d2  *******/
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: FittedBox(
              child: SizedBox(
                width: gameWidth,
                height: gameHeight,
                child: GameWidget(game: game),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
