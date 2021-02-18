import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';
import 'expression.dart';

class VariableVisitor extends CodeVisitor {
  VariableVisitor(this.root, this.parent) : super() {
    if (hasValue) expression = ExpressionVisitor.parse(root.initializer!, this);
  }
  final CodeVisitor parent;
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
    root.name = value.toNode(root.name.offset);
  }
}
