import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_analyzer/src/parser/visitors/variable.dart';

import '../parser.dart';
import '../utils.dart';

import 'class.dart';
import 'enum.dart';
import 'import.dart';
import 'method.dart';
import 'mixin.dart';

export 'class.dart';
export 'enum.dart';
export 'method.dart';
export 'import.dart';
export 'mixin.dart';

class FileVisitor extends CodeVisitor {
  FileVisitor(this.root, this.parent) : super();

  final CompilationUnit root;
  final FlutterParser parent;

  final List<ClassVisitor> classes = [];
  final List<MixinVisitor> mixins = [];
  final List<EnumVisitor> enums = [];
  final List<ImportVisitor> imports = [];
  final List<VariableVisitor> fields = [];
  final List<FunctionVisitor> functions = [];

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

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    mixins.add(MixinVisitor(node, this));
    super.visitMixinDeclaration(node);
  }

  @override
  void visitImportDirective(ImportDirective node) {
    imports.add(ImportVisitor(node, this));
    super.visitImportDirective(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    functions.add(FunctionVisitor(node, this));
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final item in node.variables.variables) {
      fields.add(VariableVisitor(item, this));
    }
    super.visitTopLevelVariableDeclaration(node);
  }

  @override
  String get visitorName => 'compilation_unit';

  @override
  dynamic toJson() {
    return {
      'name': visitorName,
      'params': {
        'classes': classes.map((e) => e.toJson()).toList(),
        'mixins': mixins.map((e) => e.toJson()).toList(),
        'enums': enums.map((e) => e.toJson()).toList(),
        'imports': imports.map((e) => e).toList(),
        'fields': fields.map((e) => e).toList(),
        'functions': functions,
      }
    };
  }
}

extension FileVisitorUtil on FileVisitor {
  void renameEnum(String name, String value) {
    for (final e in this.enums) {
      if (e.name == name) {
        e.name = value;
      }
    }
    for (final c in this.classes) {
      for (final f in c.fields) {
        if (f.type == name) {
          // TODO: Rename fields
          // f.type = value;
        }
      }
      for (var i in c.constructors) {
        for (var f in i.fields) {
          // TODO: Rename fields
          // f.type = value;
        }
      }
    }
  }
}
