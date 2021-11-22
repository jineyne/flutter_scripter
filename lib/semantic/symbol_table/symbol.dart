enum SymbolType {
  Var,
  Function,
  Unknown,
}

class Symbol {
  String name;
  SymbolType type;

  Symbol({required this.name, SymbolType? type}) : type = type ?? SymbolType.Unknown;
}