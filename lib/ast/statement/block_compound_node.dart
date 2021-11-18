import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/statement_node.dart';
import 'package:flutter_scripter/token/token.dart';

class BlockCompoundNode extends StatementNode {
  List<ASTNode> children;

  BlockCompoundNode({required Token token, required this.children}) : super(token);

  @override
  String toString() {
    return 'BlockCompoundNode($children)';
  }
}