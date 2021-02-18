import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';
import 'class.dart';
import 'expression.dart';

class ConstructorVisitor extends CodeVisitor {
  ConstructorVisitor(this.root, this.parent) : super();

  final ConstructorDeclaration root;
  final ClassVisitor parent;

  bool get hasName => name != null;

  String? get name => root.name?.toString();
  set name(String? value) {
    if (name == null) {
      throw 'Cannot rename default constructor';
    }
    if (value == null) {
      throw 'Cannot create default constructor';
    }
    root.name = textNode(value, root.name!.offset);
  }

  String get displayName {
    if (!hasName) return parent.name;
    return "${parent.name}.$name";
  }

  final List<ConstructorFieldVisitor> fields = [];
  final List<ConstructorFieldInitializerVisitor> initializers = [];
  int position = 0;

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    fields.add(FieldFormalParameterVisitor(node, this, position));
    position++;
    super.visitFieldFormalParameter(node);
  }

  @override
  void visitDefaultFormalParameter(DefaultFormalParameter node) {
    fields.add(DefaultFormalParameterVisitor(node, this));
    super.visitDefaultFormalParameter(node);
  }

  @override
  void visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    initializers.add(ConstructorFieldInitializerVisitor(node, this));
    super.visitConstructorFieldInitializer(node);
  }
}

class FieldFormalParameterVisitor extends ConstructorFieldVisitor {
  FieldFormalParameterVisitor(this.root, this.parent, this.position) : super();

  final FieldFormalParameter root;
  final ConstructorVisitor parent;
  final int position;

  bool get hasType => root.type != null;
  String? get type => root.type?.type?.toString();

  String? get name => root.identifier.toString();
  set name(String? value) {
    if (value == null) return;
    final identifier = root.identifier;
    identifier.token = value.toToken(identifier.offset);
  }
}

class DefaultFormalParameterVisitor extends ConstructorFieldVisitor {
  DefaultFormalParameterVisitor(this.root, this.parent) : super() {
    if (hasValue) expression = ExpressionVisitor(root.defaultValue!, this);
  }
  final DefaultFormalParameter root;
  final ConstructorVisitor parent;

  String? get name => root.identifier?.toString();
  set name(String? value) {
    if (value == null) return;
    final identifier = root.identifier!;
    identifier.token = value.toToken(identifier.offset);
  }

  ExpressionVisitor? expression;
  bool get hasValue => root.defaultValue != null;
}

class ConstructorFieldInitializerVisitor extends CodeVisitor {
  ConstructorFieldInitializerVisitor(this.root, this.parent) : super() {
    expression = ExpressionVisitor(root.expression, this);
  }
  final ConstructorFieldInitializer root;
  final ConstructorVisitor parent;
  late ExpressionVisitor expression;

  String? get name => root.fieldName.toString();
  set name(String? value) {
    if (value == null) return;
    final identifier = root.fieldName;
    identifier.token = value.toToken(identifier.offset);
  }
}

abstract class ConstructorFieldVisitor extends CodeVisitor {
  FormalParameter get root;
  bool get isConst => root.isConst;
  bool get isFinal => root.isFinal;
  bool get isNamed => root.isNamed;
  bool get isOptional => root.isOptional;
  bool get isPositional => root.isPositional;
  bool get isRequired => root.isRequired;
  bool get isRequiredNamed => root.isRequiredNamed;
  bool get isRequiredPositional => root.isRequiredPositional;
  bool get isSynthetic => root.isSynthetic;
  String? get name;
  set name(String? value);
  bool? get isPrivate => name?.startsWith('_');
}
