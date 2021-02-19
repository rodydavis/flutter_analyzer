import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';
import 'method.dart';

class ExpressionVisitor extends ExpressionScope {
  ExpressionVisitor(this.root, this.parent) : super();

  final Expression root;
  final CodeVisitor parent;

  static ExpressionVisitor parse(Expression root, CodeVisitor parent) {
    if (root is NamedExpression) {
      return NamedExpressionVisitor(root, parent);
    }
    return ExpressionVisitor(root, parent);
  }

  @override
  String get visitorName => 'expression';
}

class NamedExpressionVisitor extends ExpressionVisitor {
  NamedExpressionVisitor(this.root, this.parent) : super(root, parent);

  final NamedExpression root;
  final CodeVisitor parent;

  String get label => root.name.label.toString();
  set label(String value) {
    root.name.label = value.toNode(root.name.label.offset);
  }

  dynamic get value => this.root.expression.toString();

  @override
  String get visitorName => 'named_expression';

  @override
  Map<String, dynamic> get params => {
        'methods': methods.map((e) => e.toJson()).toList(),
        'value': value,
        'label': label,
      };
}

abstract class ExpressionScope extends CodeVisitor {
  final List<MethodCallVisitor> methods = [];
  MethodCallVisitor? get topMethod => methods.length > 0 ? methods.first : null;
  MethodCallVisitor? get lastMethod => methods.length > 0 ? methods.last : null;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    methods.add(MethodCallVisitor(node, lastMethod ?? this));
    super.visitMethodInvocation(node);
  }

  @override
  Map<String, dynamic> get params => {
        'methods': methods.map((e) => e.toJson()).toList(),
      };
}
