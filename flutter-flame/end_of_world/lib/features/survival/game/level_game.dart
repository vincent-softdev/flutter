import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../application/level_session_controller.dart';
import '../domain/hero_progression_state.dart';
import 'components/hero_status_follower.dart';
import 'entities/hero_character.dart';
import 'entities/monster_character.dart';
import 'game_types.dart';

class LevelGame extends FlameGame with KeyboardEvents implements HeroHudSink {
  LevelGame({
    required this.level,
    this.onMonsterKilled,
    this.onGameTick,
    this.onToggleHeroPanel,
    this.onHeroDamaged,
    this.isInputLocked,
  });

  final int level;
  final ValueChanged<int>? onMonsterKilled;
  final ValueChanged<double>? onGameTick;
  final VoidCallback? onToggleHeroPanel;
  final ValueChanged<double>? onHeroDamaged;
  final bool Function()? isInputLocked;

  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};
  final Set<MoveDirection> _touchPressed = <MoveDirection>{};
  final Set<MonsterCharacter> _monsters = <MonsterCharacter>{};
  final Random _random = Random();

  double _spawnTimer = 0;
  double _bossSpawnTimer = 0;
  double _miniWaveSpawnTimer = 0;
  double _elapsedSurvivalTime = 0;
  int _spawnedMonsterCount = 0;
  int _heroAttackDamage = 1;

  HeroCharacter? hero;
  HeroStatusFollower? _heroStatusFollower;

  static const double monsterSpawnInterval = 4;
  static const double bossSpawnInterval = 60;
  static const double miniWaveSpawnInterval = 30;
  static const int miniWaveMonsterCount = 10;

  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    hero = HeroCharacter();
    add(hero!);

    _heroStatusFollower = HeroStatusFollower();
    add(_heroStatusFollower!);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final heroRef = hero;
    if (heroRef != null &&
        heroRef.isMounted &&
        heroRef.position == Vector2.zero()) {
      heroRef.position = Vector2(size.x / 2, size.y / 2);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    onGameTick?.call(dt);
    _elapsedSurvivalTime += dt;
    _spawnTimer += dt;
    _bossSpawnTimer += dt;
    _miniWaveSpawnTimer += dt;

    while (_spawnTimer >= monsterSpawnInterval) {
      _spawnTimer -= monsterSpawnInterval;
      _spawnMonster();
    }
    while (_miniWaveSpawnTimer >= miniWaveSpawnInterval) {
      _miniWaveSpawnTimer -= miniWaveSpawnInterval;
      _spawnMiniWave();
    }
    while (_bossSpawnTimer >= bossSpawnInterval) {
      _bossSpawnTimer -= bossSpawnInterval;
      _spawnBoss();
    }

    final direction = Vector2.zero();
    if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        _keysPressed.contains(LogicalKeyboardKey.keyA)) {
      direction.x -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        _keysPressed.contains(LogicalKeyboardKey.keyD)) {
      direction.x += 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        _keysPressed.contains(LogicalKeyboardKey.keyW)) {
      direction.y -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        _keysPressed.contains(LogicalKeyboardKey.keyS)) {
      direction.y += 1;
    }
    if (_touchPressed.contains(MoveDirection.left)) {
      direction.x -= 1;
    }
    if (_touchPressed.contains(MoveDirection.right)) {
      direction.x += 1;
    }
    if (_touchPressed.contains(MoveDirection.up)) {
      direction.y -= 1;
    }
    if (_touchPressed.contains(MoveDirection.down)) {
      direction.y += 1;
    }

    hero?.setDirection(direction);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final pressedKey = event.logicalKey;
    final wasPressed = _keysPressed.contains(pressedKey);
    final inputLocked = isInputLocked?.call() ?? false;

    if (event is KeyDownEvent && !wasPressed) {
      if (pressedKey == LogicalKeyboardKey.keyP) {
        onToggleHeroPanel?.call();
      } else if (!inputLocked && pressedKey == LogicalKeyboardKey.space) {
        triggerAttackFromUi();
      }
    }

    if (inputLocked) {
      _keysPressed.clear();
      hero?.setDirection(Vector2.zero());
      return KeyEventResult.handled;
    }

    _keysPressed
      ..clear()
      ..addAll(keysPressed);
    return KeyEventResult.handled;
  }

  void setTouchDirection(MoveDirection direction, bool isPressed) {
    if (isPressed) {
      _touchPressed.add(direction);
    } else {
      _touchPressed.remove(direction);
    }
  }

  void triggerAttackFromUi() {
    if (isInputLocked?.call() ?? false) {
      return;
    }
    final didStartAttack = hero?.triggerAttack() ?? false;
    if (!didStartAttack) {
      return;
    }
    _dealDamageToNearbyMonsters();
  }

  double get currentMonsterDamage =>
      (1 + (_elapsedSurvivalTime ~/ 60)).toDouble();

  void applyDamageToHero(double damage) {
    onHeroDamaged?.call(damage);
  }

  void unregisterMonster(MonsterCharacter monster) {
    _monsters.remove(monster);
  }

  void notifyMonsterKilled(int monsterMaxHealth) {
    onMonsterKilled?.call(monsterMaxHealth);
  }

  @override
  void syncHeroHud(HeroProgressionState state) {
    hero?.setAttackSpeedLevel(state.attackSpeed);
    _heroAttackDamage = state.attackDamage;
    _heroStatusFollower?.updateStats(state);
  }

  void _dealDamageToNearbyMonsters() {
    final heroRef = hero;
    if (heroRef == null || !heroRef.isMounted) {
      return;
    }

    const attackRange = 140.0;
    for (final monster in _monsters.toList()) {
      if (monster.isDead) {
        continue;
      }
      final distance = monster.position.distanceTo(heroRef.position);
      if (distance <= attackRange) {
        monster.takeDamage(_heroAttackDamage);
      }
    }
  }

  void _spawnMonster() {
    final baseHealth = _currentMonsterBaseHealth();
    _spawnMonsterWithConfig(maxHealth: baseHealth);
  }

  void _spawnMiniWave() {
    final miniWaveHealth = max(1, _currentMonsterBaseHealth() ~/ 2);
    for (var i = 0; i < miniWaveMonsterCount; i++) {
      _spawnMonsterWithConfig(maxHealth: miniWaveHealth, sizeScale: 0.4);
    }
  }

  void _spawnBoss() {
    final bossHealth = _currentMonsterBaseHealth() * 10;
    _spawnMonsterWithConfig(maxHealth: bossHealth, sizeScale: 1.2);
  }

  int _currentMonsterBaseHealth() {
    return max(1, _spawnedMonsterCount + 1);
  }

  void _spawnMonsterWithConfig({
    required int maxHealth,
    double sizeScale = 1,
  }) {
    if (size == Vector2.zero()) {
      return;
    }

    _spawnedMonsterCount += 1;
    final monsterType = ((_spawnedMonsterCount - 1) % 3) + 1;
    final monster = MonsterCharacter(
      spriteFolder: 'monsters/Gorgon_$monsterType',
      maxHealth: maxHealth,
      sizeScale: sizeScale,
    )..position = _randomEdgeSpawnPosition();

    _monsters.add(monster);
    add(monster);
  }

  Vector2 _randomEdgeSpawnPosition() {
    final edge = _random.nextInt(4);
    return switch (edge) {
      0 => Vector2(_random.nextDouble() * size.x, 0),
      1 => Vector2(_random.nextDouble() * size.x, size.y),
      2 => Vector2(0, _random.nextDouble() * size.y),
      _ => Vector2(size.x, _random.nextDouble() * size.y),
    };
  }
}
