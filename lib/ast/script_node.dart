import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/statement/compound_node.dart';
import 'package:flutter_scripter/token/token.dart';

class ScriptNode extends ASTNode {
  String name;
  CompoundNode compound;

  ScriptNode({
    required this.compound,
    String? name
  }) : name = name ?? 'InternalScript', super(Token.empty());
}