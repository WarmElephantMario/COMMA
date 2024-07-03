// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

<<<<<<< HEAD
=======
<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_plugin/main.dart';
=======
>>>>>>> 80dd8e0076664cb755496179f9460b252c3bc1c3
import 'package:comma_script/60prepare.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


<<<<<<< HEAD
=======
>>>>>>> 5bfb9b3 (Add comma_script folder)
>>>>>>> 80dd8e0076664cb755496179f9460b252c3bc1c3

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
<<<<<<< HEAD
    await tester.pumpWidget(MyApp());
=======
<<<<<<< HEAD

    await tester.pumpWidget(const FigmaToCodeApp());
=======
    await tester.pumpWidget(MyApp());
>>>>>>> 5bfb9b3 (Add comma_script folder)
>>>>>>> 80dd8e0076664cb755496179f9460b252c3bc1c3

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
