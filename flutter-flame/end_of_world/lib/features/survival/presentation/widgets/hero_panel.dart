import 'package:flutter/material.dart';

class HeroPanel extends StatelessWidget {
  const HeroPanel({
    required this.unspentPoints,
    required this.attackSpeed,
    required this.attackDamage,
    required this.strength,
    required this.heal,
    required this.onClose,
    required this.onUpgradeAttackSpeed,
    required this.onUpgradeAttackDamage,
    required this.onUpgradeStrength,
    required this.onUpgradeHeal,
    super.key,
  });

  final int unspentPoints;
  final int attackSpeed;
  final int attackDamage;
  final int strength;
  final int heal;
  final VoidCallback onClose;
  final VoidCallback onUpgradeAttackSpeed;
  final VoidCallback onUpgradeAttackDamage;
  final VoidCallback onUpgradeStrength;
  final VoidCallback onUpgradeHeal;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Hero',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
                ],
              ),
              Text(
                'Available points: $unspentPoints',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _HeroStatRow(
                label: 'Attack Speed',
                value: attackSpeed,
                canUpgrade: unspentPoints > 0,
                onUpgrade: onUpgradeAttackSpeed,
              ),
              _HeroStatRow(
                label: 'Attack Damage (cost 5)',
                value: attackDamage,
                canUpgrade: unspentPoints >= 5,
                onUpgrade: onUpgradeAttackDamage,
              ),
              _HeroStatRow(
                label: 'Strength (+5 blood)',
                value: strength,
                canUpgrade: unspentPoints > 0,
                onUpgrade: onUpgradeStrength,
              ),
              _HeroStatRow(
                label: 'Heal (HP/sec)',
                value: heal,
                canUpgrade: unspentPoints > 0,
                onUpgrade: onUpgradeHeal,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tip: Press P to open/close this panel',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStatRow extends StatelessWidget {
  const _HeroStatRow({
    required this.label,
    required this.value,
    required this.canUpgrade,
    required this.onUpgrade,
  });

  final String label;
  final int value;
  final bool canUpgrade;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: canUpgrade ? onUpgrade : null,
            child: const Text('+1'),
          ),
        ],
      ),
    );
  }
}
