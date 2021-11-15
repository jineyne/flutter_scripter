import 'package:flutter_scripter/token/token.dart';

class UnSupportedException implements Exception {
  Token token;

  UnSupportedException(this.token);

  @override
  String toString() {
    return "'$token' is unsupported at ${token.lineNo}:${token.pos}";
  }
}