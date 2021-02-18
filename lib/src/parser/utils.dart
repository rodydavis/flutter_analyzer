import 'dart:convert';

import 'package:analyzer/dart/ast/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analyzer/src/analyzer.dart';
import 'package:_fe_analyzer_shared/src/scanner/token_impl.dart';
import 'package:flutter_analyzer/src/parser/parser.dart';

SimpleIdentifierImpl textNode(String value, int offset) {
  final stringToken = StringToken.fromString(
    TokenType.STRING,
    value,
    offset,
  );
  return SimpleIdentifierImpl(stringToken);
}

extension StringUtils on String {
  bool get isPrivate => this.startsWith('_');
  SimpleIdentifierImpl toNode(int offset) => textNode(this, offset);
  Token toToken(int offset) =>
      StringToken.fromString(TokenType.STRING, this, offset);
}

@mustCallSuper
abstract class CodeVisitor extends RecursiveAstVisitor<void> {
  CodeVisitor() {
    this.root.visitChildren(this);
  }
  AstNode get root;

  @visibleForTesting
  void debug() {
    final Map<String, dynamic> types = {};
    exploreChildren(types, this.root);
    final JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyprint = encoder.convert(types);
    print(prettyprint);
  }
}

exploreChildren(Map<String, dynamic> types, AstNode child) {
  final key = child.runtimeType.toString();
  types[key] = Map<String, dynamic>();
  for (final child in child.childEntities) {
    if (child is AstNode) exploreChildren(types[key], child);
  }
}
