import 'package:flutter/material.dart';

import '../../intellisense.dart';
import '../code_editor_base/pluto_code_editor.dart';
import '../code_editor_line/pluto_editor_line.dart';
import '../editor_theme.dart';
import '../syntax/bonicpython.dart';

class PlutoRichCodeEditingController extends TextEditingController {
  EditorTheme get theme => EditorTheme.instance;
  Lang lang = Lang.markdown;

  PlutoRichCodeEditingController({
    String? text,
    required this.lang,
  }) : super(text: text);

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context, TextStyle? style, bool? withComposing}) {
    var textStyle = theme.root;
    if (lang == Lang.markdown) return TextSpan(style: textStyle, text: text);
    return TextSpan(
      style: textStyle,
      children: getHighlightTextSpan(value.text, theme),
    );
  }
}

class IndexedSpan {
  final int start;
  final int end;
  final InlineSpan span;

  IndexedSpan(
    this.start,
    this.end,
    this.span,
  );
}

List<InlineSpan> getHighlightTextSpan(String source, EditorTheme theme) {
  if (source.isEmpty) {
    return [];
  }

  List<IndexedSpan> spans = [];

  String copy = source;

  copy = copy.replaceAllMapped(patternComment, (match) {
    spans.add(IndexedSpan(match.start, match.end,
        TextSpan(text: match.group(0), style: theme.comment)));
    return '\$' * match.group(0)!.length;
  });

  copy = copy.replaceAllMapped(patternStringSingleQuote, (match) {
    spans.add(IndexedSpan(
      match.start,
      match.end,
      TextSpan(text: match.group(0), style: theme.string),
    ));
    return '\$' * match.group(0)!.length;
  });

  copy = copy.replaceAllMapped(patternStringDoubleQuote, (match) {
    spans.add(IndexedSpan(
      match.start,
      match.end,
      TextSpan(text: match.group(0), style: theme.string),
    ));
    return '\$' * match.group(0)!.length;
  });

  copy = copy.replaceAllMapped(
      RegExp(r'\b(goto|label)\s+\.' + identifierRaw, unicode: true), (match) {
    spans.add(IndexedSpan(match.start, match.end,
        TextSpan(text: match.group(0), style: theme.link)));
    return '\$' * match.group(0)!.length;
  });

  copy = copy.replaceAllMapped(RegExp(r'\b(' + keywords.join('|') + r')\b'),
      (match) {
    spans.add(IndexedSpan(
        match.start,
        match.end,
        TextSpan(
          text: match.group(0),
          style: theme.keyword,
        )));
    return '\$' * match.group(0)!.length;
  });

  copy = copy.replaceAllMapped(
      RegExp(identifierRaw + r'\s*(?=\()', unicode: true), (match) {
    spans.add(IndexedSpan(match.start, match.end,
        TextSpan(text: match.group(0), style: theme.function)));
    return '\$' * match.group(0)!.length;
  });

  copy = copy.replaceAllMapped(RegExp(r'\b\d+\b'), (match) {
    spans.add(IndexedSpan(match.start, match.end,
        TextSpan(text: match.group(0), style: theme.number)));
    return '\$' * match.group(0)!.length;
  });

  spans.sort((a, b) => a.start.compareTo(b.start));
  List<int> results = List.generate(
      source.length, (index) => -1); // -1 for normal, -2 for @indent

  for (int i = 0; i < spans.length; i++) {
    for (var j = spans[i].start; j < spans[i].end; j++) {
      results[j] = i;
    }
  }

  for (int i = 0; i < results.length; i++) {
    if (i == 0 && source[i] == SPEC_CHAR) continue;
    if (results[i] == -1 && source[i] == ' ') {
      results[i] = -2;
    } else {
      break;
    }
  }

  // merge continuous spans
  List<InlineSpan> merged = [];
  int start = 0;
  for (int i = 1; i <= results.length; i++) {
    if (i == results.length || results[i] != results[start]) {
      if (results[start] == -1) {
        merged.add(TextSpan(text: source.substring(start, i)));
      } else if (results[start] == -2) {
        merged.add(TextSpan(
            text: '·' * (i - start),
            style: TextStyle(color: theme.root.color!.withOpacity(0.6))));
      } else {
        merged.add(spans[results[start]].span);
      }
      start = i;
    }
  }

  return merged;
}
