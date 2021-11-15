import 'package:flutter_scripter/token/token.dart';

class InvalidOperationException implements Exception {
  Token op;

  InvalidOperationException(this.op);

  @override
  String toString() {
    return "Invalid operation '$op' at ${op.lineNo}:${op.pos}";
  }
}