import 'package:analyzer/dart/ast/ast.dart';

import '../parser.dart';
import '../utils.dart';

class ExpressionVisitor extends CodeVisitor {
  ExpressionVisitor(this.root, this.parser) {
    this.root.visitChildren(this);
  }
  final Expression root;
  final FlutterParser parser;
}
