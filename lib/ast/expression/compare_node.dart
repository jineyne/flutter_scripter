import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class CompareNode extends ExpressionNode {
  ASTNode left;
  ASTNode right;

  CompareNode({
    required this.left,
    required Token token,
    required this.right}) : super(token);

  @override
  String toString() {
    return 'CompareNode($left, $token, $right)';
  }
}