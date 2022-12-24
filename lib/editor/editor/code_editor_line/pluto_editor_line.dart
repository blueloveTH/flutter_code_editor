import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../intellisense.dart';
import '../editor_line_formatter/pluto_editor_formatter.dart';
import 'pluto_editor_line_controller.dart';

// ignore: constant_identifier_names
const String SPEC_CHAR = '\u200B';

class PlutoEditorLine extends StatefulWidget {
  final PlutoEditorLineController controller;
  final void Function(dynamic) onNewline;
  final int index;
  final TextStyle lineNumberStyle;

  const PlutoEditorLine({
    Key? key,
    required this.controller,
    required this.index,
    required this.onNewline,
    required this.lineNumberStyle,
  }) : super(key: key);

  @override
  State<PlutoEditorLine> createState() => _PlutoEditorLineState();
}

class _PlutoEditorLineState extends State<PlutoEditorLine> {
  late final PlutoEditorFormatter _formatter =
      PlutoEditorFormatter(widget.onNewline);

  static const double height = 24;

  _getLineNumber() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        widget.controller.root.clickLineNumber(widget.index);
      },
      child: Container(
        width: 36,
        height: height,
        color: Colors.transparent,
        padding: const EdgeInsets.only(right: 4),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            (widget.index + 1).toString(),
            style: widget.lineNumberStyle,
          ),
        ),
      ),
    );
  }

  Widget buildTextField(BuildContext context, TextEditingController controller,
      FocusNode focusNode, void Function() onSubmitted) {
    return TextField(
      decoration: null,
      autocorrect: false,
      style: const TextStyle(
        fontSize: 15,
        fontFamily: 'SourceCodePro',
      ),
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      autofocus: false,
      inputFormatters: [_formatter],
      maxLines: null,
      focusNode: focusNode,
      scrollPhysics: const NeverScrollableScrollPhysics(),
      controller: controller,
      scrollPadding: EdgeInsets.zero,
      enableIMEPersonalizedLearning: false,
      enableSuggestions: false,
      onChanged: (value) {
        if (widget.index != 0 && (value.isEmpty || value[0] != SPEC_CHAR)) {
          widget.controller.root
              .removeLine(widget.index, widget.controller.text);
        }
        if (value.contains('\n')) {
          List<String> lines = value.split('\n');
          widget.controller.text = lines[0];
          widget.onNewline(lines.sublist(1));
        }
      },
    );
  }

  Widget buildMain(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _getLineNumber(),
        Container(
          width: 1,
          height: height - 2,
          color: widget.lineNumberStyle.color,
        ),
        GestureDetector(
          onTap: () {
            widget.controller.clickHomeButton();
          },
          child: Container(
            color: Colors.transparent,
            height: height,
            width: 7,
          ),
        ),
        Expanded(
            child: RawAutocomplete<Option>(
          fieldViewBuilder: buildTextField,
          focusNode: widget.controller.focusNode,
          optionsBuilder: (TextEditingValue textEditingValue) {
            return widget.controller.autocompleteEngine
                .getCandidates(textEditingValue.text);
          },
          textEditingController: widget.controller,
          optionsViewBuilder: (BuildContext context,
              void Function(Option) onSelected, Iterable<Option> options) {
            if (options.isEmpty) return Container();
            return AutocompleteOptions(
              onSelected: onSelected,
              options: options,
              maxOptionsHeight: 200,
            );
          },
        )),
      ],
    );
  }

  Widget buildBkg(BuildContext context) {
    return Container(
        color: Colors.cyan.withOpacity(0.35),
        height: height,
        width: 65535,
        child: null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.controller.root.lineSelectionRange.contains(widget.index))
          buildBkg(context),
        buildMain(context),
      ],
    );
  }
}

class AutocompleteOptions extends StatelessWidget {
  const AutocompleteOptions({
    Key? key,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
  }) : super(key: key);

  final AutocompleteOnSelected<Option> onSelected;

  final Iterable<Option> options;
  final double maxOptionsHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxOptionsHeight,
            maxWidth: MediaQuery.of(context).size.width * 0.5,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final Option option = options.elementAt(index);
                return InkWell(
                  onTap: () {
                    onSelected(option);
                  },
                  child: Builder(builder: (BuildContext context) {
                    final bool highlight =
                        AutocompleteHighlightedOption.of(context) == index;
                    if (highlight) {
                      SchedulerBinding.instance
                          .addPostFrameCallback((Duration timeStamp) {
                        Scrollable.ensureVisible(context, alignment: 0.5);
                      });
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: highlight ? Colors.blue : null,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        '[${option.type.name.toUpperCase()}] '.padRight(12) +
                            option.key,
                        style: const TextStyle(
                            fontFamily: 'SourceCodePro', fontSize: 12),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
