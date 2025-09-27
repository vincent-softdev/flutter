import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:init_project/constants.dart';
import 'package:init_project/game/go_green_game.dart';
import 'package:init_project/player.dart';

class GoGreenWorld extends World with HasGameRef<GoGreenGame> {
  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    super.onLoad();

    // add a player to the game world
    add(Player(position: Vector2(0, 0), radius: gameWidth / 4));
    // Add another player to the game world
    add(Player(position: Vector2(0, 100), radius: 25.0, color: Colors.green));
  }
}
