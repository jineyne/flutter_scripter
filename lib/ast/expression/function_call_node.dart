import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class FunctionCallNode extends ExpressionNode {
  String func;
  List<ExpressionNode> args;

  FunctionCallNode({required Token token, required this.func,
    required this.args}) : super(token);

  @override
  String toString() {
    return 'FunctionCall($func, $args)';
  }
}