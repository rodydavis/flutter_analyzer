import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';

class ExpressionVisitor extends CodeVisitor {
  ExpressionVisitor(this.root, this.parent) {
    this.root.visitChildren(this);
  }
  final Expression root;
  final CodeVisitor parent;
}
