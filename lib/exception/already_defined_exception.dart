import 'package:flutter_scripter/token/token.dart';

class AlreadyDefinedException implements Exception {
  Token token;
  String id;

  AlreadyDefinedException(this.token, this.id);

  @override
  String toString() {
    return "${token.lineNo}:${token.pos}: '$id' is already defined";
  }
}
