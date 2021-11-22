import 'package:flutter/cupertino.dart';
import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/ast_visitor.dart';
import 'package:flutter_scripter/ast/expression/bin_op_node.dart';
import 'package:flutter_scripter/ast/expression/bool_op_node.dart';
import 'package:flutter_scripter/ast/expression/boolean_node.dart';
import 'package:flutter_scripter/ast/expression/compare_node.dart';
import 'package:flutter_scripter/ast/expression/empty_op_node.dart';
import 'package:flutter_scripter/ast/expression/function_call_node.dart';
import 'package:flutter_scripter/ast/expression/number_node.dart';
import 'package:flutter_scripter/ast/expression/string_node.dart';
import 'package:flutter_scripter/ast/expression/unary_op_node.dart';
import 'package:flutter_scripter/ast/expression/var_node.dart';
import 'package:flutter_scripter/ast/script_node.dart';
import 'package:flutter_scripter/ast/statement/assign_node.dart';
import 'package:flutter_scripter/ast/statement/block_compound_node.dart';
import 'package:flutter_scripter/ast/statement/compound_node.dart';
import 'package:flutter_scripter/ast/statement/expr_statement_node.dart';
import 'package:flutter_scripter/ast/statement/if_node.dart';
import 'package:flutter_scripter/ast/statement/procedure_call_node.dart';
import 'package:flutter_scripter/ast/statement/var_decl_node.dart';
import 'package:flutter_scripter/exception/already_defined_exception.dart';
import 'package:flutter_scripter/exception/invalid_function_argument_exception.dart';
import 'package:flutter_scripter/exception/invalid_symbol_exception.dart';
import 'package:flutter_scripter/exception/undefined_exception.dart';
import 'package:flutter_scripter/machine/value.dart';
import 'package:flutter_scripter/semantic/symbol_table/scoped_symbol_table.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbol.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbol_table.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbols/function_symbol.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbols/procedure_symbol.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbols/var_symbol.dart';
import 'package:flutter_scripter/token/token.dart';

class SemanticAnalyzer extends ASTVisitor<void> {
  var symtab = SymbolTable(scopeName: 'GLOBAL', scopeLevel: 1);
  var debugMode = false;

  void apply(Map<String, Value> scope) {
    late SymbolTable tbl;

    // TODO:
    scope.forEach((key, value) {
      if (value is NumberValue || value is StringValue || value is BooleanValue) {
        symtab.insert(VarSymbol(key));
        return;
      }

      if (value is ExternalFunctionValue) {
        symtab.insert(FunctionSymbol(key, value.argc));
        return;
      }

      if (value is ExternalProcedureValue) {
        symtab.insert(ProcedureSymbol(key, value.argc));
        return;
      }
    });
  }

  @override
  void returnNull() {
  }

  @override
  void visitAssign(AssignNode node) {
    var left = visit(node.left);
    var right = visit(node.right);
  }

  @override
  void visitBinOp(BinOpNode node) {
    var left = visit(node.left);
    var right = visit(node.right);
  }

  @override
  void visitBlockCompound(BlockCompoundNode node) {
    for (var child in node.children) {
      visit(child);
    }
  }

  @override
  void visitBoolOp(BoolOpNode node) {
    visit(node.left);
    visit(node.right);
  }

  @override
  void visitBoolean(BooleanNode node) {
  }

  @override
  void visitCompare(CompareNode node) {
    visit(node.left);
    visit(node.right);
  }

  @override
  void visitCompound(CompoundNode node) {
    for (var child in node.children) {
      visit(child);
    }
  }

  @override
  void visitIf(IfNode node) {
    visit(node.expr);

    pushSymbolTable('INTERNAL_IF_SCOPE');
    visit(node.body);
    popSymbolTable();
    if (node.orElse != null) {
      pushSymbolTable('INTERNAL_IF_ELSE_SCOPE');
      visit(node.orElse ?? EmptyOpNode(token: Token.empty()));
      popSymbolTable();
    }
  }

  @override
  void visitNumber(NumberNode node) {
  }

  @override
  void visitString(StringNode node) {
  }

  @override
  void visitUnaryOp(UnaryOpNode node) {
    visit(node.expr);
  }

  @override
  void visitVar(VarNode node) {
    var varName = node.id;
    var symbol = symtab.lookUp(varName);

    if (symbol == null) {
      throw UndefinedException(node.token, node.id);
    }

    if (symbol.type == null) {
      throw InvalidSymbolException(node.token, symbol);
    }
  }

  @override
  void visitVarDecl(VarDeclNode node) {
    var varName = node.variable.token.value as String;

    if (symtab.lookUp(varName) != null) {
      throw AlreadyDefinedException(node.token, varName);
    }

    var expr = visit(node.initializer);
    var varSymbol = VarSymbol(varName);

    symtab.insert(varSymbol);
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

  @override
  void visitFunctionCall(FunctionCallNode node) {
    var symbol = symtab.lookUp(node.func);
    if ((symbol == null) || symbol is! FunctionSymbol) {
      throw UndefinedException(node.token, node.func);
    }

    if (node.args.length > symbol.argc) {
      throw InvalidFunctionArgumentsException.many(node.token);
    } else if (node.args.length < symbol.argc) {
      throw InvalidFunctionArgumentsException.few(node.token);
    }
  }

  @override
  void visitExprStatement(ExprStatementNode node) {
    visit(node.expr);
  }

  @override
  void visitScriptNode(ScriptNode node) {
    visit(node.compound);
  }

  @override
  void visitProcedureCall(ProcedureCallNode node) {
    var symbol = symtab.lookUp(node.func);
    if ((symbol == null) || symbol is! ProcedureSymbol) {
      throw UndefinedException(node.token, node.func);
    }

    if (node.args.length > symbol.argc) {
      throw InvalidFunctionArgumentsException.many(node.token);
    } else if (node.args.length < symbol.argc) {
      throw InvalidFunctionArgumentsException.few(node.token);
    }
  }
}