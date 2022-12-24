import 'package:flutter/material.dart';

class EditorTheme {
  static final EditorTheme _instance = EditorTheme._();
  static EditorTheme get instance => _instance;

  final Color backgroundColor = const Color(0xff1e1e1e);
  TextStyle get lineNumberStyle => symbol;

  TextStyle root = const TextStyle(color: Color(0xffcccccc), fontFamily: 'SourceCodePro');
  TextStyle comment = const TextStyle(color: Color(0xff6a9955));
  TextStyle keyword = const TextStyle(color: Color(0xFFC586C0));
  TextStyle function = const TextStyle(color: Color(0xffdcdcaa));
  TextStyle number = const TextStyle(color: Color(0xffb5cea8));
  TextStyle name = const TextStyle(color: Color(0xffe06c75));
  TextStyle string = const TextStyle(color: Color(0xffce9178));
  TextStyle link = const TextStyle(color: Color.fromARGB(255, 222, 222, 0));
  TextStyle symbol = const TextStyle(color: Color(0xff858585), fontSize: 12);

  EditorTheme._();
}
