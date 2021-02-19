part of flutter_ast;

enum RenameScope { CLASS, ENUM_NAME, ENUM_VALUE, VARIABLE, METHOD, MIXIN }

class RefactorVisitor extends RecursiveAstVisitor<void> {
  RefactorVisitor.className(this.current, this.replacement)
      : this.scope = RenameScope.CLASS,
        this.match = null;

  RefactorVisitor.mixinName(this.current, this.replacement)
      : this.scope = RenameScope.CLASS,
        this.match = null;

  RefactorVisitor.variableName(this.current, this.replacement, String name)
      : this.scope = RenameScope.VARIABLE,
        this.match = name;

  RefactorVisitor.enumName(this.current, this.replacement)
      : this.scope = RenameScope.ENUM_NAME,
        this.match = null;

  RefactorVisitor.enumValue(this.current, this.replacement, String name)
      : this.scope = RenameScope.ENUM_VALUE,
        this.match = name;

  RefactorVisitor.methodTopLevelName(this.current, this.replacement)
      : this.scope = RenameScope.METHOD,
        this.match = null;

  RefactorVisitor.methodName(this.current, this.replacement, String name)
      : this.scope = RenameScope.METHOD,
        this.match = name;

  final String current, replacement;
  final RenameScope scope;
  final String? match;

  ClassDeclaration? _currentClass;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _currentClass = node;
    if (scope == RenameScope.CLASS) rename(node.name);
    super.visitClassDeclaration(node);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    if (scope == RenameScope.ENUM_NAME) {
      rename(node.name);
    }
    if (scope == RenameScope.ENUM_VALUE && match == node.name.toString()) {
      for (final child in node.constants) {
        rename(child.name);
      }
    }
    super.visitEnumDeclaration(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (scope == RenameScope.ENUM_NAME && current == node.prefix.toString()) {
      rename(node.prefix);
    }
    if (scope == RenameScope.ENUM_VALUE && match == node.prefix.toString()) {
      rename(node.identifier);
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (scope == RenameScope.METHOD && sameScope) {
      rename(node.name);
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (scope == RenameScope.METHOD && sameScope) {
      rename(node.methodName);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    if (scope == RenameScope.MIXIN) rename(node.name);
    super.visitMixinDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (scope == RenameScope.METHOD) rename(node.name);
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    if (scope == RenameScope.VARIABLE && sameScope) {
      rename(node.identifier);
    }
    super.visitFieldFormalParameter(node);
  }

  @override
  void visitTypeName(TypeName node) {
    if (scope == RenameScope.ENUM_NAME && node.name.toString() == current) {
      node.name = SimpleIdentifierImpl(replacement.toToken(node.name.offset));
    }
    super.visitTypeName(node);
  }

  @override
  void visitDefaultFormalParameter(DefaultFormalParameter node) {
    if (scope == RenameScope.VARIABLE && sameScope) {
      if (node.identifier != null) rename(node.identifier!);
    }
    super.visitDefaultFormalParameter(node);
  }

  @override
  void visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    if (scope == RenameScope.VARIABLE && sameScope) {
      rename(node.fieldName);
    }
    super.visitConstructorFieldInitializer(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (scope == RenameScope.VARIABLE && sameScope) {
      rename(node.name);
    }
    super.visitVariableDeclaration(node);
  }

  bool get sameScope => _currentClass?.name.toString() == match;

  void rename(SimpleIdentifier node) {
    if (node.token.toString() != current) return;
    node.token = replacement.toToken(node.token.offset);
  }
}
