import 'package:flutter/material.dart';

import '../../../app/widgets/image_text_button.dart';
import 'level_play_screen.dart';

class SurvivalModeScreen extends StatelessWidget {
  const SurvivalModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/home_background.png', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 180, left: 80, right: 80),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: List.generate(10, (index) {
                            final level = index + 1;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ImageTextButton(
                                label: 'Level $level',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder:
                                          (_) => LevelPlayScreen(level: level),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
