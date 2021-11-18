import 'package:flutter_scripter/symbol_table/symbol.dart';
import 'package:flutter_scripter/symbol_table/symbol_table.dart';
import 'package:format/format.dart';

class ScopedSymbolTable extends SymbolTable {
  SymbolTable _enclosingScope;

  ScopedSymbolTable({
    required SymbolTable enclosingScope,
    required String scopeName,
    required int scopeLevel})
      : _enclosingScope = enclosingScope
      , super(scopeName: scopeName, scopeLevel: scopeLevel);

  @override
  Symbol? lookUp(String name) {
    var result = super.lookUp(name);
    if (result != null) {
      return result;
    }

    return _enclosingScope.lookUp(name);
  }

  @override
  String toString() {
    var sb = StringBuffer();
    sb.writeln('SCOPED SYMBOL TABLE');
    sb.writeln('Scope name: $scopeName');
    sb.writeln('Scope level: $scopeLevel');
    sb.writeln('Enclosing scope: ${_enclosingScope.scopeName}');
    sb.writeln('Symbol table contents');
    sb.writeln('---------------------');
    symbols.forEach((key, value) {
      sb.writeln(format('{0:7}: {1}', key, value));
    });

    return sb.toString();
  }
}