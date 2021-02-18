import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/line_info.dart';

import 'utils.dart';
import 'visitors/file.dart';

class FlutterParser {
  FlutterParser.fromString(String source) {
    visitor = FileVisitor(this);
    this.code = source;
    this.result.unit.visitChildren(visitor);
  }

  late String _code;
  late FileVisitor visitor;

  void debug() {
    final Set<String> types = {};
    exploreChildren(types, this.result.unit);
    print(toSource());
    print(types);
  }

  /// Raw source code
  String get code => this._code;
  set code(String value) {
    this._code = value;
    this.result = parseString(
      content: value,
      featureSet: FeatureSet.latestLanguageVersion(),
      throwIfDiagnostics: false,
    );
  }

  /// Dart Parse String Result
  late ParseStringResult result;

  /// Root AST Node
  AstNode get root => result.unit.root;

  /// List of any errors in the file
  List<AnalysisError> get errors => result.errors;

  String toSource() => result.unit.toSource();

  /// Dart source code
  String save() => this.code = toSource();

  /// Information about lines in the content.
  LineInfo get lineInfo => this.result.lineInfo;

  /// Length of source code
  int get length => this.code.length;

  @override
  String toString() => this.code;
}
