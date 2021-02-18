import 'package:analyzer/dart/ast/ast.dart';

import '../parser.dart';
import '../utils.dart';
import 'comment.dart';
import 'variable.dart';

class FieldVisitor extends CodeVisitor {
  FieldVisitor(this.root, this.parser) {
    this.root.visitChildren(this);
    if (root.documentationComment != null) {
      this.comment = CommentVisitor(root.documentationComment!, this.parser);
    }
  }
  final FlutterParser parser;
  final FieldDeclaration root;
  CommentVisitor? comment;

  bool get isStatic => root.isStatic;

  String get type =>
      root.fields.type?.type?.toString() ??
      root.fields.type?.toString().replaceAll('?', '') ??
      'dynamic';

  String get typeName => isOptional ? '$type?' : '$type';

  bool get isOptional => root.fields.type?.question != null;

  List<VariableVisitor> get variables => root.fields.variables
      .map((e) => VariableVisitor(e, this.parser))
      .toList();
}
