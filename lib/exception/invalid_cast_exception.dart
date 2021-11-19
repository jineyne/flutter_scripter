import 'package:flutter_scripter/token/token.dart';

class InvalidCastException implements Exception {
  Token token;

  InvalidCastException(this.token);

  @override
  String toString() {
    return '${token.lineNo}:${token.pos}: Invalid cast' ;
  }
}