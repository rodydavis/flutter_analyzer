import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_analyzer/src/parser/visitors/file.dart';

import '../utils.dart';
import 'class.dart';

class MethodVisitor extends CodeVisitor {
  MethodVisitor(this.root, this.parent) : super();

  final ClassVisitor parent;
  final MethodDeclaration root;

  bool get isGetter => root.isGetter;
  bool get isSetter => root.isSetter;
  bool get isOperator => root.isOperator;
  bool get isStatic => root.isStatic;
  bool get isSynthetic => root.isSynthetic;
  bool get isAbstract => root.isAbstract;

  String get name => root.name.toString();
  set name(String value) {
    root.name = value.toNode(root.name.offset);
  }
}

class FunctionVisitor extends CodeVisitor {
  FunctionVisitor(this.root, this.parent) : super();

  final FileVisitor parent;
  final FunctionDeclaration root;

  bool get isGetter => root.isGetter;
  bool get isSetter => root.isSetter;
  bool get isSynthetic => root.isSynthetic;

  String get name => root.name.toString();
  set name(String value) {
    root.name = value.toNode(root.name.offset);
  }
}
