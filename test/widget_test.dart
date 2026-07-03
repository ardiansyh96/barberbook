import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:barber_book/core/utils/validators.dart';
import 'package:barber_book/main.dart';

void main() {
  testWidgets('App smoke test - BarberBookApp renders', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: BarberBookApp()),
    );

    // Verify the app renders without errors.
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('confirm password validator uses the latest password value', (
    WidgetTester tester,
  ) async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(controller: passwordController),
                TextFormField(
                  controller: confirmController,
                  validator: (value) => Validators.confirmPassword(
                    passwordController.text,
                  )(value),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'password123');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.pump();

    expect(formKey.currentState!.validate(), isTrue);
  });
}
