import 'package:flutter_test/flutter_test.dart';

import 'package:spin_the_wheel/main.dart';

void main() {
  testWidgets('App renders wheel page', (WidgetTester tester) async {
    await tester.pumpWidget(const SpinTheWheelApp());

    expect(find.text('Spin the Wheel'), findsOneWidget);
  });
}
