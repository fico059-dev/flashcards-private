import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Same side-menu setup as MainTabPage uses on computers.
void main() {
  testWidgets('side menu with profile button at the bottom lays out', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: true,
                minExtendedWidth: 200,
                selectedIndex: 0,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.style),
                    label: Text('Cards'),
                  ),
                ],
                trailingAtBottom: true,
                trailing: IconButton(
                  icon: const Icon(CupertinoIcons.profile_circled),
                  onPressed: () {},
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getCenter(find.byIcon(CupertinoIcons.profile_circled)).dy,
      greaterThan(600),
    );
  });
}
