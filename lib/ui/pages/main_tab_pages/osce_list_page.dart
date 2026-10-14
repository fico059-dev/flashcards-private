import 'package:auto_route/auto_route.dart';
import 'package:flashcards/ui/widgets/osce/osce_library_view.dart';
import 'package:flutter/material.dart';

/// OSCE stations, organised in speciality folders.
@RoutePage()
class OsceListPage extends StatelessWidget {
  const OsceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: OsceLibraryView());
  }
}
