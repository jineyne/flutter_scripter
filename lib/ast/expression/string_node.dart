import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class StringNode extends ExpressionNode {
  String value;

  StringNode({required Token token, required this.value}) : super(token);

  @override
  String toString() {
    return 'StringNode($value)';
  }
}