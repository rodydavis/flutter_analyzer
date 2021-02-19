import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_analyzer/src/parser/visitors/class.dart';

import '../utils.dart';
import 'comment.dart';
import 'variable.dart';

class FieldVisitor extends CodeVisitor {
  FieldVisitor(this.root, this.parent) : super() {
    if (root.documentationComment != null) {
      this.comment = CommentVisitor(root.documentationComment!, this);
    }
  }
  final ClassVisitor parent;
  final FieldDeclaration root;
  CommentVisitor? comment;

  bool get isStatic => root.isStatic;

  String get type =>
      root.fields.type?.type?.toString() ??
      root.fields.type?.toString().replaceAll('?', '') ??
      'dynamic';

  String get typeName => isOptional ? '$type?' : '$type';

  bool get isOptional => root.fields.type?.question != null;

  List<VariableVisitor> get variables =>
      root.fields.variables.map((e) => VariableVisitor(e, this)).toList();

  @override
  String get visitorName => 'field';

  @override
  Map<String, dynamic> get params => {
        'isOptional': isOptional,
        'isStatic': isStatic,
        'type': type,
        'typeName': typeName,
        'variables': variables.map((e) => e.toJson()).toList(),
      };
}
