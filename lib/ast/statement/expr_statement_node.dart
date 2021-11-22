import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/ast/statement_node.dart';
import 'package:flutter_scripter/token/token.dart';

class ExprStatementNode extends StatementNode {
  ExpressionNode expr;

  ExprStatementNode({required Token token, required this.expr}) : super(token);

  @override
  String toString() {
    return 'ExpStatementNode($expr)';
  }
}