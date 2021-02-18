import 'package:analyzer/dart/ast/ast.dart';

import '../parser.dart';
import '../utils.dart';
import 'comment.dart';
import 'constructor.dart';
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
  
  final List<FieldVisitor> fields = [];
  bool get hasFields => fields.isNotEmpty;

  final List<ConstructorVisitor> constructors = [];
  bool get hasConstructor => constructors.isNotEmpty;

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    constructors.add(ConstructorVisitor(node, this));
    super.visitConstructorDeclaration(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    fields.add(FieldVisitor(node, this.parser));
    super.visitFieldDeclaration(node);
  }
}
