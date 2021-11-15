import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class EmptyOpNode extends ExpressionNode {
  EmptyOpNode({required Token token}) : super(token);

  @override
  String toString() {
    return 'EmptyOp()';
  }
}