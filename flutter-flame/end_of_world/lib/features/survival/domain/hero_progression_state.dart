import 'hero_attribute.dart';

class HeroProgressionState {
  const HeroProgressionState({
    this.level = 1,
    this.unspentPoints = 0,
    this.attackSpeed = 0,
    this.attackDamage = 1,
    this.strength = 0,
    this.heal = 0,
    this.currentHealth = baseHealth,
    this.currentExp = 0,
    this.expToNextLevel = 10,
  });

  static const double baseHealth = 100;

  final int level;
  final int unspentPoints;
  final int attackSpeed;
  final int attackDamage;
  final int strength;
  final int heal;
  final double currentHealth;
  final double currentExp;
  final double expToNextLevel;

  double get maxHealth => baseHealth + (strength * 5);
  bool get isDead => currentHealth <= 0;

  HeroProgressionState gainExp(double gainedExp) {
    var nextExp = currentExp + gainedExp;
    var nextLevel = level;
    var nextUnspentPoints = unspentPoints;
    var nextExpToLevel = expToNextLevel;

    while (nextExp >= nextExpToLevel) {
      nextExp -= nextExpToLevel;
      nextLevel += 1;
      nextUnspentPoints += 5;
      nextExpToLevel = (10 * (1 << (nextLevel - 1))).toDouble();
    }

    return copyWith(
      level: nextLevel,
      unspentPoints: nextUnspentPoints,
      currentExp: nextExp,
      expToNextLevel: nextExpToLevel,
    );
  }

  HeroProgressionState applyDamage(double damage) {
    final nextHealth = (currentHealth - damage).clamp(0.0, maxHealth).toDouble();
    return copyWith(currentHealth: nextHealth);
  }

  HeroProgressionState applyRegeneration(double dt) {
    if (heal <= 0 || isDead || currentHealth >= maxHealth || dt <= 0) {
      return this;
    }

    final regenerated = (currentHealth + (heal * dt)).clamp(0.0, maxHealth).toDouble();
    if (regenerated == currentHealth) {
      return this;
    }

    return copyWith(currentHealth: regenerated);
  }

  HeroProgressionState spendPoint(HeroAttribute attribute) {
    if (unspentPoints <= 0) {
      return this;
    }

    var nextAttackSpeed = attackSpeed;
    var nextAttackDamage = attackDamage;
    var nextStrength = strength;
    var nextHeal = heal;

    switch (attribute) {
      case HeroAttribute.attackSpeed:
        nextAttackSpeed += 1;
        break;
      case HeroAttribute.attackDamage:
        if (unspentPoints < 5) {
          return this;
        }
        nextAttackDamage += 1;
        break;
      case HeroAttribute.strength:
        nextStrength += 1;
        break;
      case HeroAttribute.heal:
        nextHeal += 1;
        break;
    }

    final nextState = copyWith(
      unspentPoints:
          unspentPoints -
          (attribute == HeroAttribute.attackDamage ? 5 : 1),
      attackSpeed: nextAttackSpeed,
      attackDamage: nextAttackDamage,
      strength: nextStrength,
      heal: nextHeal,
    );

    if (attribute == HeroAttribute.strength) {
      final healed =
          (nextState.currentHealth + 5).clamp(0.0, nextState.maxHealth).toDouble();
      return nextState.copyWith(currentHealth: healed);
    }

    return nextState;
  }

  HeroProgressionState copyWith({
    int? level,
    int? unspentPoints,
    int? attackSpeed,
    int? attackDamage,
    int? strength,
    int? heal,
    double? currentHealth,
    double? currentExp,
    double? expToNextLevel,
  }) {
    return HeroProgressionState(
      level: level ?? this.level,
      unspentPoints: unspentPoints ?? this.unspentPoints,
      attackSpeed: attackSpeed ?? this.attackSpeed,
      attackDamage: attackDamage ?? this.attackDamage,
      strength: strength ?? this.strength,
      heal: heal ?? this.heal,
      currentHealth: currentHealth ?? this.currentHealth,
      currentExp: currentExp ?? this.currentExp,
      expToNextLevel: expToNextLevel ?? this.expToNextLevel,
    );
  }
}
