import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../application/level_session_controller.dart';
import '../domain/hero_attribute.dart';
import '../game/level_game.dart';
import 'widgets/hero_panel.dart';
import 'widgets/touch_dpad.dart';

class LevelPlayScreen extends StatefulWidget {
  const LevelPlayScreen({required this.level, super.key});

  final int level;

  @override
  State<LevelPlayScreen> createState() => _LevelPlayScreenState();
}

class _LevelPlayScreenState extends State<LevelPlayScreen> {
  late final LevelSessionController _controller;
  late final LevelGame _game;
  bool _isEnginePaused = false;

  @override
  void initState() {
    super.initState();

    _controller = LevelSessionController()..addListener(_refreshUi);
    _game = LevelGame(
      level: widget.level,
      onMonsterKilled: _controller.handleMonsterKilled,
      onGameTick: _controller.handleGameTick,
      onToggleHeroPanel: _controller.toggleHeroPanel,
      onHeroDamaged: _controller.handleHeroDamaged,
      isInputLocked: () => _controller.shouldPauseGameplay,
    );
    _controller.attachHeroHudSink(_game);
    _syncPauseState();
  }

  @override
  void dispose() {
    _controller.removeListener(_refreshUi);
    _controller.dispose();
    super.dispose();
  }

  void _refreshUi() {
    if (!mounted) {
      return;
    }
    _syncPauseState();
    setState(() {});
  }

  void _syncPauseState() {
    final shouldPause = _controller.shouldPauseGameplay;
    if (shouldPause == _isEnginePaused) {
      return;
    }

    if (shouldPause) {
      _game.pauseEngine();
    } else {
      _game.resumeEngine();
    }
    _isEnginePaused = shouldPause;
  }

  @override
  Widget build(BuildContext context) {
    final hero = _controller.heroState;
    final controlsLocked = _controller.shouldPauseGameplay;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Focus(autofocus: true, child: GameWidget(game: _game)),
          Positioned(
            top: 42,
            left: 16,
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _controller.toggleHeroPanel,
                    child: const Text('Hero (P)'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 24,
            child: SafeArea(
              child: IgnorePointer(
                ignoring: controlsLocked,
                child: TouchDPad(game: _game),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: FilledButton(
                onPressed: controlsLocked ? null : _game.triggerAttackFromUi,
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  minimumSize: const Size(84, 84),
                ),
                child: const Text('ATK'),
              ),
            ),
          ),
          if (_controller.showHeroPanel)
            Positioned.fill(
              child: HeroPanel(
                unspentPoints: hero.unspentPoints,
                attackSpeed: hero.attackSpeed,
                attackDamage: hero.attackDamage,
                strength: hero.strength,
                heal: hero.heal,
                onClose: _controller.toggleHeroPanel,
                onUpgradeAttackSpeed:
                    () => _controller.spendPoint(HeroAttribute.attackSpeed),
                onUpgradeAttackDamage:
                    () => _controller.spendPoint(HeroAttribute.attackDamage),
                onUpgradeStrength:
                    () => _controller.spendPoint(HeroAttribute.strength),
                onUpgradeHeal: () => _controller.spendPoint(HeroAttribute.heal),
              ),
            ),
          Positioned(
            top: 84,
            left: 84,
            child: IgnorePointer(
              child: Text(
                'Stage ${widget.level}',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (_controller.isHeroDead)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.55),
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'You are dead',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          child: const Text('Finish'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
