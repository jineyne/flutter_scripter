import 'package:flutter_scripter/token/token.dart';

import 'ast_node.dart';

abstract class StatementNode extends ASTNode {
  StatementNode(Token token) : super(token);
}