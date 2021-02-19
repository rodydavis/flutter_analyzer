part of flutter_ast;

class EnumVisitor extends CodeVisitor {
  EnumVisitor(this.root, this.parent) : super();

  final FileVisitor parent;
  final EnumDeclaration root;

  String get name => root.name.toString();
  set name(String value) {
    root.name = value.toNode(root.name.offset);
  }

  final List<EnumValueVisitor> values = [];

  @override
  void visitEnumConstantDeclaration(EnumConstantDeclaration node) {
    values.add(EnumValueVisitor(node, this));
    super.visitEnumConstantDeclaration(node);
  }

  @override
  String get visitorName => 'enum';

  @override
  Map<String, dynamic> get params => {
        'name': name,
        'values': values.map((e) => e.toJson()).toList(),
      };
}

class EnumValueVisitor extends CodeVisitor {
  EnumValueVisitor(this.root, this.parent) : super();

  String get name => root.name.toString();
  set name(String value) {
    root.name = value.toNode(root.name.offset);
  }

  final EnumVisitor parent;
  final EnumConstantDeclaration root;

  @override
  String get visitorName => 'enum_value';

  @override
  Map<String, dynamic> get params => {
        'name': name,
      };
}
