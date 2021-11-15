import 'package:flutter_scripter/token/token.dart';

class InvalidCastException implements Exception {
  Token token;

  InvalidCastException(this.token);

  @override
  String toString() {
    return 'Invalid cast at ${token.lineNo}:${token.pos}';
  }
}