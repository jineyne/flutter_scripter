import 'package:flutter_scripter/token/token_type.dart';

class Token {
  TokenType type;
  dynamic value;

  int lineNo;
  int pos;

  Token(this.type, this.lineNo, this.pos);

  Token.number(double this.value, this.lineNo, this.pos) : type = TokenType.Number;
  Token.string(String this.value, this.lineNo, this.pos) : type = TokenType.String;
  Token.identifier(String this.value, this.lineNo, this.pos) : type = TokenType.Identifier;

  Token.keyword(this.type, String this.value, this.lineNo, this.pos);
  Token.unknown(String this.value, this.lineNo, this.pos) : type = TokenType.Unknown;

  Token.empty() : type = TokenType.Unknown, lineNo = 0, pos = 0;

  @override
  String toString() {
    return 'Token($type, $value)';
  }
}