import 'package:flutter/material.dart';
import 'dart:io';

import '../editor/code_editor_base/pluto_code_editor_controller.dart';
import 'pluto_bottom_bar_key_card.dart';

class PlutoEditorBottomBar extends StatefulWidget {
  final PlutoCodeEditorController controller;
  final bool reverse;
  const PlutoEditorBottomBar(
      {Key? key, required this.controller, required this.reverse})
      : super(key: key);

  @override
  State<PlutoEditorBottomBar> createState() => _PlutoEditorBottomBarState();
}

class _PlutoEditorBottomBarState extends State<PlutoEditorBottomBar> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) return const SizedBox();

    var keys = [
      ':',
      '_',
      '()',
      '[]',
      '.',
      ',',
      "''",
      '+',
      '-',
      '*',
      '/',
      '%',
      '=',
      '>',
      '<',
      '#',
    ];

    List<KeyCard> cards = [
      KeyCard(
        char: 'TAB',
        onTap: () {
          widget.controller.addChar('  ');
        },
      ),
      KeyCard(
        char: '▶',
        onTap: () {
          widget.controller.addChar('▶ ');
        },
      ),
      for (var c in keys)
        KeyCard(char: c, onTap: () => widget.controller.addChar(c)),
    ];

    if (widget.reverse) {
      cards = cards.reversed.toList();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 40,
        color: widget.controller.theme.keyword.color,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
          separatorBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                color: Colors.white,
                width: 1,
              ),
            );
          },
        ),
      ),
    );
  }
}
