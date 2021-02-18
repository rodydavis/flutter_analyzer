import 'package:analyzer/dart/ast/ast.dart';

import '../parser.dart';
import '../utils.dart';
import 'expression.dart';

class VariableVisitor extends CodeVisitor {
  ExpressionVisitor? expression;
  VariableVisitor(this.root, this.parser) {
    this.root.visitChildren(this);
    if (hasValue)
      expression = ExpressionVisitor(root.initializer!, this.parser);
  }
  final FlutterParser parser;
  final VariableDeclaration root;
  bool get isLate => root.isLate;
  bool get isFinal => root.isFinal;
  bool get isConst => root.isConst;
  bool get isSynthetic => root.isSynthetic;
  bool get isPrivate => name.startsWith('_');
  bool get hasValue => root.equals != null && root.initializer != null;

  String get name => root.name.toString();
  set name(String value) {
    root.name = textNode(value, root.name.offset);
  }

  @override
  String toString() {
    return '$name -> isLate:$isLate,isFinal:$isFinal,isConst:$isConst,isPrivate:$isPrivate,hasValue:$hasValue';
  }
}
