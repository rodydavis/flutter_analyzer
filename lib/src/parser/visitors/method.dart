import 'package:analyzer/dart/ast/ast.dart';

import '../../analyzer.dart';
import '../utils.dart';
import 'class.dart';
import 'expression.dart';
import 'file.dart';

class FunctionBodyVisitor extends ExpressionScope {
  FunctionBodyVisitor(this.root, this.parent) : super();

  // static Map<String, dynamic> toTree(MethodCallVisitor? top) {
  //   final base = <String, dynamic>{};
  //   if (top != null) {
  //     base['name'] = top.name;
  //     base['params'] = {};
  //     for (final arg in top.arguments) {
  //       if (arg is NamedExpressionVisitor) {
  //         if (arg.root.expression is LiteralImpl) {
  //           base['params'][arg.label] = arg.value;
  //         } else {
  //           base['params'][arg.label] = toTree(arg.topMethod);
  //         }
  //       }
  //     }
  //   }
  //   return base;
  // }

  final CodeVisitor parent;
  final FunctionBody root;

  bool get isAsynchronous => this.root.isAsynchronous;
  bool get isGenerator => this.root.isGenerator;
  bool get isSynchronous => this.root.isSynchronous;
  bool get isSynthetic => this.root.isSynthetic;

  @override
  String get visitorName => 'method_body';

  @override
  dynamic toJson() {
    return {
      'name': visitorName,
      'params': {
        'isAsynchronous': isAsynchronous,
        'isGenerator': isGenerator,
        'isSynchronous': isSynchronous,
        'isSynthetic': isSynthetic,
        'body': this.topMethod?.toJson(),
      },
    };
  }
}

class MethodVisitor extends ExpressionScope {
  MethodVisitor(this.root, this.parent) : super() {
    body = FunctionBodyVisitor(this.root.body, this);
  }

  final ClassVisitor parent;
  final MethodDeclaration root;
  late FunctionBodyVisitor body;

  bool get isGetter => root.isGetter;
  bool get isSetter => root.isSetter;
  bool get isOperator => root.isOperator;
  bool get isStatic => root.isStatic;
  bool get isSynthetic => root.isSynthetic;
  bool get isAbstract => root.isAbstract;

  String get name => root.name.toString();
  set name(String value) {
    root.name = value.toNode(root.name.offset);
  }

  @override
  String get visitorName => 'method_declaration';

  @override
  dynamic toJson() {
    return {
      'name': visitorName,
      'params': {
        'isGetter': isGetter,
        'isSetter': isSetter,
        'isOperator': isOperator,
        'isStatic': isStatic,
        'isSynthetic': isSynthetic,
        'isAbstract': isAbstract,
        'name': name,
        'body': body.toJson(),
      },
    };
  }
}

class FunctionVisitor extends ExpressionScope {
  FunctionVisitor(this.root, this.parent) : super();

  final FileVisitor parent;
  final FunctionDeclaration root;

  bool get isGetter => root.isGetter;
  bool get isSetter => root.isSetter;
  bool get isSynthetic => root.isSynthetic;

  String get name => root.name.toString();
  set name(String value) {
    root.name = value.toNode(root.name.offset);
  }

  @override
  String get visitorName => 'method_function';

  @override
  dynamic toJson() {
    return {
      'name': visitorName,
      'params': {
        'isGetter': isGetter,
        'isSetter': isSetter,
        'isSynthetic': isSynthetic,
        'name': name,
      },
    };
  }
}

class MethodCallVisitor extends ExpressionScope {
  MethodCallVisitor(this.root, this.parent) : super() {
    for (var e in this.root.argumentList.arguments) {
      arguments.add(ExpressionVisitor.parse(e, this));
    }
  }

  final CodeVisitor parent;
  final MethodInvocation root;
  final List<ExpressionVisitor> arguments = [];

  String get name => root.methodName.toString();
  set name(String value) {
    root.methodName = value.toNode(root.methodName.offset);
  }

  bool get isCascaded => root.isCascaded;
  bool get isNullAware => root.isNullAware;
  bool get isAssignable => root.isAssignable;
  bool get isSynthetic => root.isSynthetic;

  @override
  String get visitorName => 'method_invocation';

  @override
  dynamic toJson() {
    return {
      'name': visitorName,
      'params': {
        'isCascaded': isCascaded,
        'isNullAware': isNullAware,
        'isAssignable': isAssignable,
        'isSynthetic': isSynthetic,
        'name': name,
        'arguments': arguments.map((e) => e.toJson()).toList(),
      },
    };
  }
}
