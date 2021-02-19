import 'package:analyzer/dart/ast/ast.dart';

import '../utils.dart';
import 'comment.dart';
import 'file.dart';

class MixinVisitor extends CodeVisitor {
  MixinVisitor(this.root, this.parent) : super() {
    if (root.documentationComment != null) {
      this.comment = CommentVisitor(root.documentationComment!, this);
    }
  }

  final MixinDeclaration root;
  final FileVisitor parent;

  CommentVisitor? comment;

  String get name => root.name.toString();
  set name(String value) {
    root.name = value.toNode(root.name.offset);
  }

  @override
  String get visitorName => 'mixin';

  @override
  Map<String, dynamic> get params => {};
}
