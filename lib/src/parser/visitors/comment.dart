import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';

class CommentVisitor extends CodeVisitor {
  CommentVisitor(this.root, this.parent) {
    this.root.visitChildren(this);
    for (final token in this.root.tokens) {
      final String value = token.value().toString().trimLeft();
      if (value.startsWith('/// ')) {
        this.lines.add(value.replaceFirst('///', '').trim());
      } else if (value.startsWith('/**')) {
        for (final line in value.split('\n')) {
          final trimmedLine = line.trimLeft();
          if (trimmedLine.startsWith('*/')) continue;
          if (trimmedLine.startsWith('*')) {
            this.lines.add(trimmedLine.replaceFirst('*', '').trim());
          }
        }
      }
    }
  }

  final CodeVisitor parent;
  final Comment root;
  final List<String> lines = [];
  String get content => lines.join('\n');
  String get raw => lines.join(' ');
  bool get isBlock => root.isBlock;
  bool get isDocumentation => root.isDocumentation;
  bool get isEndOfLine => root.isEndOfLine;
  bool get isSynthetic => root.isSynthetic;
  NodeList<CommentReference> get references => root.references;
}
