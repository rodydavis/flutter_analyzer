import 'package:analyzer/dart/ast/ast.dart';

import '../parser.dart';
import '../utils.dart';
import 'class.dart';

class ConstructorVisitor extends CodeVisitor {
  ConstructorVisitor(this.root, this.parent) {
    this.root.visitChildren(this);
  }
  final ConstructorDeclaration root;
  final ClassVisitor parent;

  bool get hasName => name != null;
  
  String? get name => root.name?.toString();
  set name(String? value) {
    if (value == null) {
      throw 'Cannot rename default constructor';
    }
    root.name = textNode(value, root.name!.offset);
  }

  String get displayName {
    if (!hasName) return parent.name;
    return "${parent.name}.$name";
  }
}
