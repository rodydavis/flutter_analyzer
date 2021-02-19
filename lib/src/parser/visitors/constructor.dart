part of flutter_ast;

class ConstructorVisitor extends CodeVisitor {
  ConstructorVisitor(this.root, this.parent) : super();

  final ConstructorDeclaration root;
  final ClassVisitor parent;

  bool get hasName => name != null;

  String? get redirectedConstructor =>
      root.redirectedConstructor?.name.toString();

  String? get name => root.name?.toString();
  set _name(String? value) {
    if (name == null) {
      throw 'Cannot rename default constructor';
    }
    if (value == null) {
      throw 'Cannot create default constructor';
    }
    root.name = value.toNode(root.name!.offset);
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

  @override
  String get visitorName => 'constructor_declaration';

  @override
  Map<String, dynamic> get params => {
        'name': name,
        'displayName': displayName,
        'position': position,
        'fields': fields.map((e) => e.toJson()).toList(),
        'initializers': initializers.map((e) => e.toJson()).toList(),
      };
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

  @override
  String get visitorName => 'field_formal';

  @override
  Map<String, dynamic> get params => {
        'name': name,
        'type': type,
        'position': position,
      };
}

class DefaultFormalParameterVisitor extends ConstructorFieldVisitor {
  DefaultFormalParameterVisitor(this.root, this.parent) : super() {
    if (hasValue)
      expression = ExpressionVisitor.parse(root.defaultValue!, this);
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

  @override
  String get visitorName => 'field_formal_default';

  @override
  Map<String, dynamic> get params => {
        'name': name,
        'expression': expression?.toJson(),
      };
}

class ConstructorFieldInitializerVisitor extends CodeVisitor {
  ConstructorFieldInitializerVisitor(this.root, this.parent) : super() {
    expression = ExpressionVisitor.parse(root.expression, this);
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

  @override
  String get visitorName => 'field_initializer';

  @override
  Map<String, dynamic> get params => {
        'name': name,
        'expression': expression.toJson(),
      };
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

  @override
  dynamic toJson() {
    return {
      'name': 'field',
      'params': {
        'isConst': isConst,
        'isFinal': isFinal,
        'isNamed': isNamed,
        'isOptional': isOptional,
        'isPositional': isPositional,
        'isRequired': isRequired,
        'isRequiredNamed': isRequiredNamed,
        'isRequiredPositional': isRequiredPositional,
        'isSynthetic': isSynthetic,
        'isPrivate': isPrivate,
        'name': name,
      }
    };
  }
}
