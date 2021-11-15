
import 'package:flutter_scripter/token/token.dart';
import 'package:flutter_scripter/token/token_type.dart';

import 'ast_node.dart';

abstract class ExpressionNode extends ASTNode {
  Token get op => token;
  TokenType get type => token.type;

  ExpressionNode(Token token) : super(token);
}