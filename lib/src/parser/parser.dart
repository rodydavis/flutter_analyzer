library flutter_ast;

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analyzer/src/analyzer.dart';

import 'utils.dart';

part 'visitors/class.dart';
part 'visitors/comment.dart';
part 'visitors/constructor.dart';
part 'visitors/enum.dart';
part 'visitors/expression.dart';
part 'visitors/field.dart';
part 'visitors/file.dart';
part 'visitors/import.dart';
part 'visitors/method.dart';
part 'visitors/mixin.dart';
part 'visitors/refactor.dart';
part 'visitors/types.dart';
part 'visitors/variable.dart';

class FlutterParser {
  FlutterParser.fromString(this.code) {
    this.result = parseString(
      content: this.code,
      featureSet: FeatureSet.latestLanguageVersion(),
      throwIfDiagnostics: false,
    );
    visitor = FileVisitor(this.result.unit, this);
  }

  final String code;
  late FileVisitor visitor;

  /// Dart Parse String Result
  late ParseStringResult result;

  /// Root AST Node
  AstNode get root => result.unit.root;

  /// List of any errors in the file
  List<AnalysisError> get errors => result.errors;

  String toSource() => result.unit.toSource();

  /// Information about lines in the content.
  LineInfo get lineInfo => this.result.lineInfo;

  /// Length of source code
  int get length => this.code.length;

  @override
  String toString() => this.code;

  void renameClass(String oldVal, String newVal) {
    _rename(RefactorVisitor.className(oldVal, newVal));
  }

  void renameEnum(String oldVal, String newVal) {
    _rename(RefactorVisitor.enumName(oldVal, newVal));
  }

  void renameEnumVal(String enumName, String oldVal, String newVal) {
    _rename(RefactorVisitor.enumValue(oldVal, newVal, enumName));
  }

  void renameVariable(String className, String oldVal, String newVal) {
    _rename(RefactorVisitor.variableName(oldVal, newVal, className));
  }

  void _rename(RefactorVisitor refactor) {
    this.root.visitChildren(refactor);
  }

  @visibleForTesting
  void debug() {
    // ignore: invalid_use_of_visible_for_testing_member
    // this.visitor.debug(this.code);
    print(this.toSource());
  }
}
