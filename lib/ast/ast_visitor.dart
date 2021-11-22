import 'package:flutter_scripter/ast/ast_node.dart';
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
import 'package:flutter_scripter/exception/unsupported_exception.dart';

abstract class ASTVisitor<T> {
  T visit(ASTNode node) {
    if (node is CompoundNode) {
      return visitCompound(node);
    } else if (node is BlockCompoundNode){
      return visitBlockCompound(node);
    } else if (node is AssignNode) {
      return visitAssign(node);
    } else if (node is VarDeclNode) {
      return visitVarDecl(node);
    } else if (node is IfNode) {
      return visitIf(node);
    } else if (node is ExprStatementNode) {
      return visitExprStatement(node);
    } else if (node is BinOpNode) {
      return visitBinOp(node);
    } else if (node is BoolOpNode) {
      return visitBoolOp(node);
    } else if (node is CompareNode) {
      return visitCompare(node);
    } else if (node is FunctionCallNode) {
      return visitFunctionCall(node);
    } else if (node is BooleanNode) {
      return visitBoolean(node);
    } else if (node is NumberNode) {
      return visitNumber(node);
    } else if (node is StringNode) {
      return visitString(node);
    } else if (node is UnaryOpNode) {
      return visitUnaryOp(node);
    } else if (node is VarNode) {
      return visitVar(node);
    } else if (node is EmptyOpNode) {
      return visitEmptyOp(node);
    } else if (node is ScriptNode) {
      return visitScriptNode(node);
    } else if (node is ProcedureCallNode) {
      return visitProcedureCall(node);
    }

    throw UnSupportedException(node.token);
    return returnNull();
  }

  T returnNull();

  /////////////////////////
  //  statement compound //
  /////////////////////////
  T visitCompound(CompoundNode node);
  T visitBlockCompound(BlockCompoundNode node);
  T visitAssign(AssignNode node);
  T visitVarDecl(VarDeclNode node);
  T visitIf(IfNode node);
  T visitExprStatement(ExprStatementNode node);
  T visitProcedureCall(ProcedureCallNode node);


  /////////////////////////
  // expression compound //
  /////////////////////////
  T visitBinOp(BinOpNode node);
  T visitBoolOp(BoolOpNode node);
  T visitCompare(CompareNode node);
  T visitFunctionCall(FunctionCallNode node);
  T visitBoolean(BooleanNode node);
  T visitNumber(NumberNode node);
  T visitString(StringNode node);
  T visitUnaryOp(UnaryOpNode node);
  T visitVar(VarNode node);

  T visitScriptNode(ScriptNode node);

  T visitEmptyOp(EmptyOpNode node) {
    return returnNull();
  }

}