import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:string_scanner/string_scanner.dart';

import 'formatter.dart';
import 'parser/parser.dart';
import 'theme.dart';

class DartController extends TextEditingController {
  DartController({
    SyntaxTheme? theme,
  }) : super() {
    this.theme = theme ??= SyntaxTheme.dracula();
  }
  late SyntaxTheme theme;
  DartHighlighter? get highlighter =>
      parser == null ? null : DartHighlighter(parser!, this.theme, this);
  FlutterParser? parser;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) =>
      highlighter != null
          ? highlighter!.toTextSpan(
              context: context,
              style: style,
              withComposing: withComposing,
            )
          : super.buildTextSpan(context: context, withComposing: withComposing);

  @override
  set text(String newText) {
    super.text = newText;
    this.analyze(newText);
  }

  void analyze(String val) {
    final formatted = Formatter(val).format();
    parser = FlutterParser.fromString(formatted);
    super.notifyListeners();
  }
}

class DartHighlighter {
  DartHighlighter(this.parser, this.theme, this.controller);

  final FlutterParser parser;
  late SyntaxTheme theme;
  final DartController controller;

  TextSpan toTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ?? TextStyle();
    final spans = <CodeHighlight>[];

    final src = parser.code;
    final _scanner = StringScanner(src);
    int lastLoopPosition = _scanner.position;

    while (!_scanner.isDone) {
      /// Skip White space
      _scanner.scan(RegExp(r'\s+'));

      /// Block comments
      if (_scanner.scan(RegExp('/\\*+[^*]*\\*+(?:[^/*][^*]*\\*+)*/'))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.commentStyle,
        ));
        continue;
      }

      /// Line comments
      if (_scanner.scan('//')) {
        final int startComment = _scanner.lastMatch!.start;
        bool eof = false;
        int endComment;
        if (_scanner.scan(RegExp(r'.*'))) {
          endComment = _scanner.lastMatch!.end;
        } else {
          eof = true;
          endComment = src.length;
        }
        final start = startComment;
        final end = endComment;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.commentStyle,
        ));
        if (eof) break;
        continue;
      }

      /// Raw r"String"
      if (_scanner.scan(RegExp(r'r".*"'))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.stringStyle,
        ));
        continue;
      }

      /// Raw r'String'
      if (_scanner.scan(RegExp(r"r'.*'"))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.stringStyle,
        ));
        continue;
      }

      /// Multiline """String"""
      if (_scanner.scan(RegExp(r'"""(?:[^"\\]|\\(.|\n))*"""'))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.stringStyle,
        ));
        continue;
      }

      /// Multiline '''String'''
      if (_scanner.scan(RegExp(r"'''(?:[^'\\]|\\(.|\n))*'''"))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.stringStyle,
        ));
        continue;
      }

      /// "String"
      if (_scanner.scan(RegExp(r'"(?:[^"\\]|\\.)*"'))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.stringStyle,
        ));
        continue;
      }

      /// 'String'
      if (_scanner.scan(RegExp(r"'(?:[^'\\]|\\.)*'"))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.stringStyle,
        ));
        continue;
      }

      /// Double
      if (_scanner.scan(RegExp(r'\d+\.\d+'))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.numberStyle,
        ));
        continue;
      }

      /// Integer
      if (_scanner.scan(RegExp(r'\d+'))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.numberStyle,
        ));
        continue;
      }

      /// Punctuation
      if (_scanner.scan(RegExp(r'[\[\]{}().!=<>&\|\?\+\-\*/%\^~;:,]'))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.punctuationStyle,
        ));
        continue;
      }

      /// Meta data
      if (_scanner.scan(RegExp(r'@\w+'))) {
        final start = _scanner.lastMatch!.start;
        final end = _scanner.lastMatch!.end;
        spans.add(CodeHighlight(
          start,
          end,
          value: src.substring(start, end),
          style: theme.keywordStyle,
        ));
        continue;
      }

      /// Words
      if (_scanner.scan(RegExp(r'\w+'))) {
        final raw = _scanner.lastMatch![0]!;
        String word = raw;
        if (word.startsWith('_')) word = word.substring(1);
        if (Dart.tokens.contains(word)) {
          final start = _scanner.lastMatch!.start;
          final end = _scanner.lastMatch!.end;
          spans.add(CodeHighlight(
            start,
            end,
            value: src.substring(start, end),
            style: theme.keywordStyle,
          ));
        } else if (Dart.types.contains(word)) {
          final start = _scanner.lastMatch!.start;
          final end = _scanner.lastMatch!.end;
          spans.add(CodeHighlight(
            start,
            end,
            value: src.substring(start, end),
            style: theme.numberStyle,
          ));
        } else if (word.firstLetterIsUpperCase) {
          final start = _scanner.lastMatch!.start;
          final end = _scanner.lastMatch!.end;
          parser.visitor.classes.forEach((c) {
            if (c.name == raw) {
              spans.add(CodeHighlight(
                start,
                end,
                value: src.substring(start, end),
                style: theme.classStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    CodeSelection<String>(
                      value: () => c.name,
                      onChanged: (val) {
                        if (val.isEmpty) return;
                        final raw = this.controller.text;
                        this.controller.text = raw.split(c.name).join(val);
                      },
                    ).dispatch(context);
                  },
              ));
            } else {
              spans.add(CodeHighlight(
                start,
                end,
                value: src.substring(start, end),
                style: theme.classStyle,
              ));
            }
          });
        } else if (word.length >= 2 &&
            word.startsWith('k') &&
            word.substring(1).firstLetterIsUpperCase) {
          final start = _scanner.lastMatch!.start;
          final end = _scanner.lastMatch!.end;
          spans.add(CodeHighlight(
            start,
            end,
            value: src.substring(start, end),
            style: theme.constantStyle,
          ));
        } else {
          parser.visitor.classes.forEach((c) {
            c.fields.forEach((f) {
              f.variables.forEach((v) {
                if (v.name == raw) {
                  final start = _scanner.lastMatch!.start;
                  final end = _scanner.lastMatch!.end;
                  spans.add(CodeHighlight(
                    start,
                    end,
                    value: src.substring(start, end),
                    style: theme.baseStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        CodeSelection<String>(
                          value: () => v.name,
                          onChanged: (val) {
                            // v.name = val;
                            print('v.name, ${v.name}');
                          },
                        ).dispatch(context);
                      },
                  ));
                }
              });
            });
          });
        }
      }

      /// Check if this loop did anything
      if (lastLoopPosition == _scanner.position) {
        /// Failed to parse this file, abort gracefully
        return TextSpan(style: theme.baseStyle, text: src);
      }
      lastLoopPosition = _scanner.position;
    }

    final List<InlineSpan> formattedText = <InlineSpan>[];
    for (var i = 0; i <= src.length; i++) {
      final endOfFile = i == src.length;
      TextStyle _base = baseStyle;
      GestureRecognizer? recognizer;
      final _filtered = spans.where((e) => i >= e.start && i <= e.end);
      for (CodeHighlight span in _filtered) {
        _base = _base.merge(span.style);
        recognizer = span.recognizer ?? recognizer;
      }
      formattedText.add(TextSpan(
        style: _base,
        text: endOfFile ? ' ' : src[i],
        recognizer: recognizer,
      ));
    }
    return TextSpan(
      style: theme.baseStyle.merge(style),
      children: formattedText,
    );
  }
}

class Dart {
  static List<String> tokens = const [
    'abstract',
    'as',
    'late',
    'required',
    'override',
    'class',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'external',
    'extends',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'get',
    'if',
    'implements',
    'import',
    'in',
    'is',
    'library',
    'new',
    'null',
    'operator',
    'part',
    'rethrow',
    'return',
    'set',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
    'show'
  ];

  static List<String> types = const [
    'int',
    'num',
    'bool',
    'double',
    'String',
    'Map',
    'List',
    'Set',
  ];
}

extension StringUtils on String {
  bool get firstLetterIsUpperCase {
    if (this.isNotEmpty) {
      final String first = this.substring(0, 1);
      return first == first.toUpperCase();
    }
    return false;
  }
}

class CodeHighlight {
  CodeHighlight(
    this.start,
    this.end, {
    required this.value,
    required this.style,
    this.recognizer,
  });
  final TextStyle style;
  final int start, end;
  final String value;
  GestureRecognizer? recognizer;
}

class CodeSelection<T> extends Notification {
  CodeSelection({
    required this.value,
    required this.onChanged,
  });
  final ValueChanged<T> onChanged;
  final T Function() value;
}
