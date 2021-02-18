import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';
import 'file.dart';

class EnumVisitor extends CodeVisitor {
  EnumVisitor(this.root, this.parent) : super();

  final FileVisitor parent;
  final EnumDeclaration root;

  String get name => root.name.toString();
  set name(String value) {
    root.name = textNode(value, root.name.offset);
  }

  final List<EnumValueVisitor> values = [];

  @override
  void visitEnumConstantDeclaration(EnumConstantDeclaration node) {
    values.add(EnumValueVisitor(node, this));
    super.visitEnumConstantDeclaration(node);
  }
}

class EnumValueVisitor extends CodeVisitor {
  EnumValueVisitor(this.root, this.parent) : super();

  String get name => root.name.toString();
  set name(String value) {
    root.name = textNode(value, root.name.offset);
  }

  final EnumVisitor parent;
  final EnumConstantDeclaration root;
}
