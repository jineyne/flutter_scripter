import 'package:flutter_scripter/semantic/symbol_table/symbol.dart';

class FunctionSymbol extends Symbol {
  FunctionSymbol({required String name})
      : super(name: name, type: SymbolType.Function);
}