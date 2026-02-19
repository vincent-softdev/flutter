import 'package:flame/components.dart';
import 'package:flame/game.dart';

class EndOfWorldGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    add(HomeBackgroundComponent());
  }
}

class HomeBackgroundComponent extends SpriteComponent
    with HasGameReference<EndOfWorldGame> {
  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('home_background.png');
    priority = -1;
    _syncToGameSize(game.size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _syncToGameSize(size);
  }

  void _syncToGameSize(Vector2 gameSize) {
    size = gameSize;
    anchor = Anchor.center;
    position = gameSize / 2;
  }
}
