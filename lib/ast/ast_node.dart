import 'package:flutter_scripter/token/token.dart';

abstract class ASTNode {
  Token token;

  ASTNode(this.token);
}