import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/statement_node.dart';
import 'package:flutter_scripter/token/token.dart';

class CompoundNode extends StatementNode {
  List<ASTNode> children;

  CompoundNode({required Token token, required this.children}) : super(token);

  @override
  String toString() {
    return 'Compound($children)';
  }
}