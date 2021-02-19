library flutter_ast;

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/ast/ast.dart';

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

  void renameVariable(String name, String value) {
    for (var ctx in visitor.classes) {
      for (final c in ctx.constructors) {
        for (final f in c.fields) {
          if (f.name == name) {
            f.name = value;
          }
        }
        for (final f in c.initializers) {
          if (f.name == name) {
            f.name = value;
          }
        }
      }
      for (final f in ctx.fields) {
        for (var v in f.variables) {
          if (v.name == name) {
            v.name = value;
          }
        }
      }
    }
  }

  void renameClass(String name, String value) {
    for (var ctx in visitor.classes) {
      if (ctx.name == name) {
        ctx.name = value;
      }
      for (final c in ctx.constructors) {
        if (c.name == name) {
          c.name = value;
        }
      }
    }
  }
}
