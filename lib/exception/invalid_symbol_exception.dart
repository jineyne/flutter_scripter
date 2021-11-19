import 'package:flutter_scripter/semantic/symbol_table/symbol.dart';
import 'package:flutter_scripter/token/token.dart';

class InvalidSymbolException implements Exception {
  Token token;
  Symbol symbol;

  InvalidSymbolException(this.token, this.symbol);

  @override
  String toString() {
    return "${token.lineNo}:${token.pos}: Invalid symbol '$symbol'";
  }
}
