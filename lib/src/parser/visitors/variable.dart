import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';
import 'expression.dart';
import 'field.dart';

class VariableVisitor extends CodeVisitor {
  VariableVisitor(this.root, this.parent) : super() {
    if (hasValue) expression = ExpressionVisitor(root.initializer!, this);
  }
  final FieldVisitor parent;
  final VariableDeclaration root;
  bool get isLate => root.isLate;
  bool get isFinal => root.isFinal;
  bool get isConst => root.isConst;
  bool get isSynthetic => root.isSynthetic;
  bool get isPrivate => name.startsWith('_');

  ExpressionVisitor? expression;
  bool get hasValue => root.equals != null && root.initializer != null;

  String get name => root.name.toString();
  set name(String value) {
    for (final c in parent.parent.constructors) {
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
    root.name = textNode(value, root.name.offset);
  }
}
