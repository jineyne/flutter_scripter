import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class UnaryOpNode extends ExpressionNode {
  ASTNode expr;

  UnaryOpNode({required Token token, required this.expr}) : super(token);

  @override
  String toString() {
    return 'UnaryOpNode($token, $expr)';
  }
}