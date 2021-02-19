part of flutter_ast;

class ExpressionVisitor extends ExpressionScope {
  ExpressionVisitor(this.root, this.parent) : super();

  final Expression root;
  final CodeVisitor parent;

  static ExpressionVisitor parse(Expression root, CodeVisitor parent) {
    if (root is LiteralImpl) {
      if (root is IntegerLiteralImpl) {
        return IntVisitor(root, parent);
      }
      if (root is BooleanLiteralImpl) {
        return BoolVisitor(root, parent);
      }
      if (root is DoubleLiteralImpl) {
        return DoubleVisitor(root, parent);
      }
      if (root is SimpleStringLiteralImpl) {
        return StringVisitor(root, parent);
      }
      return DynamicVisitor(root, parent);
    }
    if (root is MethodInvocationImpl) {
      return MethodInvocationVisitor(root, parent);
    }
    if (root is InstanceCreationExpressionImpl) {
      return InstanceCreationExpressionVisitor(root, parent);
    }
    if (root is PrefixedIdentifierImpl) {
      return PrefixedVisitor(root, parent);
    }
    if (root is SimpleIdentifierImpl) {
      return SimpleVisitor(root, parent);
    }
    if (root is NamedExpressionImpl) {
      return NamedExpressionVisitor(root, parent);
    }
    return ExpressionVisitor(root, parent);
  }

  @override
  String get visitorName => 'expression';
}

class NamedExpressionVisitor extends ExpressionVisitor {
  NamedExpressionVisitor(this.root, this.parent) : super(root, parent) {
    this.expression = ExpressionVisitor.parse(root.expression, this);
  }

  final NamedExpression root;
  final CodeVisitor parent;

  String get label => root.name.label.toString();
  set label(String value) {
    root.name.label = value.toNode(root.name.label.offset);
  }

  late ExpressionVisitor expression;

  @override
  String get visitorName => 'named_expression';

  @override
  Map<String, dynamic> get params => {
        'methods': methods.map((e) => e.toJson()).toList(),
        'value': expression.toJson(),
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
