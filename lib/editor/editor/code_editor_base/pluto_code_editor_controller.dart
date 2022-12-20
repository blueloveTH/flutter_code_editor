import 'package:flutter/material.dart';
import '../../intellisense.dart';
import '../code_editor_line/pluto_editor_line.dart';
import '../code_editor_line/pluto_editor_line_controller.dart';
import '../editor_theme.dart';
import 'pluto_code_editor.dart';

void insertText(TextEditingController textC, String text,
    {int selectionOffset = 0, TextSelection? selection}) {
  selection = selection ?? textC.selection;
  if (!selection.isValid) {
    String newText = textC.text + text;
    textC.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  } else {
    final newText =
        textC.text.replaceRange(selection.start, selection.end, text);
    textC.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: selection.baseOffset + text.length + selectionOffset),
    );
  }
}

class PlutoCodeEditorController extends ValueNotifier {
  final List<PlutoEditorLineController> controllers = [];
  final AutocompleteEngine autocompleteEngine = AutocompleteEngine();
  EditorTheme get theme => EditorTheme.instance;

  Lang _lang = Lang.python;
  Lang get lang => _lang;
  set lang(Lang value) {
    _lang = value;
    for (var controller in controllers) {
      controller.lang = value;
    }
    notifyListeners();
  }

  PlutoCodeEditorController() : super(1);

  PlutoEditorLineController? getFocusedController() {
    for (var controller in controllers) {
      if (controller.focusNode.hasFocus) return controller;
    }
    return null;
  }

  void addChar(String char) {
    var c = getFocusedController();
    if (c == null) return;
    insertText(c, char, selectionOffset: (char.trim().length == 2) ? -1 : 0);
    notifyListeners();
  }

  String getLineSelectionText() {
    if (!lineSelectionRange.hasValue()) return "";
    return getText(
        start: lineSelectionRange.start, end: lineSelectionRange.end + 1);
  }

  void onLineFocus() {
    if (lineSelectionRange.hasValue()) clearSelection();
  }

  void removeLine(int index, String suffixText) async {
    if (index == 0) return;
    var tobeRemoved = controllers[index];
    controllers.removeAt(index);
    PlutoEditorLineController controller = controllers[index - 1];
    int offset = controller.text.length;
    controller.text += suffixText;
    controller.focusNode.requestFocus();
    controller.selection = TextSelection.collapsed(offset: offset);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tobeRemoved.dispose();
    });
    notifyListeners();
  }

  void removeLineSelectionText() {
    if (!lineSelectionRange.hasValue()) return;
    var start = lineSelectionRange.start;
    var end = lineSelectionRange.end;
    if (start == 0) {
      start++;
      controllers[0].text = '';
    }
    for (int i = start; i <= end; i++) {
      controllers[i].dispose();
    }
    controllers.removeRange(start, end + 1);
    clearSelection();
  }

  String getText({int start = 0, int? end}) {
    StringBuffer buffer = StringBuffer();
    for (int i = start; i < (end ?? controllers.length); i++) {
      String line = controllers[i].text;
      line = line.replaceAll(SPEC_CHAR, '');
      buffer.write(line);
      if (i < controllers.length - 1) buffer.write('\n');
    }
    return buffer.toString();
  }

  void setText(String code) {
    controllers.clear();
    List<String> lines = code.split('\n');
    for (int i = 0; i < lines.length; i++) {
      controllers.add(
        PlutoEditorLineController(text: SPEC_CHAR + lines[i], root: this, lang: lang),
      );
    }
    notifyListeners();
  }

  PlutoEditorLineController getNewLineController(String text) {
    PlutoEditorLineController lineController =
        PlutoEditorLineController(text: SPEC_CHAR + text, root: this, lang: lang);
    lineController.selection = const TextSelection.collapsed(offset: 1);
    return lineController;
  }

  final LineSelectionRange lineSelectionRange = LineSelectionRange();

  void clickLineNumber(int index) {
    lineSelectionRange.click(index);
    notifyListeners();
  }

  void clearSelection() {
    lineSelectionRange.clear();
    notifyListeners();
  }
}

class LineSelectionRange {
  int start = -1;
  int end = -1;

  bool hasValue() {
    return start != -1 && end != -1;
  }

  void clear() {
    start = -1;
    end = -1;
  }

  void click(int i) {
    if (!hasValue()) {
      start = i;
      end = i;
    } else {
      if (i < start) {
        start = end = i;
        return;
      }
      end = i;
    }
  }

  bool contains(int index) {
    return index >= start && index <= end;
  }
}
