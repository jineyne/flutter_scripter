import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/ast_visitor.dart';
import 'package:flutter_scripter/ast/expression/bin_op_node.dart';
import 'package:flutter_scripter/ast/expression/bool_op_node.dart';
import 'package:flutter_scripter/ast/expression/boolean_node.dart';
import 'package:flutter_scripter/ast/expression/compare_node.dart';
import 'package:flutter_scripter/ast/expression/empty_op_node.dart';
import 'package:flutter_scripter/ast/expression/number_node.dart';
import 'package:flutter_scripter/ast/expression/string_node.dart';
import 'package:flutter_scripter/ast/expression/unary_op_node.dart';
import 'package:flutter_scripter/ast/expression/var_node.dart';
import 'package:flutter_scripter/ast/statement/assign_node.dart';
import 'package:flutter_scripter/ast/statement/block_compound_node.dart';
import 'package:flutter_scripter/ast/statement/compound_node.dart';
import 'package:flutter_scripter/ast/statement/if_node.dart';
import 'package:flutter_scripter/ast/statement/var_decl_node.dart';
import 'package:flutter_scripter/exception/already_defined_exception.dart';
import 'package:flutter_scripter/exception/invalid_cast_exception.dart';
import 'package:flutter_scripter/exception/invalid_operation_exception.dart';
import 'package:flutter_scripter/exception/invalid_symbol_exception.dart';
import 'package:flutter_scripter/exception/undefined_exception.dart';
import 'package:flutter_scripter/semantic/symbol_table/scoped_symbol_table.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbol.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbol_table.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbols/var_symbol.dart';
import 'package:flutter_scripter/token/token.dart';
import 'package:flutter_scripter/token/token_type.dart';

class SemanticAnalyzer extends ASTVisitor<TokenType> {
  var symtab = SymbolTable(scopeName: 'GLOBAL', scopeLevel: 1);
  var debugMode = false;

  void apply(SymbolTable? table) {
    late SymbolTable tbl;

    while (table != null) {
      // do stuff
      if (table is SymbolTable) {
        tbl = SymbolTable(scopeName: table.scopeName, scopeLevel: table.scopeLevel);
      } else if (table is ScopedSymbolTable) {
        tbl = ScopedSymbolTable(scopeName: table.scopeName, scopeLevel: table.scopeLevel, enclosingScope: tbl);
      } else {
        break;
      }

      table.symbols.forEach((key, value) {
        tbl.insert(value);
      });

      if (table is ScopedSymbolTable) {
        table = (table as ScopedSymbolTable).enclosingScope;
      } else {
        table = null;
      }
    }
  }

  @override
  TokenType returnNull() {
    return TokenType.Unknown;
  }

  @override
  TokenType visitAssign(AssignNode node) {
    var left = visit(node.left);
    var right = visit(node.right);

    return left;
  }

  @override
  TokenType visitBinOp(BinOpNode node) {
    var left = visit(node.left);
    var right = visit(node.right);

    return left;
  }

  @override
  TokenType visitBlockCompound(BlockCompoundNode node) {
    for (var child in node.children) {
      visit(child);
    }

    return returnNull();
  }

  @override
  TokenType visitBoolOp(BoolOpNode node) {
    var left = visit(node.left);
    var right = visit(node.right);
    if (left != TokenType.Boolean || right != TokenType.Boolean) {
      throw InvalidCastException(node.op);
    }
    return left;
  }

  @override
  TokenType visitBoolean(BooleanNode node) {
    return node.token.type;
  }

  @override
  TokenType visitCompare(CompareNode node) {
    var left = visit(node.left);
    var right = visit(node.right);

    if (left != right) {
      throw InvalidCastException(node.op);
    }
    return TokenType.Boolean;
  }

  @override
  TokenType visitCompound(CompoundNode node) {
    for (var child in node.children) {
      visit(child);
    }

    return returnNull();
  }

  @override
  TokenType visitIf(IfNode node) {
    var condition = visit(node.expr);
    if (condition != TokenType.Boolean) {
      throw InvalidCastException(node.expr.op);
    }

    pushSymbolTable('INTERNAL_IF_SCOPE');
    visit(node.body);
    popSymbolTable();
    if (node.orElse != null) {
      pushSymbolTable('INTERNAL_IF_ELSE_SCOPE');
      visit(node.orElse ?? EmptyOpNode(token: Token.empty()));
      popSymbolTable();
    }

    return returnNull();
  }

  @override
  TokenType visitNumber(NumberNode node) {
    return node.token.type;
  }

  @override
  TokenType visitString(StringNode node) {
    return node.token.type;
  }

  @override
  TokenType visitUnaryOp(UnaryOpNode node) {
    return visit(node.expr);
  }

  @override
  TokenType visitVar(VarNode node) {
    var varName = node.id;
    var varSymbol = symtab.lookUp(varName);

    if (varSymbol == null) {
      throw UndefinedException(node.token, node.id);
    }

    if (varSymbol.type == null) {
      throw InvalidSymbolException(node.token, varSymbol);
    }

    if (varSymbol.type?.name == 'String') {
      return TokenType.String;
    } else if (varSymbol.type?.name == 'Number') {
      return TokenType.Number;
    } else if (varSymbol.type?.name == 'Boolean') {
      return TokenType.Boolean;
    }

    throw InvalidSymbolException(node.token, varSymbol);
  }

  @override
  TokenType visitVarDecl(VarDeclNode node) {
    var varName = node.variable.token.value as String;

    if (symtab.lookUp(varName) != null) {
      throw AlreadyDefinedException(node.token, varName);
    }

    var expr = visit(node.initializer);
    late Symbol typeSymbol;

    if (expr == TokenType.String) {
      typeSymbol = symtab.lookUp('String') ?? (throw InvalidCastException(node.token));
    } else if (expr == TokenType.Number) {
      typeSymbol = symtab.lookUp('Number') ?? (throw InvalidCastException(node.token));
    } else if (expr == TokenType.Boolean) {
      typeSymbol = symtab.lookUp('Boolean') ?? (throw InvalidCastException(node.token));
    } else {
      throw InvalidOperationException(node.token);
    }

    var varSymbol = VarSymbol(name: varName, type: typeSymbol);

    symtab.insert(varSymbol);
    return expr;
  }

  void pushSymbolTable(String name) {
    symtab = ScopedSymbolTable(enclosingScope: symtab, scopeName: name,
        scopeLevel: symtab.scopeLevel + 1);
  }

  void popSymbolTable() {
    if (debugMode) {
      print('');
      print('========================================');
      print(symtab);
      print('========================================');
      print('LEAVE SCOPE: ${symtab.scopeName}');
      print('');
    }

    symtab = (symtab as ScopedSymbolTable).enclosingScope;
  }
}