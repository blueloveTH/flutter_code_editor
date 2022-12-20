import 'package:flutter/material.dart';

import '../../intellisense.dart';
import '../code_editor_base/pluto_code_editor.dart';
import '../code_editor_base/pluto_code_editor_controller.dart';
import '../editor_line_formatter/pluto_rich_code_editing_controller.dart';

class PlutoEditorLineController extends PlutoRichCodeEditingController {
  final FocusNode _focusNode = FocusNode();
  final PlutoCodeEditorController root;
  AutocompleteEngine get autocompleteEngine => root.autocompleteEngine;

  PlutoEditorLineController({
    required String text,
    required this.root,
    required Lang lang,
  }) : super(text: text, lang: lang) {
    focusNode.addListener(() {
      if (focusNode.hasFocus) root.onLineFocus();
    });
  }

  FocusNode get focusNode => _focusNode;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void clickHomeButton() {
    focusNode.requestFocus();
    selection = TextSelection.collapsed(offset: 1);
  }
}
