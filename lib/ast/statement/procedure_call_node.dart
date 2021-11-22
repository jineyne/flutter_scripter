import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/ast/statement_node.dart';
import 'package:flutter_scripter/token/token.dart';

class ProcedureCallNode extends StatementNode {
  String func;
  List<ExpressionNode> args;

  ProcedureCallNode({required Token token, required this.func,
    required this.args}) : super(token);

  @override
  String toString() {
    return 'ProcedureCall($func, $args)';
  }
}