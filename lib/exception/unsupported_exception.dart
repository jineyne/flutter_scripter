import 'package:flutter_scripter/token/token.dart';

class UnSupportedException implements Exception {
  Token token;

  UnSupportedException(this.token);

  @override
  String toString() {
    return "${token.lineNo}:${token.pos}: '$token' is unsupported";
  }
}