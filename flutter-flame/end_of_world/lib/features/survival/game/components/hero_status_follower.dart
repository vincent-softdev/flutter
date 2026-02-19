import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/hero_progression_state.dart';
import '../level_game.dart';

class HeroStatusFollower extends PositionComponent
    with HasGameReference<LevelGame> {
  HeroStatusFollower()
    : super(priority: 100, size: Vector2(128, 48), anchor: Anchor.bottomCenter);

  final TextPaint _labelPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );

  late final RectangleComponent _panel;
  late final TextComponent _levelLabel;
  late final RectangleComponent _bloodBg;
  late final RectangleComponent _bloodFill;
  late final RectangleComponent _expBg;
  late final RectangleComponent _expFill;
  bool _uiReady = false;
  HeroProgressionState _state = const HeroProgressionState();

  @override
  Future<void> onLoad() async {
    _panel = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.45),
      anchor: Anchor.topLeft,
      position: Vector2.zero(),
    );
    add(_panel);

    _levelLabel = TextComponent(
      text: 'Lv 1',
      textRenderer: _labelPaint,
      anchor: Anchor.topLeft,
      position: Vector2(8, 4),
    );
    add(_levelLabel);

    _bloodBg = RectangleComponent(
      size: Vector2(112, 10),
      paint: Paint()..color = Colors.red.shade200,
      anchor: Anchor.topLeft,
      position: Vector2(8, 20),
    );
    add(_bloodBg);

    _bloodFill = RectangleComponent(
      size: Vector2(112, 10),
      paint: Paint()..color = Colors.redAccent,
      anchor: Anchor.topLeft,
      position: _bloodBg.position.clone(),
    );
    add(_bloodFill);

    _expBg = RectangleComponent(
      size: Vector2(112, 8),
      paint: Paint()..color = Colors.blue.shade200,
      anchor: Anchor.topLeft,
      position: Vector2(8, 34),
    );
    add(_expBg);

    _expFill = RectangleComponent(
      size: Vector2(112, 8),
      paint: Paint()..color = Colors.blueAccent,
      anchor: Anchor.topLeft,
      position: _expBg.position.clone(),
    );
    add(_expFill);

    _uiReady = true;
    _applyStatsToUi();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final hero = game.hero;
    if (hero == null || !hero.isMounted) {
      return;
    }
    position = hero.position + Vector2(0, -10);
  }

  void updateStats(HeroProgressionState state) {
    _state = state;
    _applyStatsToUi();
  }

  void _applyStatsToUi() {
    if (!_uiReady) {
      return;
    }

    _levelLabel.text = 'Lv ${_state.level}';
    final healthRatio =
        _state.maxHealth <= 0
            ? 0.0
            : (_state.currentHealth / _state.maxHealth).clamp(0.0, 1.0);
    final expRatio =
        _state.expToNextLevel <= 0
            ? 0.0
            : (_state.currentExp / _state.expToNextLevel).clamp(0.0, 1.0);
    _bloodFill.size.x = _bloodBg.size.x * healthRatio;
    _expFill.size.x = _expBg.size.x * expRatio;
  }
}
