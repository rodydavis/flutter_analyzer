import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:flutter_analyzer/src/analyzer.dart';
import 'package:_fe_analyzer_shared/src/scanner/token_impl.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dart_style/src/source_visitor.dart';

class FlutterParser {
  FlutterParser.fromString(String source)
      : this.result = parseString(
          content: source,
          featureSet: FeatureSet.latestLanguageVersion(),
          throwIfDiagnostics: false,
        ) {
    this.result.unit.visitChildren(visitor);
  }

  /// Dart Parse String Result
  final ParseStringResult result;
  final formatter = DartFormatter();
  final visitor = FileVisitor();

  /// Root AST Node
  AstNode get root => result.unit.root;

  /// List of any errors in the file
  List<AnalysisError> get errors => result.errors;

  /// Dart source code
  String get source => result.unit.toSource();

  /// Formatted source code
  String get formatted => formatter.format(source);

  /// Information about lines in the content.
  LineInfo get lineInfo => this.result.lineInfo;

  void debug() {
    // print("Source: ${this.source}");
    for (final classItem in visitor.classes) {
      print('class ${classItem.comment?.raw} -> ${classItem.name}');
      for (final fieldItem in classItem.fields) {
        for (final fieldVar in fieldItem.variables) {
          print(
              '    field ${fieldItem.comment?.raw} -> ${fieldItem.typeName} ${fieldVar.name}');
        }
      }
    }
  }
}

class FileVisitor extends RecursiveAstVisitor<void> {
  final List<ClassVisitor> classes = [];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    classes.add(ClassVisitor(node));
    super.visitClassDeclaration(node);
  }
}

class CommentVisitor extends RecursiveAstVisitor<void> {
  CommentVisitor(this.root) {
    this.root.visitChildren(this);
    for (final token in this.root.tokens) {
      final String value = token.value().toString().trimLeft();
      if (value.startsWith('/// ')) {
        this.lines.add(value.replaceFirst('///', '').trim());
      } else if (value.startsWith('/**')) {
        for (final line in value.split('\n')) {
          final trimmedLine = line.trimLeft();
          if (trimmedLine.startsWith('*/')) continue;
          if (trimmedLine.startsWith('*')) {
            this.lines.add(trimmedLine.replaceFirst('*', '').trim());
          }
        }
      }
    }
  }

  final Comment root;
  final List<String> lines = [];
  String get content => lines.join('\n');
  String get raw => lines.join(' ');
  bool get isBlock => root.isBlock;
  bool get isDocumentation => root.isDocumentation;
  bool get isEndOfLine => root.isEndOfLine;
  bool get isSynthetic => root.isSynthetic;
  NodeList<CommentReference> get references => root.references;
}

class ClassVisitor extends RecursiveAstVisitor<void> {
  ClassVisitor(this.root) {
    this.root.visitChildren(this);
    if (root.documentationComment != null) {
      this.comment = CommentVisitor(root.documentationComment!);
    }
  }
  final ClassDeclaration root;
  CommentVisitor? comment;
  int get offset => root.offset;
  String get name => root.name.toString();
  bool get isPrivate => name.startsWith('_');
  final List<String> constructors = [];
  final List<FieldVisitor> fields = [];

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final String? constructorName = node.name?.toString();
    if (constructorName != null) {
      constructors.add("$name.$constructorName");
    } else {
      constructors.add("$name");
    }
    super.visitConstructorDeclaration(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    fields.add(FieldVisitor(node));
    super.visitFieldDeclaration(node);
  }
}

class FieldVisitor extends RecursiveAstVisitor<void> {
  FieldVisitor(this.root) {
    this.root.visitChildren(this);
    if (root.documentationComment != null) {
      this.comment = CommentVisitor(root.documentationComment!);
    }
  }
  final FieldDeclaration root;
  CommentVisitor? comment;
  bool get isStatic => root.isStatic;
  String get type =>
      root.fields.type?.type?.toString() ??
      root.fields.type?.toString().replaceAll('?', '') ??
      'dynamic';
  String get typeName => isOptional ? '$type?' : '$type';
  bool get isOptional => root.fields.type?.question != null;
  List<VariableVisitor> get variables =>
      root.fields.variables.map((e) => VariableVisitor(e)).toList();
}

class VariableVisitor extends RecursiveAstVisitor<void> {
  ExpressionVisitor? expression;
  VariableVisitor(this.root) {
    this.root.visitChildren(this);
    if (hasValue) expression = ExpressionVisitor(root.initializer!);
  }
  final VariableDeclaration root;
  bool get isLate => root.isLate;
  bool get isFinal => root.isFinal;
  bool get isConst => root.isConst;
  bool get isSynthetic => root.isSynthetic;
  bool get isPrivate => name.startsWith('_');
  bool get hasValue => root.equals != null && root.initializer != null;
  String get name => root.name.toString();
  set name(String value) {
    final stringToken =
        StringToken.fromString(TokenType.STRING, value, root.name.offset);
    root.name = SimpleIdentifierImpl(stringToken);
  }

  @override
  String toString() {
    return '$name -> isLate:$isLate,isFinal:$isFinal,isConst:$isConst,isPrivate:$isPrivate,hasValue:$hasValue';
  }
}

class ExpressionVisitor extends RecursiveAstVisitor<void> {
  ExpressionVisitor(this.root) {
    this.root.visitChildren(this);
  }
  final Expression root;
}
