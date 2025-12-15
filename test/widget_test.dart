import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:payrent/main.dart';
import 'package:payrent/presentation/shared/pages/splash_screen.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap MyApp with ProviderScope and override authStateProvider to avoid timers
    // NOTE: Maintenant c'est un AutoDisposeFutureProvider !
    final fakeAuthProvider = FutureProvider.autoDispose<AuthCheckResult>((ref) async {
      return AuthCheckResult(state: AuthState.loading);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWithProvider(fakeAuthProvider),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that SplashScreen is shown as initial route
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}