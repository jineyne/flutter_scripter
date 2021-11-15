import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class AssignOpNode extends ExpressionNode {
  ASTNode left;
  ASTNode right;

  AssignOpNode({
    required this.left,
    required Token token,
    required this.right}) : super(token);
}