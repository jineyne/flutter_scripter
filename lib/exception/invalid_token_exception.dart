import 'package:flutter_scripter/token/token.dart';

class InvalidTokenException implements Exception {
  Token token;

  InvalidTokenException(this.token);

  @override
  String toString() {
    return "${token.lineNo}:${token.pos}: Invalid token '$token'";
  }
}
