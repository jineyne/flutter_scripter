import 'package:flutter_scripter/symbol_table/symbol.dart';

class VarSymbol extends Symbol {
  VarSymbol({required String name, required Symbol type})
      : super(name: name, type: type);

  @override
  String toString() {
    return 'VarSymbol($name, $type)';
  }
}
