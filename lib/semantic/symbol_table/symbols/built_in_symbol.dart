import 'package:flutter_scripter/semantic/symbol_table/symbol.dart';

class BuiltinTypeSymbol extends Symbol {
  BuiltinTypeSymbol({required String name}) : super(name: name);

  @override
  String toString() {
    return 'BuiltinTypeSymbol($name)';
  }
}