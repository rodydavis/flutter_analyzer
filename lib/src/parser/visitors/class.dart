import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';
import 'comment.dart';
import 'constructor.dart';
import 'field.dart';
import 'file.dart';
import 'method.dart';

class ClassVisitor extends CodeVisitor {
  ClassVisitor(this.root, this.parent) : super() {
    if (root.documentationComment != null) {
      this.comment = CommentVisitor(root.documentationComment!, this);
    }
  }

  final FileVisitor parent;
  final ClassDeclaration root;

  CommentVisitor? comment;

  String get name => root.name.toString();
  set name(String value) {
    root.name = value.toNode(root.name.offset);
  }

  String? get extendsClause => root.extendsClause?.superclass.toString();
  List<String>? get withClause =>
      root.withClause?.mixinTypes.map((e) => e.toString()).toList();
  List<String>? get implementsClause =>
      root.implementsClause?.interfaces.map((e) => e.toString()).toList();

  bool get isPrivate => name.startsWith('_');

  final List<FieldVisitor> fields = [];
  final List<ConstructorVisitor> constructors = [];
  final List<MethodVisitor> methods = [];

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    constructors.add(ConstructorVisitor(node, this));
    super.visitConstructorDeclaration(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    fields.add(FieldVisitor(node, this));
    super.visitFieldDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    methods.add(MethodVisitor(node, this));
    super.visitMethodDeclaration(node);
  }

  void renameVariable(String name, String value) {
    for (final c in this.constructors) {
      for (final f in c.fields) {
        if (f.name == name) {
          f.name = value;
        }
      }
      for (final f in c.initializers) {
        if (f.name == name) {
          f.name = value;
        }
      }
    }
    for (final f in this.fields) {
      for (var v in f.variables) {
        if (v.name == name) {
          v.name = value;
        }
      }
    }
  }
}
