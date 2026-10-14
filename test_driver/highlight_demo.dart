// A web page with one highlightable card, for testing text selection in a
// mobile browser: flutter build web --target test_driver/highlight_demo.dart
import 'package:flashcards/data/remote/cloud_function_service.dart';
import 'package:flashcards/data/repositories/notebook/highlight_repository.dart';
import 'package:flashcards/data/services/api/users/auth_service.dart';
import 'package:flashcards/domain/models/flashcards/highlight/highlight.dart';
import 'package:flashcards/ui/widgets/notebook/highlightable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class _User implements User {
  @override
  String get uid => 'demo';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth implements AuthService {
  @override
  User? getCurrentUser() => _User();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Functions implements CloudFunctionService {
  @override
  Future<String> saveHighlight(Map<String, dynamic> highlight) async => 'h1';
  @override
  Future<List<Map<String, dynamic>>> listHighlights() async => [];
  @override
  Future<void> deleteHighlight(String id) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb && const bool.fromEnvironment('APP_MENU')) {
    await BrowserContextMenu.disableContextMenu();
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => HighlightRepository(
        functions: _Functions(),
        authService: _Auth(),
      ),
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.fromLTRB(24, 80, 24, 24),
            child: HighlightableText(
              'Classic galactosemia is notorious for E. coli sepsis in '
              'neonates. Confirmatory testing includes erythrocyte enzyme '
              'assay and measurement of erythrocyte galactose-1-phosphate.',
              style: TextStyle(fontSize: 20),
              target: HighlightTarget(
                flashcardId: 'c1',
                packId: 'p',
                side: HighlightSide.answer,
                question: 'q',
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
