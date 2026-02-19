import 'package:flame/components.dart';

import '../components/monster_health_follower.dart';
import '../game_types.dart';
import '../level_game.dart';

class MonsterCharacter extends SpriteAnimationGroupComponent<MonsterState>
    with HasGameReference<LevelGame> {
  MonsterCharacter({
    required this.spriteFolder,
    required this.maxHealth,
    this.sizeScale = 1,
  })
    : _health = maxHealth,
      super(
        anchor: Anchor.center,
        size: Vector2.all(128 * sizeScale),
        scale: Vector2.all(1.5 * sizeScale),
      );

  final String spriteFolder;
  final int maxHealth;
  final double sizeScale;
  int _health;
  bool _isDead = false;
  double _attackCooldown = 0;
  double _deadTimeRemaining = 0;
  late final MonsterHealthFollower _healthFollower;

  bool get isDead => _isDead;
  int get currentHealth => _health.clamp(0, maxHealth);

  static const double moveSpeed = 100;
  static const double attackRange = 86;
  static const double attackInterval = 1;

  @override
  Future<void> onLoad() async {
    final walkImage = await game.images.load('$spriteFolder/Walk.png');
    final attackImage = await game.images.load('$spriteFolder/Attack_1.png');
    final deadImage = await game.images.load('$spriteFolder/Dead.png');

    animations = {
      MonsterState.walk: SpriteAnimation.fromFrameData(
        walkImage,
        SpriteAnimationData.sequenced(
          amount: 13,
          stepTime: 0.08,
          textureSize: Vector2.all(128),
        ),
      ),
      MonsterState.attack: SpriteAnimation.fromFrameData(
        attackImage,
        SpriteAnimationData.sequenced(
          amount: 16,
          stepTime: 0.07,
          textureSize: Vector2.all(128),
        ),
      ),
      MonsterState.dead: SpriteAnimation.fromFrameData(
        deadImage,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.12,
          textureSize: Vector2.all(128),
          loop: false,
        ),
      ),
    };

    current = MonsterState.walk;
    _healthFollower = MonsterHealthFollower(monster: this);
    game.add(_healthFollower);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isDead) {
      _deadTimeRemaining -= dt;
      if (_deadTimeRemaining <= 0) {
        removeFromParent();
      }
      return;
    }

    final hero = game.hero;
    if (hero == null || !hero.isMounted) {
      return;
    }

    if (_attackCooldown > 0) {
      _attackCooldown -= dt;
    }

    final toHero = hero.position - position;
    final distance = toHero.length;

    if (distance <= attackRange) {
      current = MonsterState.attack;
      if (_attackCooldown <= 0) {
        _attackCooldown = attackInterval;
        game.applyDamageToHero(game.currentMonsterDamage);
        animationTickers?[MonsterState.attack]?.reset();
      }
      return;
    }

    if (distance > 0) {
      final movement = toHero.normalized() * moveSpeed * dt;
      position += movement;
      current = MonsterState.walk;

      if (movement.x > 0) {
        scale.x = 1.5 * sizeScale;
      } else if (movement.x < 0) {
        scale.x = -1.5 * sizeScale;
      }
    }
  }

  void takeDamage(int amount) {
    if (_isDead) {
      return;
    }

    _health -= amount;
    if (_health <= 0) {
      _isDead = true;
      game.notifyMonsterKilled(maxHealth);
      current = MonsterState.dead;
      animationTickers?[MonsterState.dead]?.reset();
      _deadTimeRemaining = 0.45;
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    _healthFollower.removeFromParent();
    game.unregisterMonster(this);
  }
}
