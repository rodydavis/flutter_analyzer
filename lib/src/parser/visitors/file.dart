import 'package:analyzer/dart/ast/ast.dart';

import '../parser.dart';
import '../utils.dart';
import 'class.dart';
import 'enum.dart';

class FileVisitor extends CodeVisitor {
  FileVisitor(this.root, this.parent) : super();

  final CompilationUnit root;
  final FlutterParser parent;
  final List<ClassVisitor> classes = [];
  final List<EnumVisitor> enums = [];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    classes.add(ClassVisitor(node, this));
    super.visitClassDeclaration(node);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    enums.add(EnumVisitor(node, this));
    super.visitEnumDeclaration(node);
  }
}
