import 'dart:convert';

import 'package:_fe_analyzer_shared/src/scanner/token_impl.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
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
  void debug(String code) {
    final Map<String, dynamic> output = this.toJson();
    print(output.prettyPrint());
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
