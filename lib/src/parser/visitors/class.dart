import 'package:analyzer/dart/ast/ast.dart';

import '../parser.dart';
import '../utils.dart';
import 'comment.dart';
import 'field.dart';

class ClassVisitor extends CodeVisitor {
  ClassVisitor(this.root, this.parser) {
    this.root.visitChildren(this);
    if (root.documentationComment != null) {
      this.comment = CommentVisitor(root.documentationComment!, this.parser);
    }
  }
  final FlutterParser parser;
  final ClassDeclaration root;
  CommentVisitor? comment;

  String get name => root.name.toString();
  set name(String value) {
    root.name = textNode(value, root.name.offset);
  }

  bool get isPrivate => name.startsWith('_');
  final List<String> constructors = [];
  final List<FieldVisitor> fields = [];

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final String? constructorName = node.name?.toString();
    if (constructorName != null) {
      constructors.add("$name.$constructorName");
    } else {
      constructors.add("$name");
    }
    super.visitConstructorDeclaration(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    fields.add(FieldVisitor(node, this.parser));
    super.visitFieldDeclaration(node);
  }
}
