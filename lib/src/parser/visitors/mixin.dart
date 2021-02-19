import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';
import 'file.dart';

class MixinVisitor extends CodeVisitor {
  MixinVisitor(this.root, this.parent) : super();

  final MixinDeclaration root;
  final FileVisitor parent;

  @override
  String get visitorName => 'mixin';

  @override
  dynamic toJson() {
    return {
      'name': visitorName,
      'params': {},
    };
  }
}
