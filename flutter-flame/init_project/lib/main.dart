import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:init_project/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Flame.device.fullScreen();
  // Set the game stick with Portrait mode
  Flame.device.setPortrait();

  runApp(App());
}
