import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class BooleanNode extends ExpressionNode {
  bool value;

  BooleanNode({required Token token, required this.value}) : super(token);

  @override
  String toString() {
    return 'BooleanNode($value)';
  }
}