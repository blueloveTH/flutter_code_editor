import 'package:flutter/services.dart';

class PlutoEditorFormatter extends TextInputFormatter {
  final void Function(String text) onNewLine;

  PlutoEditorFormatter(this.onNewLine);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    PressedKey pressedKey = KeyboardUtilz.getPressedKey(oldValue, newValue);
    if (pressedKey == PressedKey.enter) {
      int offset = oldValue.selection.baseOffset;
      String prefixText = oldValue.text.substring(0, offset);
      String suffixText = oldValue.text.substring(offset);
      newValue = TextEditingValue(
        text: prefixText,
        selection: TextSelection.fromPosition(
          TextPosition(offset: prefixText.length),
        ),
      );
      onNewLine(suffixText);
    }

    return newValue;
  }
}

class KeyboardUtilz {
  /// Check and see if last pressed key was enter key.
  /// This is checked by looking if the last character text == "\n".
  static PressedKey getPressedKey(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text == "\n") {
      return PressedKey.enter;
    }

    final TextSelection newSelection = newValue.selection;
    final TextSelection currentSelection = oldValue.selection;

    if (currentSelection.baseOffset > newSelection.baseOffset) {
      //backspace was pressed
      return PressedKey.backSpace;
    }

    var lastChar = newValue.text
        .substring(currentSelection.baseOffset, newSelection.baseOffset);

    return lastChar == "\n" ? PressedKey.enter : PressedKey.regular;
  }
}

enum PressedKey { enter, backSpace, regular }