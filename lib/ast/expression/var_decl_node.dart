import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class VarDeclNode extends ExpressionNode {
  ASTNode variable;
  ASTNode initializer;

  VarDeclNode({
    required this.variable,
    required Token token,
    required this.initializer}) : super(token);

  @override
  String toString() {
    return 'VarDeclNode($variable, $initializer)';
  }
}