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
import 'package:flutter_scripter/ast/statement/assign_node.dart';
import 'package:flutter_scripter/ast/statement/block_compound_node.dart';
import 'package:flutter_scripter/ast/statement/compound_node.dart';
import 'package:flutter_scripter/ast/statement/expr_statement_node.dart';
import 'package:flutter_scripter/ast/statement/if_node.dart';
import 'package:flutter_scripter/ast/statement/var_decl_node.dart';
import 'package:flutter_scripter/exception/already_defined_exception.dart';
import 'package:flutter_scripter/exception/invalid_symbol_exception.dart';
import 'package:flutter_scripter/exception/undefined_exception.dart';
import 'package:flutter_scripter/machine/stack_frame.dart';
import 'package:flutter_scripter/semantic/symbol_table/scoped_symbol_table.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbol_table.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbols/function_symbol.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbols/var_symbol.dart';
import 'package:flutter_scripter/token/token.dart';

class SemanticAnalyzer extends ASTVisitor<void> {
  var symtab = SymbolTable(scopeName: 'GLOBAL', scopeLevel: 1);
  var debugMode = false;

  void applyStackFrame(StackFrame frame) {
    late SymbolTable tbl;


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
    var varSymbol = VarSymbol(name: varName);

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
    if ((symbol == null) || !(symbol is! FunctionSymbol)) {
      throw UndefinedException(node.token, node.func);
    }
  }

  @override
  void visitExprStatement(ExprStatementNode node) {
    visit(node.expr);
  }
}