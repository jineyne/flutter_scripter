import 'package:flutter_scripter/symbol_table/symbol.dart';
import 'package:flutter_scripter/symbol_table/symbols/built_in_symbol.dart';
import 'package:format/format.dart';

class SymbolTable {
  final symbols = <String, dynamic>{};
  final String scopeName;
  final int scopeLevel;

  SymbolTable({required this.scopeName, required this.scopeLevel}) {
    _initBuiltins();
}

  void _initBuiltins() {
    insert(BuiltinTypeSymbol(name: 'var'));
  }

  Symbol? lookUp(String name) {
    print('LookUp: $name');

    return symbols[name];
  }

  void insert(Symbol symbol) {
    print('Insert: ${symbol.name}');
    symbols[symbol.name] = symbol;
  }

  @override
  String toString() {
    var sb = StringBuffer();
    sb.writeln('SYMBOL TABLE');
    sb.writeln('Scope name: $scopeName');
    sb.writeln('Scope level: $scopeLevel');
    sb.writeln('Symbol table contents');
    sb.writeln('---------------------');
    symbols.forEach((key, value) {
      sb.writeln(format('{0:7}: {1}', key, value));
    });

    return sb.toString();
  }
}