import 'package:flutter_scripter/token/token.dart';

class InvalidOperationException implements Exception {
  Token op;

  InvalidOperationException(this.op);

  @override
  String toString() {
    return "${op.lineNo}:${op.pos}: Invalid operation '$op'";
  }
}