import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../bottom_bar/pluto_editor_bottom_bar.dart';
import '../code_editor_line/pluto_editor_line.dart';
import '../code_editor_line/pluto_editor_line_controller.dart';
import 'pluto_code_editor_controller.dart';

class PlutoCodeEditor extends StatefulWidget {
  final PlutoCodeEditorController controller;

  const PlutoCodeEditor({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<PlutoCodeEditor> createState() => _PlutoCodeEditorState();
}

enum Lang {
  python,
  markdown,
}

class _PlutoCodeEditorState extends State<PlutoCodeEditor> {
  late final Timer _timer;

  _listener() {
    setState(() {});
  }

  @override
  void initState() {
    widget.controller.addListener(_listener);
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (widget.controller.lang != Lang.python) return;
      widget.controller.autocompleteEngine.update(widget.controller.getText());
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    _timer.cancel();
    super.dispose();
  }

  _getOnNewLine(int index) {
    return (dynamic lines) async {
      if (lines is String) lines = [lines];
      late PlutoEditorLineController lineController;
      for (int j = 0; j < lines.length; j++) {
        lineController = widget.controller.getNewLineController(lines[j]);
        widget.controller.controllers.insert(index + 1 + j, lineController);
      }
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        FocusScope.of(context).requestFocus(lineController.focusNode);
        lineController.selection = const TextSelection.collapsed(offset: 1);
      });
    };
  }

  Widget buildBottom(BuildContext context) {
    if (widget.controller.lineSelectionRange.hasValue()) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                    text: widget.controller.getLineSelectionText()));
                widget.controller.clearSelection();
              },
              child: Text("复制")),
          SizedBox(
            width: 4,
          ),
          OutlinedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                    text: widget.controller.getLineSelectionText()));
                widget.controller.removeLineSelectionText();
              },
              child: Text("剪切")),
          SizedBox(
            width: 4,
          ),
          OutlinedButton(
              onPressed: () {
                widget.controller.clearSelection();
              },
              child: Text("取消")),
        ],
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [
      PlutoEditorBottomBar(
        controller: widget.controller,
        reverse: true,
      ),
      PlutoEditorBottomBar(
        reverse: false,
        controller: widget.controller,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: widget.controller.theme.backgroundColor,
            child: ListView.builder(
              itemCount: widget.controller.controllers.length,
              itemBuilder: (context, index) {
                return PlutoEditorLine(
                  controller: widget.controller.controllers[index],
                  index: index,
                  dividerLineColor: widget.controller.theme.dividerLineColor,
                  lineNumberStyle: widget.controller.theme.lineNumberStyle,
                  onNewline: _getOnNewLine(index),
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        buildBottom(context),
      ],
    );
  }
}
