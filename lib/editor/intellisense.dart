import 'package:retrieval/trie.dart';

import 'editor/code_editor_line/pluto_editor_line.dart';
import 'editor/syntax/bonicpython.dart';

final RegExp patternComment = RegExp(r'#[^\n]*');
final RegExp patternStringSingleQuote = RegExp(r"f?'.*?'");
final RegExp patternStringDoubleQuote = RegExp(r'f?".*?"');
const String identifierRaw = r'[\p{Lo}a-zA-Z_][\p{Lo}a-zA-Z0-9_]*';
final RegExp patternIdentifier = RegExp(identifierRaw, unicode: true);

String patchSrc(String src) {
  var pattern = RegExp(r"^(\s*)▶\s*(.*)$", unicode: true, multiLine: true);
  return src.replaceAllMapped(pattern, (match) {
    // ignore: prefer_interpolation_to_compose_strings
    return match.group(1)! + "print('${match.group(2)}')";
  });
}

Set<String> getSymbols(String source) {
  source = patchSrc(source);
  source = source.replaceAllMapped(patternComment, (match) {
    return '\$' * match.group(0)!.length;
  });

  source = source.replaceAllMapped(patternStringSingleQuote, (match) {
    return '\$' * match.group(0)!.length;
  });

  source = source.replaceAllMapped(patternStringDoubleQuote, (match) {
    return '\$' * match.group(0)!.length;
  });

  Set<String> symbols = {};
  source = source.replaceAllMapped(patternIdentifier, (match) {
    symbols.add(match.group(0)!);
    return '\$' * match.group(0)!.length;
  });

  return symbols;
}

class AutocompleteEngine {
  late Trie trie = Trie();

  String? prevSource;

  void update(String source) {
    if (source == prevSource) return;
    trie = Trie();
    for (var element in keywords.union(builtins)) {
      trie.insert(element);
    }
    Set<String> symbols = getSymbols(source);
    for (String symbol in symbols) {
      if (symbol.length <= 1) continue;
      trie.insert(symbol);
    }
    prevSource = source;
  }

  List<Option> getCandidates(String text) {
    final pattern =
        RegExp(r'([\p{Lo}a-zA-Z_][\p{Lo}a-zA-Z0-9_]+)$', unicode: true);
    var match = pattern.firstMatch(text);
    if (match == null) return [];
    String prefix = text.substring(0, match.start);
    bool canBeKeyword =
        prefix == SPEC_CHAR || prefix.isEmpty || prefix.endsWith(' ');
    List<String> candidates = trie.find(match.group(1)!);
    List<Option> result = [];
    for (String key in candidates) {
      if (key == match.group(1)) continue;
      String newText = text.replaceFirstMapped(pattern, (match) => key);
      if (!canBeKeyword && (keywords.contains(key) || builtins.contains(key))) {
        continue;
      }
      result.add(Option(key: key, newText: newText));
    }
    result.sort((a, b) => a.type.index.compareTo(b.type.index));
    return result;
  }
}

enum CandidateType { divert, keyword, builtin, name }

class Option {
  final String key;
  final String newText;
  late final CandidateType type;

  Option({required this.key, required this.newText}) {
    if (key == 'goto' || key == 'label') {
      type = CandidateType.divert;
    } else if (keywords.contains(key)) {
      type = CandidateType.keyword;
    } else if (builtins.contains(key)) {
      type = CandidateType.builtin;
    } else {
      type = CandidateType.name;
    }
  }

  @override
  String toString() {
    return newText;
  }
}
