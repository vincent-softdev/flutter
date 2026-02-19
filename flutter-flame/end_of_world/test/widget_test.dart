import 'package:flame/game.dart';
import 'package:end_of_world/app/end_of_world_app.dart';
import 'package:end_of_world/features/home/presentation/home_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Flame game widget', (WidgetTester tester) async {
    await tester.pumpWidget(const EndOfWorldApp());

    expect(find.byType(GameWidget<EndOfWorldGame>), findsOneWidget);
  });
}
