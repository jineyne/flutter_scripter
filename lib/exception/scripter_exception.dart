import 'package:flutter_scripter/token/token.dart';

class ScripterException implements Exception {
  Token token;

  int get lineNo => token.lineNo;
  int get pos => token.pos;

  ScripterException(this.token);
}