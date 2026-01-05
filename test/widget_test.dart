
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_pages/widgets/app_bottom_nav.dart';

void main() {
  testWidgets('AppBottomNavBar should persist and navigate correctly on tap', (WidgetTester tester) async {
    // 1. Build the app with routes that mimic the real app's structure.
    // Each page in the route map must include the Scaffold and the AppBottomNavBar
    // to ensure the nav bar persists across navigation, which was the root cause of the error.
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(
          body: Text('Initial Page'),
          bottomNavigationBar: AppBottomNavBar(activeIndex: 0),
        ),
        routes: {
          '/home': (context) => const Scaffold(
                body: Text('Home Page'),
                bottomNavigationBar: AppBottomNavBar(activeIndex: 0),
              ),
          '/my-team': (context) => const Scaffold(
                body: Text('My Team Page'),
                bottomNavigationBar: AppBottomNavBar(activeIndex: 1),
              ),
          '/search': (context) => const Scaffold(
                body: Text('Search Page'),
                bottomNavigationBar: AppBottomNavBar(activeIndex: 2),
              ),
          '/my-player': (context) => const Scaffold(
                body: Text('My Player Page'),
                bottomNavigationBar: AppBottomNavBar(activeIndex: 3),
              ),
        },
      ),
    );

    // 2. Allow the UI to settle.
    await tester.pumpAndSettle();

    // 3. Verify the initial state and that the keys are present.
    expect(find.text('Initial Page'), findsOneWidget);
    expect(find.byKey(const Key('nav_my_team')), findsOneWidget);

    // 4. Tap the 'My Team' item and verify navigation.
    await tester.tap(find.byKey(const Key('nav_my_team')));
    await tester.pumpAndSettle();

    // 5. Verify the new page is shown and that the nav bar keys are still present.
    expect(find.text('My Team Page'), findsOneWidget);
    expect(find.byKey(const Key('nav_home')), findsOneWidget); // This will now pass.

    // 6. Tap the 'Home' item to navigate back.
    await tester.tap(find.byKey(const Key('nav_home')));
    await tester.pumpAndSettle();

    // 7. Verify we are on the Home Page.
    expect(find.text('Home Page'), findsOneWidget);
    expect(find.text('My Team Page'), findsNothing);
  });
}
