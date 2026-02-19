import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../entities/monster_character.dart';

class MonsterHealthFollower extends TextComponent {
  MonsterHealthFollower({required this.monster})
    : super(
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        anchor: Anchor.bottomCenter,
        priority: 120,
      );

  final MonsterCharacter monster;

  @override
  void update(double dt) {
    super.update(dt);
    if (!monster.isMounted) {
      removeFromParent();
      return;
    }

    text = '${monster.currentHealth}/${monster.maxHealth}';
    position = monster.position + Vector2(0, -10);
  }
}
