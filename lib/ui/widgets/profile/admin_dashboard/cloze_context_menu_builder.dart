import 'package:flutter/material.dart';

Widget clozeContextMenuBuilder(
  BuildContext context,
  EditableTextState editableTextState,
  TextEditingController controller,
) {
  late final ContextMenuButtonItem customItem;
  if (controller.selection.start == controller.selection.end) {
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: editableTextState.contextMenuButtonItems,
    );
  } else if (isCloze(controller)) {
    customItem = buildRemoveClozeItem(controller);
  } else {
    customItem = buildAddClozeItem(controller);
  }
  final buttonItems = [customItem, ...editableTextState.contextMenuButtonItems];

  return AdaptiveTextSelectionToolbar.buttonItems(
    anchors: editableTextState.contextMenuAnchors,
    buttonItems: buttonItems,
  );
}

ContextMenuButtonItem buildAddClozeItem(TextEditingController controller) {
  return ContextMenuButtonItem(
    onPressed: () {
      final selection = controller.selection;
      final text = controller.text;
      if (selection.isValid && !selection.isCollapsed) {
        final selectedText = text.substring(selection.start, selection.end);
        controller.text = replaceControllerText(controller, selectedText);
      }
      ContextMenuController.removeAny();
    },
    label: "فراغ (Cloze)",
  );
}

ContextMenuButtonItem buildRemoveClozeItem(TextEditingController controller) {
  return ContextMenuButtonItem(
    onPressed: () {
      final selection = controller.selection;
      final text = controller.text;
      if (selection.isValid && !selection.isCollapsed) {
        final selectedText = getSelectedText(controller);
        final result = getSelectedTextExtended(controller);
        late final int start, end;
        late final String newText;
        if (isWrappedWithBrackets(selectedText)) {
          newText = removeBrackets(selectedText);
          start = controller.selection.start;
          end = controller.selection.end;
        } else if (isWrappedWithBrackets(result.selectedTextExtended)) {
          newText = removeBrackets(result.selectedTextExtended);
          start = result.start;
          end = result.end;
        } else {
          newText = "";
          start = controller.selection.start;
          end = controller.selection.end;
        }
        controller.text = controller.text.replaceRange(start, end, newText);
        ContextMenuController.removeAny();
      }
    },
    label: "إزالة الفراغ",
  );
}

// if the selection is "someText" and selection is wrapped with {} it's considered a cloze
// also if the selection is "{someText}" it's also considered a cloze
bool isCloze(TextEditingController controller) {
  final selectedText = getSelectedText(controller);
  final result = getSelectedTextExtended(controller);
  final extendedSelectedText = result.selectedTextExtended;

  if (isWrappedWithBrackets(selectedText)) return true;
  return isWrappedWithBrackets(extendedSelectedText);
}

bool isWrappedWithBrackets(String text) {
  return text.startsWith('{') && text.endsWith('}');
}

String replaceControllerText(TextEditingController controller, String newText) {
  final text = controller.text;
  final selection = controller.selection;
  return text.replaceRange(selection.start, selection.end, "{$newText}");
}

String removeBrackets(String text) {
  text = text.replaceFirst('{', '');
  text = text.replaceFirst('}', '');
  return text;
}

String getSelectedText(TextEditingController controller) {
  final selection = controller.selection;
  final text = controller.text;

  return text.substring(selection.start, selection.end);
}

ExtendedTextResult getSelectedTextExtended(TextEditingController controller) {
  final selection = controller.selection;
  final text = controller.text;

  final start = selection.start == 0 ? selection.start : selection.start - 1;
  final end = selection.end == text.length ? selection.end : selection.end + 1;
  return ExtendedTextResult(
    selectedTextExtended: text.substring(start, end),
    start: start,
    end: end,
  );
}

class ExtendedTextResult {
  final String selectedTextExtended;
  final int start;
  final int end;

  const ExtendedTextResult({
    required this.selectedTextExtended,
    required this.start,
    required this.end,
  });
}
