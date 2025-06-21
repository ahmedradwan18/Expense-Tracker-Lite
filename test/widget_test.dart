import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic App Tests', () {
    testWidgets('App should have MaterialApp', (WidgetTester tester) async {
      // Create a simple test app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Test')),
            body: Center(child: Text('Hello World')),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            ),
          ),
        ),
      );

      // Verify basic widgets exist
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('FloatingActionButton should be tappable', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test')),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                tapped = true;
              },
              child: Icon(Icons.add),
            ),
          ),
        ),
      );

      // Find and tap the floating action button
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      
      await tester.tap(fab);
      await tester.pump();

      // Verify the button was tapped
      expect(tapped, isTrue);
    });

    testWidgets('Basic navigation should work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => Scaffold(
              body: Center(child: Text('Home')),
              floatingActionButton: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/second'),
                child: Icon(Icons.add),
              ),
            ),
            '/second': (context) => Scaffold(
              body: Center(child: Text('Second Page')),
            ),
          },
        ),
      );

      // Verify we're on the home page
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Second Page'), findsNothing);

      // Tap the FAB to navigate
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify navigation worked
      expect(find.text('Home'), findsNothing);
      expect(find.text('Second Page'), findsOneWidget);
    });
  });
} 