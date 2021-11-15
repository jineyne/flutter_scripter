import 'package:flutter_scripter/ast/expression/var_node.dart';

class InvalidVarException implements Exception {
  VarNode varNode;

  InvalidVarException(this.varNode);

  @override
  String toString() {
    var token = varNode.token;
    return 'Invalid var ${varNode.id} at ${token.lineNo}:${token.pos}';
  }
}