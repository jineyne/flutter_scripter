import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/statement_node.dart';
import 'package:flutter_scripter/token/token.dart';

class AssignNode extends StatementNode {
  ASTNode left;
  ASTNode right;

  AssignNode({
    required this.left,
    required Token token,
    required this.right}) : super(token);
}