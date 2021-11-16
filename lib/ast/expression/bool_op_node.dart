import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class BoolOpNode extends ExpressionNode {
  ASTNode left;
  ASTNode right;

  BoolOpNode({
    required Token token,
    required this.left,
    required this.right}) : super(token);

  @override
  String toString() {
    return 'BoolOpNode($left, $token, $right)';
  }
}