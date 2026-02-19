import 'package:flutter/material.dart';

import '../../game/game_types.dart';
import '../../game/level_game.dart';

class TouchDPad extends StatelessWidget {
  const TouchDPad({required this.game, super.key});

  final LevelGame game;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _TouchDirectionButton(
              icon: Icons.keyboard_arrow_up,
              onPressedChanged:
                  (pressed) => game.setTouchDirection(MoveDirection.up, pressed),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _TouchDirectionButton(
              icon: Icons.keyboard_arrow_left,
              onPressedChanged:
                  (pressed) => game.setTouchDirection(MoveDirection.left, pressed),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _TouchDirectionButton(
              icon: Icons.keyboard_arrow_right,
              onPressedChanged:
                  (pressed) => game.setTouchDirection(MoveDirection.right, pressed),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _TouchDirectionButton(
              icon: Icons.keyboard_arrow_down,
              onPressedChanged:
                  (pressed) => game.setTouchDirection(MoveDirection.down, pressed),
            ),
          ),
        ],
      ),
    );
  }
}

class _TouchDirectionButton extends StatelessWidget {
  const _TouchDirectionButton({
    required this.icon,
    required this.onPressedChanged,
  });

  final IconData icon;
  final ValueChanged<bool> onPressedChanged;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onPressedChanged(true),
      onPointerUp: (_) => onPressedChanged(false),
      onPointerCancel: (_) => onPressedChanged(false),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.45)),
        ),
        child: Icon(icon, size: 38, color: Colors.black87),
      ),
    );
  }
}
