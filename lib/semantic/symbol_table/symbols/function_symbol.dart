import 'package:flutter_scripter/semantic/symbol_table/symbol.dart';

class FunctionSymbol extends Symbol {
  int argc;

  FunctionSymbol(String name, this.argc)
      : super(name: name, type: SymbolType.Function);
}