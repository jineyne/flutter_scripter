import 'package:flutter_scripter/semantic/symbol_table/symbol.dart';

class VarSymbol extends Symbol {
  VarSymbol(String name)
      : super(name: name, type: SymbolType.Var);

  @override
  String toString() {
    return 'VarSymbol($name)';
  }
}
