import 'dart:convert';

import 'package:_fe_analyzer_shared/src/scanner/token_impl.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:flutter/material.dart';

import '../analyzer.dart';

extension StringUtils on String {
  bool get isPrivate => this.startsWith('_');
  SimpleIdentifierImpl toNode(int offset) =>
      SimpleIdentifierImpl(this.toToken(offset));
  Token toToken(int offset) =>
      StringToken.fromString(TokenType.STRING, this, offset);
}

extension on Object {
  String prettyPrint() {
    final JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyprint = encoder.convert(this);
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
    final Map<String, dynamic> output = this.toJson();
    output.prettyPrint();
  }

  String get visitorName;

  Map<String, dynamic> get params;

  dynamic toJson() {
    return {
      'name': visitorName,
      'type': root.runtimeType.toString(),
      'offset': root.offset,
      'length': root.length,
      'params': params,
    };
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
