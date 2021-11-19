import 'package:flutter_scripter/token/token.dart';

class UndefinedException implements Exception {
  Token token;
  String id;

  UndefinedException(this.token, this.id);

  @override
  String toString() {
    return "${token.lineNo}:${token.pos}: '$id' is undefined";
  }
}