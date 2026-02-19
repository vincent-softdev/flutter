import 'package:flutter/material.dart';

import '../../../app/widgets/image_text_button.dart';
import '../../survival/presentation/survival_mode_screen.dart';

class HomeMenuOverlay extends StatelessWidget {
  const HomeMenuOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageTextButton(
            label: 'Survival mode',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SurvivalModeScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          ImageTextButton(
            label: 'Endless mode',
            onPressed: () {
              debugPrint('Endless mode tapped');
            },
          ),
        ],
      ),
    );
  }
}
