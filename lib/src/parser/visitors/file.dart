part of flutter_ast;

class FileVisitor extends CodeVisitor {
  FileVisitor(this.root, this.parent) : super();

  final CompilationUnit root;
  final FlutterParser parent;

  final List<ClassVisitor> classes = [];
  final List<MixinVisitor> mixins = [];
  final List<EnumVisitor> enums = [];
  final List<ImportVisitor> imports = [];
  final List<VariableVisitor> fields = [];
  final List<FunctionVisitor> functions = [];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    classes.add(ClassVisitor(node, this));
    super.visitClassDeclaration(node);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    enums.add(EnumVisitor(node, this));
    super.visitEnumDeclaration(node);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    mixins.add(MixinVisitor(node, this));
    super.visitMixinDeclaration(node);
  }

  @override
  void visitImportDirective(ImportDirective node) {
    imports.add(ImportVisitor(node, this));
    super.visitImportDirective(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    functions.add(FunctionVisitor(node, this));
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final item in node.variables.variables) {
      fields.add(VariableVisitor(item, this));
    }
    super.visitTopLevelVariableDeclaration(node);
  }

  @override
  String get visitorName => 'compilation_unit';

  @override
  Map<String, dynamic> get params => {
        'classes': classes.map((e) => e.toJson()).toList(),
        'mixins': mixins.map((e) => e.toJson()).toList(),
        'enums': enums.map((e) => e.toJson()).toList(),
        'imports': imports.map((e) => e).toList(),
        'fields': fields.map((e) => e).toList(),
        'functions': functions,
      };
}
