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
  void debug(String code) {
    final Map<String, dynamic> output = this.toJson();
    output.prettyPrint();
    _explore(code, output);
  }

  _explore(String code, dynamic output) {
    if (output is Map) {
      final String n = output['name'];
      if (output.containsKey('length') && output.containsKey('offset')) {
        final int l = output['length'];
        final int o = output['offset'];
        print('$n [$o,$l] -> "${code.substring(o, o + (l))}"');
      }
      final p = output['params'];
      for (final item in p.values) {
        if (item is List) {
          for (final child in item) {
            _explore(code, child);
          }
        }
      }
      return;
    }
    print('-> ${output.runtimeType}');
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
