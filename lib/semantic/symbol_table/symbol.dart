enum SymbolType {
  Var,
  Function,
  Procedure,
  Unknown,
}

class Symbol {
  String name;
  SymbolType type;

  Symbol({required this.name, SymbolType? type}) : type = type ?? SymbolType.Unknown;
}