import 'package:analyzer/dart/ast/ast.dart';

import '../../analyzer.dart';
import '../utils.dart';
import 'expression.dart';

class DoubleVisitor extends LiteralVisitor<double> {
  DoubleVisitor(this.root, this.parent) : super(root, parent);

  @override
  final CodeVisitor parent;

  @override
  final DoubleLiteralImpl root;

  @override
  double get value => root.value;
  set value(double val) {
    root.value = val;
  }
}

class BoolVisitor extends LiteralVisitor<bool> {
  BoolVisitor(this.root, this.parent) : super(root, parent);

  @override
  final CodeVisitor parent;

  @override
  final BooleanLiteralImpl root;

  @override
  bool get value => root.value;
  set value(bool val) {
    root.value = val;
  }
}

class IntVisitor extends LiteralVisitor<int?> {
  IntVisitor(this.root, this.parent) : super(root, parent);

  @override
  final CodeVisitor parent;

  @override
  final IntegerLiteralImpl root;

  @override
  int? get value => root.value;
  set value(int? val) {
    root.value = val;
  }
}

class StringVisitor extends LiteralVisitor<String> {
  StringVisitor(this.root, this.parent) : super(root, parent);

  @override
  final CodeVisitor parent;

  @override
  final SimpleStringLiteralImpl root;

  @override
  String get value => root.value;
  set value(String val) {
    root.value = val;
  }
}

class DynamicVisitor extends LiteralVisitor<dynamic> {
  DynamicVisitor(this.root, this.parent) : super(root, parent);

  @override
  final CodeVisitor parent;

  @override
  final LiteralImpl root;

  @override
  dynamic get value => null;
  set value(dynamic val) {}
}

class SimpleVisitor extends LiteralVisitor<String> {
  SimpleVisitor(this.root, this.parent) : super(root, parent);

  @override
  final CodeVisitor parent;

  @override
  final SimpleIdentifierImpl root;

  @override
  String get value => root.name;
  set value(String val) {
    root.token = val.toToken(root.offset);
  }
}

class PrefixedVisitor extends LiteralVisitor<String> {
  PrefixedVisitor(this.root, this.parent) : super(root, parent);

  @override
  final CodeVisitor parent;

  @override
  final PrefixedIdentifierImpl root;

  @override
  String get value => root.identifier.toString();
  set value(String val) {
    root.identifier.token = val.toToken(root.offset);
  }

  String get prefix => root.prefix.toString();
  set prefix(String val) {
    root.prefix.token = val.toToken(root.offset);
  }

  @override
  Map<String, dynamic> get params => {
        'prefix': prefix,
        'value': value,
      };
}

class MethodInvocationVisitor extends LiteralVisitor<String> {
  MethodInvocationVisitor(this.root, this.parent) : super(root, parent) {
    for (final child in root.argumentList.arguments) {
      arguments.add(ExpressionVisitor.parse(child, parent));
    }
  }

  final List<ExpressionVisitor> arguments = [];

  @override
  final CodeVisitor parent;

  @override
  final MethodInvocationImpl root;

  @override
  String get value => root.methodName.toString();
  set value(String val) {
    root.methodName.token = val.toToken(root.offset);
  }

  @override
  Map<String, dynamic> get params => {
        'name': value,
        'arguments': arguments.map((e) => e.toJson()).toList(),
      };
}

abstract class LiteralVisitor<T> extends ValueVisitor {
  LiteralVisitor(Expression root, CodeVisitor parent) : super(root, parent);

  T get value;

  set value(T val);

  @override
  Map<String, dynamic> get params => {
        'value': value,
      };

  @override
  String get visitorName => '$T'.toLowerCase();
}

abstract class ValueVisitor extends ExpressionVisitor {
  ValueVisitor(Expression root, CodeVisitor parent) : super(root, parent);
}
