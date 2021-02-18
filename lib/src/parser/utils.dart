import 'package:analyzer/dart/ast/token.dart';
import 'package:flutter_analyzer/src/analyzer.dart';
import 'package:_fe_analyzer_shared/src/scanner/token_impl.dart';

SimpleIdentifierImpl textNode(String value, int offset) {
  final stringToken = StringToken.fromString(
    TokenType.STRING,
    value,
    offset,
  );
  return SimpleIdentifierImpl(stringToken);
}

exploreChildren(Set<String> types, AstNode child) {
  types.add(child.runtimeType.toString());
  for (final child in child.childEntities) {
    if (child is AstNode) exploreChildren(types, child);
  }
}

extension StringUtils on String {
  bool get isPrivate => this.startsWith('_');
  SimpleIdentifierImpl toNode(int offset) => textNode(this, offset);
}

class CodeVisitor extends RecursiveAstVisitor<void> {}
