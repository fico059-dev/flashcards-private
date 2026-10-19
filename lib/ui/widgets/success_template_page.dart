import 'dart:async';

import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';

class SuccessTemplatePage extends StatefulWidget {
  final Widget topAsset;
  final String textString;
  final String buttonText;
  final VoidCallback redirectTo;
  final bool enableRedirectTimer;

  const SuccessTemplatePage({
    super.key,
    required this.topAsset,
    required this.textString,
    required this.buttonText,
    required this.redirectTo,
    this.enableRedirectTimer = true,
  });

  @override
  State<SuccessTemplatePage> createState() => _SuccessTemplatePageState();
}

class _SuccessTemplatePageState extends State<SuccessTemplatePage> {
  late final Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    if (widget.enableRedirectTimer) {
      _redirectTimer = Timer(const Duration(seconds: 8), () {
        if (!context.mounted) return;
        widget.redirectTo;
      });
    }
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReadableWidth(
        maxWidth: 820,
        child: Container(
          margin: const EdgeInsets.only(top: 100),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalScreenPadding,
            vertical: 20,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  widget.topAsset,
                  Text(
                    widget.textString,
                    style: TextTheme.of(context).bodyLarge,
                  ),
                ],
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: widget.redirectTo,
                    child: Text(widget.buttonText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
