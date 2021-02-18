import 'package:analyzer/dart/ast/ast.dart';

import '../parser.dart';
import '../utils.dart';
import 'class.dart';

class FileVisitor extends CodeVisitor {
  FileVisitor(this.parser);

  final FlutterParser parser;
  final List<ClassVisitor> classes = [];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    classes.add(ClassVisitor(node, this.parser));
    super.visitClassDeclaration(node);
  }
}
