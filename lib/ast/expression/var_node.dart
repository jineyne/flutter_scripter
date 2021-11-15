import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/token/token.dart';

class VarNode extends ExpressionNode {
  String id;
  // int? index;

  VarNode({required Token token, required this.id}) : super(token);

  @override
  String toString() {
    return 'Var($id)';
  }
}