import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/ast/statement_node.dart';
import 'package:flutter_scripter/token/token.dart';

class IfNode extends StatementNode {
  ExpressionNode expr;
  StatementNode body;
  StatementNode? orElse;

  IfNode({
    required Token token,
    required this.expr,
    required this.body,
    this.orElse}) : super(token);

  @override
  String toString() {
    return 'IfNode($expr, $body, $orElse)';
  }
}