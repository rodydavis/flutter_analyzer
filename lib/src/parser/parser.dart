import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/line_info.dart';

import 'visitors/file.dart';

export 'visitors/file.dart';

class FlutterParser {
  FlutterParser.fromString(this.code) {
    this.result = parseString(
      content: this.code,
      featureSet: FeatureSet.latestLanguageVersion(),
      throwIfDiagnostics: false,
    );
    visitor = FileVisitor(this.result.unit, this);
    final Map<String, dynamic> output = this.visitor.toJson();
    _explore(output);
  }

  _explore(Map<String, dynamic> output) {
    final String n = output['name'];
    final int l = output['length'];
    final int o = output['offset'];
    print('$n [$o,$l] -> "${code.substring(o, o + (l - 1))}"');
    final p = output['params'];
    for (final key in p.keys) {
      if (key is Map) {
        _explore(p[key]);
      } else {
        // print(param);
      }
    }
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
}
