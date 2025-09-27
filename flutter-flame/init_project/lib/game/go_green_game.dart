import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:init_project/constants.dart';
import 'package:init_project/game/go_green_world.dart';

class GoGreenGame extends FlameGame {
  // We setup the camera with a fixed resolution which according to the game ---
  // width and height constants. This will ensure that the game world has a ---
  // consistent size across different screen sizes and aspect ratios.
  GoGreenGame({super.children})
    : super(
        world: GoGreenWorld(),
        camera: CameraComponent.withFixedResolution(
          width: gameWidth,
          height: gameHeight,
        ),
      );

  // draw the background
  @override
  Color backgroundColor() => const Color.fromARGB(255, 10, 10, 10);
}
