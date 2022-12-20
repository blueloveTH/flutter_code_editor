import 'package:flutter/material.dart';

class EditorTheme {
  late Color backgroundColor;
  late Color fontColor;
  late Color dividerLineColor;
  final String fontFamily = 'SourceCodePro';
  late Map<String, TextStyle> syntaxTheme;
  late TextStyle lineNumberStyle;

  static final EditorTheme _instance = EditorTheme._();
  static EditorTheme get instance => _instance;

  EditorTheme._() {
    syntaxTheme = const {
      'root': TextStyle(
          color: Color(0xffcccccc), backgroundColor: Color(0xff1e1e1e)),
      'comment': TextStyle(color: Color(0xff6a9955)),
      'keyword': TextStyle(color: Color(0xFFC586C0)),
      'function': TextStyle(color: Color(0xffdcdcaa)),
      'number': TextStyle(color: Color(0xffb5cea8)),
      'name': TextStyle(color: Color(0xffe06c75)),
      'string': TextStyle(color: Color(0xffce9178)),
      'link': TextStyle(color: Color.fromARGB(255, 222, 222, 0)),
      'symbol': TextStyle(color: Color(0xff858585), fontSize: 12),
      //'symbol_highlight': TextStyle(color: Color(0xFFC6C6C6)),
    };
    dividerLineColor = syntaxTheme['symbol']!.color!;
    backgroundColor = syntaxTheme['root']!.backgroundColor!;
    fontColor = syntaxTheme['root']!.color!;
    lineNumberStyle = syntaxTheme['symbol']!;
  }
}
