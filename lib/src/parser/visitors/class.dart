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
  bool get isAbstract => root.isAbstract;
  bool get isSynthetic => root.isSynthetic;

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

  @override
  String get visitorName => 'class_declaration';

  @override
  Map<String, dynamic> get params => {
        'name': name,
        'fields': fields.map((e) => e.toJson()).toList(),
        'constructors': constructors.map((e) => e.toJson()).toList(),
        'methods': methods.map((e) => e.toJson()).toList(),
        'withClause': withClause?.map((e) => e).toList(),
        'implementsClause': implementsClause?.map((e) => e).toList(),
        'isPrivate': isPrivate,
        'extendsClause': extendsClause,
        'isAbstract': isAbstract,
        'isSynthetic': isSynthetic,
      };
}

