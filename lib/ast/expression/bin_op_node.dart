import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class BinOpNode extends ExpressionNode {
  ASTNode left;
  ASTNode right;

  BinOpNode({
    required this.left,
    required Token token,
    required this.right}) : super(token);

  @override
  String toString() {
    return 'BinOpNode($left, $token, $right)';
  }
}