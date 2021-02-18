import 'package:analyzer/dart/ast/ast.dart';

import '../parser.dart';
import '../utils.dart';
import 'class.dart';

class FileVisitor extends CodeVisitor {
  FileVisitor(this.parent);

  final FlutterParser parent;
  final List<ClassVisitor> classes = [];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    classes.add(ClassVisitor(node, this));
    super.visitClassDeclaration(node);
  }
}
