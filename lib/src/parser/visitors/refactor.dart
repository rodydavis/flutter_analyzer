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
  NamedExpression? _namedExpression;

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
  void visitNamedExpression(NamedExpression node) {
    _namedExpression = node;
    super.visitNamedExpression(node);
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
    if (scope == RenameScope.METHOD && sameScope) rename(node.name);
    if (scope == RenameScope.CLASS) rename(node.name);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (scope == RenameScope.CLASS &&
        node.constructorName.type.name.toString() == current) {
      node.constructorName.type.name =
          replacement.toNode(node.constructorName.type.name.offset);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (scope == RenameScope.METHOD && sameScope) rename(node.methodName);
    if (scope == RenameScope.CLASS) rename(node.methodName);
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
    if (scope == RenameScope.CLASS && node.returnType.toString() == current) {
      if (node.returnType != null) {
        node.returnType =
            TypeNameImpl(replacement.toNode(node.returnType!.offset), null);
      }
    }
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitTypeName(TypeName node) {
    if (scope == RenameScope.ENUM_NAME && node.name.toString() == current) {
      node.name = SimpleIdentifierImpl(replacement.toToken(node.name.offset));
    }
    if (scope == RenameScope.CLASS && node.name.toString() == current) {
      node.name = SimpleIdentifierImpl(replacement.toToken(node.name.offset));
    }
    super.visitTypeName(node);
  }

  @override
  void visitLabel(Label node) {
    if (scope == RenameScope.VARIABLE && sameScope) {
      rename(node.label);
    }
    super.visitLabel(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (scope == RenameScope.VARIABLE && sameScope) {
      rename(node.propertyName);
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    if (scope == RenameScope.VARIABLE && sameScope) {
      rename(node.identifier);
    }
    super.visitFieldFormalParameter(node);
  }

  @override
  void visitDefaultFormalParameter(DefaultFormalParameter node) {
    if (scope == RenameScope.VARIABLE && sameScope) {
      if (node.identifier != null) rename(node.identifier!);
    }
    super.visitDefaultFormalParameter(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (scope == RenameScope.CLASS && _currentClass?.name.toString() == current) {
      node.returnType = replacement.toNode(node.returnType.offset);
    }
    super.visitConstructorDeclaration(node);
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
