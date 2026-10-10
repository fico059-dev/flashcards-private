import 'package:flashcards/ui/widgets/auth/auth_error_container.dart';
import 'package:flashcards/ui/widgets/core/bloc_animated_icon.dart';
import 'package:flashcards/ui/widgets/core/theme_toggle_button.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';

import '../../constants/styles.dart';

class AuthScreenContainer extends StatelessWidget {
  final BlocAnimatedIcon authIcon;
  final Widget messageContainer;
  final List<Widget> otherContent;
  final Widget message;
  final List<Widget> inputs;

  const AuthScreenContainer({
    super.key,
    required this.authIcon,
    required this.messageContainer,
    required this.otherContent,
    required this.message,
    required this.inputs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: null, actions: [ThemeToggleButton()]),
      body: ReadableWidth(
        maxWidth: 480,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalScreenPadding,
                vertical: 10,
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  authIcon,
                  SizedBox(height: 20),
                  messageContainer,
                  SizedBox(height: 20),
                  message,
                  SizedBox(height: 25),
                  Column(spacing: 15, children: inputs),
                  SizedBox(height: 10),
                  ...otherContent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
