import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_analyzer/src/analyzer.dart';

import '../utils.dart';

class ImportVisitor extends CodeVisitor {
  ImportVisitor(this.root, this.parent) : super();

  final ImportDirective root;
  final CodeVisitor parent;

  bool get deferred => root.deferredKeyword != null;

  String get url => this.root.uriContent ?? this.root.uri.stringValue ?? '';

  String? get prefix => this.root.prefix?.toString();
  set prefix(String? value) {
    if (value == null) {
      this.root.prefix = null;
    } else {
      this.root.prefix = value.toNode(this.root.prefix?.offset ?? 0);
    }
  }

  @override
  String get visitorName => 'import';

  @override
  Map<String, dynamic> get params => {
        'url': url,
        'prefix': prefix,
        'deferred': deferred,
      };
}
