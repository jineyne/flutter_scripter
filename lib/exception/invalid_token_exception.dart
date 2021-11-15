import 'package:flutter_scripter/token/token.dart';

class InvalidTokenException implements Exception {
  Token token;

  InvalidTokenException(this.token);

  @override
  String toString() {
    return "Invalid token '$token' at ${token.lineNo}:${token.pos}";
  }
}
