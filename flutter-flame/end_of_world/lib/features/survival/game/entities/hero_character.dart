import 'package:flame/components.dart';

import '../game_types.dart';
import '../level_game.dart';

class HeroCharacter extends SpriteAnimationGroupComponent<HeroState>
    with HasGameReference<LevelGame> {
  HeroCharacter()
    : super(
        anchor: Anchor.center,
        size: Vector2.all(96),
        scale: Vector2.all(2),
      );

  final Vector2 _direction = Vector2.zero();

  static const double speed = 220;
  static const double baseAttackStepTime = 0.08;
  static const int attackFrameCount = 7;
  static const double attackSpeedBonusPerPoint = 0.01;
  static const double minAttackStepTime = 0.025;

  bool _isAttacking = false;
  double _attackTimeRemaining = 0;
  int _attackSpeedLevel = 0;
  late Sprite _attackSpriteSheet;

  void setDirection(Vector2 direction) {
    _direction.setFrom(direction);
  }

  void setAttackSpeedLevel(int level) {
    final nextLevel = level < 0 ? 0 : level;
    if (nextLevel == _attackSpeedLevel) {
      return;
    }

    _attackSpeedLevel = nextLevel;
    if (animations == null) {
      return;
    }

    final updatedAnimations = Map<HeroState, SpriteAnimation>.from(animations!);
    updatedAnimations[HeroState.attack] = _buildAttackAnimation();
    animations = updatedAnimations;
  }

  bool triggerAttack() {
    if (_isAttacking) {
      return false;
    }

    _isAttacking = true;
    _attackTimeRemaining = currentAttackStepTime * attackFrameCount;
    animationTickers?[HeroState.attack]?.reset();
    current = HeroState.attack;
    return true;
  }

  @override
  Future<void> onLoad() async {
    final idleImage = await game.images.load('hero/hero_idle.png');
    final runImage = await game.images.load('hero/hero_run.png');
    final attackImage = await game.images.load('hero/hero_attack.png');
    _attackSpriteSheet = Sprite(attackImage);

    animations = {
      HeroState.idle: SpriteAnimation.fromFrameData(
        idleImage,
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: 0.1,
          textureSize: Vector2.all(96),
        ),
      ),
      HeroState.run: SpriteAnimation.fromFrameData(
        runImage,
        SpriteAnimationData.sequenced(
          amount: 16,
          stepTime: 0.07,
          textureSize: Vector2.all(96),
        ),
      ),
      HeroState.attack: _buildAttackAnimation(),
    };

    position = game.size / 2;
    current = HeroState.idle;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_direction.length2 > 0) {
      final movement = _direction.normalized() * speed * dt;
      position += movement;
      if (!_isAttacking) {
        current = HeroState.run;
      }

      if (movement.x > 0) {
        scale.x = 2;
      } else if (movement.x < 0) {
        scale.x = -2;
      }
    } else if (!_isAttacking) {
      current = HeroState.idle;
    }

    if (_isAttacking) {
      _attackTimeRemaining -= dt;
      if (_attackTimeRemaining <= 0) {
        _isAttacking = false;
        current = _direction.length2 > 0 ? HeroState.run : HeroState.idle;
      } else {
        current = HeroState.attack;
      }
    }

    final halfWidth = size.x;
    final halfHeight = size.y;
    position.x = position.x.clamp(halfWidth, game.size.x - halfWidth).toDouble();
    position.y = position.y.clamp(halfHeight, game.size.y - halfHeight).toDouble();
  }

  double get currentAttackStepTime {
    final multiplier = 1 + (_attackSpeedLevel * attackSpeedBonusPerPoint);
    final next = baseAttackStepTime / multiplier;
    if (next < minAttackStepTime) {
      return minAttackStepTime;
    }
    return next;
  }

  SpriteAnimation _buildAttackAnimation() {
    return SpriteAnimation.fromFrameData(
      _attackSpriteSheet.image,
      SpriteAnimationData.sequenced(
        amount: attackFrameCount,
        stepTime: currentAttackStepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }
}
