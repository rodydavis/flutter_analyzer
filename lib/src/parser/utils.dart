import 'dart:convert';

import 'package:analyzer/dart/ast/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analyzer/src/analyzer.dart';
import 'package:_fe_analyzer_shared/src/scanner/token_impl.dart';
import 'package:flutter_analyzer/src/parser/parser.dart';

extension StringUtils on String {
  bool get isPrivate => this.startsWith('_');
  SimpleIdentifierImpl toNode(int offset) =>
      SimpleIdentifierImpl(this.toToken(offset));
  Token toToken(int offset) =>
      StringToken.fromString(TokenType.STRING, this, offset);
}

extension MapUtil on Map {
  String prettyPrint() {
    final JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyprint = encoder.convert(this);
    print(prettyprint);
    return prettyprint;
  }
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
    types.prettyPrint();
  }
}

exploreChildren(Map<String, dynamic> types, AstNode child) {
  final desc = child.toString().trim();
  final suffix =
      '(${(desc.length > 10 ? desc.substring(0, 10) : desc).trim()})';
  final key = child.runtimeType.toString() + suffix;
  types[key] = Map<String, dynamic>();
  for (final child in child.childEntities) {
    if (child is AstNode) exploreChildren(types[key], child);
  }
}
