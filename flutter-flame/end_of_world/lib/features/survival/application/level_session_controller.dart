import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../domain/hero_attribute.dart';
import '../domain/hero_progression_state.dart';

abstract class HeroHudSink {
  void syncHeroHud(HeroProgressionState state);
}

class LevelSessionController extends ChangeNotifier {
  LevelSessionController({HeroProgressionState? initialState})
    : _heroState = initialState ?? const HeroProgressionState();

  HeroProgressionState _heroState;
  HeroHudSink? _heroHudSink;
  bool _showHeroPanel = false;
  double _pendingHeroDamage = 0;
  bool _isDamageFlushScheduled = false;

  HeroProgressionState get heroState => _heroState;
  bool get showHeroPanel => _showHeroPanel;
  bool get isHeroDead => _heroState.isDead;
  bool get shouldPauseGameplay => _showHeroPanel || isHeroDead;

  void attachHeroHudSink(HeroHudSink sink) {
    _heroHudSink = sink;
    _syncHeroHud();
  }

  void toggleHeroPanel() {
    if (isHeroDead) {
      return;
    }
    _showHeroPanel = !_showHeroPanel;
    notifyListeners();
  }

  void handleMonsterKilled(int monsterMaxHealth) {
    _heroState = _heroState.gainExp(monsterMaxHealth.toDouble());
    _syncAndNotify();
  }

  void handleGameTick(double dt) {
    if (isHeroDead) {
      return;
    }

    final nextState = _heroState.applyRegeneration(dt);
    if (identical(nextState, _heroState)) {
      return;
    }

    _heroState = nextState;
    _syncAndNotify();
  }

  void handleHeroDamaged(double damage) {
    if (isHeroDead) {
      return;
    }
    _pendingHeroDamage += damage;
    if (_isDamageFlushScheduled) {
      return;
    }

    _isDamageFlushScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final damageToApply = _pendingHeroDamage;
      _pendingHeroDamage = 0;
      _isDamageFlushScheduled = false;
      if (damageToApply <= 0) {
        return;
      }

      _heroState = _heroState.applyDamage(damageToApply);
      if (_heroState.isDead) {
        _showHeroPanel = false;
      }
      _syncAndNotify();
    });
  }

  void spendPoint(HeroAttribute attribute) {
    if (isHeroDead) {
      return;
    }
    final next = _heroState.spendPoint(attribute);
    if (identical(next, _heroState)) {
      return;
    }

    _heroState = next;
    _syncAndNotify();
  }

  void _syncAndNotify() {
    _syncHeroHud();
    notifyListeners();
  }

  void _syncHeroHud() {
    _heroHudSink?.syncHeroHud(_heroState);
  }
}
