import 'package:flutter_scripter/semantic/symbol_table/symbol.dart';

class ProcedureSymbol extends Symbol {
  int argc;

  ProcedureSymbol(String name, this.argc)
      : super(name: name, type: SymbolType.Procedure);
}