import 'package:flutter_scripter/token/token_type.dart';

class Token {
  TokenType type;
  dynamic value;

  int lineNo;
  int pos;

  Token(this.type, this.lineNo, this.pos);

  Token.number(double this.value, this.lineNo, this.pos) : type = TokenType.number;
  Token.string(String this.value, this.lineNo, this.pos) : type = TokenType.string;
  Token.identifier(String this.value, this.lineNo, this.pos) : type = TokenType.identifier;

  Token.keyword(this.type, String this.value, this.lineNo, this.pos);
  Token.unknown(String this.value, this.lineNo, this.pos) : type = TokenType.unknwon;

  @override
  String toString() {
    return 'Token($type, $value)';
  }
}