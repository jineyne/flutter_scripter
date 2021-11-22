import 'package:flutter_scripter/exception/scripter_exception.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbol.dart';
import 'package:flutter_scripter/token/token.dart';

class InvalidSymbolException extends ScripterException {
  Symbol symbol;

  InvalidSymbolException(Token token, this.symbol) : super(token);

  @override
  String toString() {
    return "$lineNo:$pos: Invalid symbol '$symbol'";
  }
}
