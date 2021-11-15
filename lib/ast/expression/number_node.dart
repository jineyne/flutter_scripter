import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class NumberNode extends ExpressionNode {
  double value;

  NumberNode({required Token token}) : value = token.value, super(token);

  @override
  String toString() {
    return 'NumberNode($value)';
  }
}