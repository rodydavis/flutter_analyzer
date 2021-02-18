import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';

class ImportVisitor extends CodeVisitor {
  ImportVisitor(this.root, this.parent) : super();

  final ImportDirective root;
  final CodeVisitor parent;
}
