import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/script_node.dart';
import 'package:flutter_scripter/ast/statement/expr_statement_node.dart';
import 'package:flutter_scripter/ast/expression/function_call_node.dart';
import 'package:flutter_scripter/ast/statement/assign_node.dart';
import 'package:flutter_scripter/ast/expression/bin_op_node.dart';
import 'package:flutter_scripter/ast/expression/bool_op_node.dart';
import 'package:flutter_scripter/ast/expression/boolean_node.dart';
import 'package:flutter_scripter/ast/expression/compare_node.dart';
import 'package:flutter_scripter/ast/expression/empty_op_node.dart';
import 'package:flutter_scripter/ast/statement/block_compound_node.dart';
import 'package:flutter_scripter/ast/statement/if_node.dart';
import 'package:flutter_scripter/ast/expression/number_node.dart';
import 'package:flutter_scripter/ast/expression/string_node.dart';
import 'package:flutter_scripter/ast/expression/unary_op_node.dart';
import 'package:flutter_scripter/ast/statement/procedure_call_node.dart';
import 'package:flutter_scripter/ast/statement/var_decl_node.dart';
import 'package:flutter_scripter/ast/expression/var_node.dart';
import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/ast/statement/compound_node.dart';
import 'package:flutter_scripter/ast/statement_node.dart';
import 'package:flutter_scripter/lexer/lexer.dart';
import 'package:flutter_scripter/token/token.dart';
import 'package:flutter_scripter/token/token_type.dart';

class Parser {
  Lexer lexer;
  Token currentToken;

  var errorBuffer = StringBuffer();
  bool get isError  => errorBuffer.isNotEmpty;
  String get errorMessage => errorBuffer.toString();

  Parser(this.lexer) : currentToken = lexer.getNextToken();

  ASTNode parse() {
    errorBuffer.clear();
    return ScriptNode(compound: compoundStatement());
  }

  void error(String error) {
    errorBuffer.writeln('Error at ${currentToken.lineNo}:${currentToken.pos}: $error');
  }

  void eat(TokenType type) {
    if (currentToken.type == type) {
      currentToken = lexer.getNextToken();
    } else {
      error('expect token \'$currentToken\' at ${currentToken.lineNo}:${currentToken.pos}');
    }
  }

  StatementNode statement() {
    switch (currentToken.type) {
      case TokenType.If: return ifStatement();
      case TokenType.Identifier:
        if (lexer.currentChar == '(') {
          return procedureCall();
        } else {
          return assignmentStatement();
        }
      case TokenType.Variable: return varDeclStatement();
      case TokenType.LeftBracket: return blockStatement();
      default: return CompoundNode(token: currentToken, children: []);
    }
  }

  List<ASTNode> statementList() {
    var result = <ASTNode>[];
    result.add(statement());

    while (currentToken.type == TokenType.EOL) {
      eat(TokenType.EOL);
      result.add(statement());
    }

    if (currentToken.type == TokenType.Identifier) {
      error('Invalid identifier');
    }

    return result;
  }

  BlockCompoundNode blockStatement() {
    var token = currentToken;
    eat(TokenType.LeftBracket);
    var nodes = statementList();
    eat(TokenType.RightBracket);

    return BlockCompoundNode(token: token, children: nodes);
  }

  CompoundNode compoundStatement() {
    var token = currentToken;
    var nodes = statementList();

    return CompoundNode(token: token, children: nodes);
  }

  VarDeclNode varDeclStatement() {
    var token = currentToken;
    eat(TokenType.Variable);

    var id = variable();

    eat(TokenType.Assign);
    var initializer = expr();

    return VarDeclNode(variable: id, token: token, initializer: initializer);
  }

  ProcedureCallNode procedureCall() {
    var token = currentToken;
    var funcName = token.value as String;
    eat(TokenType.Identifier);
    eat(TokenType.LeftParen);
    var args = <ExpressionNode>[];
    if (currentToken.type != TokenType.RightParen) {
      args.add(expr());
    }

    while (currentToken.type == TokenType.Comma) {
      eat(TokenType.Comma);
      args.add(expr());
    }

    eat(TokenType.RightParen);

    return ProcedureCallNode(token: token, func: funcName, args: args);
  }

  FunctionCallNode functionCall() {
    var token = currentToken;
    var funcName = token.value as String;
    eat(TokenType.Identifier);
    eat(TokenType.LeftParen);
    var args = <ExpressionNode>[];
    if (currentToken.type != TokenType.RightParen) {
      args.add(expr());
    }
    
    while (currentToken.type == TokenType.Comma) {
      eat(TokenType.Comma);
      args.add(expr());
    }

    eat(TokenType.RightParen);

    return FunctionCallNode(token: token, func: funcName, args: args);
  }

  AssignNode assignmentStatement() {
    var left = variable();
    var token = currentToken;
    eat(TokenType.Assign);
    var right = expr();

    return AssignNode(left: left, token: token, right: right);
  }

  IfNode ifStatement() {
    var token = currentToken;
    eat(TokenType.If);

    eat(TokenType.LeftParen);
    var exp = expr();
    eat(TokenType.RightParen);

    late StatementNode body;
    if (currentToken.type == TokenType.LeftBracket) {
      body = blockStatement();
    } else {
      body = statement();
    }

    StatementNode? orElse;
    if (currentToken.type == TokenType.Else) {
      eat(TokenType.Else);
      if (currentToken.type == TokenType.LeftBracket) {
        orElse = blockStatement();
      } else {
        orElse = statement();
      }
    }

    return IfNode(token: token, expr: exp, body: body, orElse: orElse);
  }

  ExpressionNode factor() {
    var token = currentToken;
    switch (token.type) {
      case TokenType.Plus:
        eat(TokenType.Plus);
        return UnaryOpNode(token: token, expr: factor());
      case TokenType.Minus:
        eat(TokenType.Minus);
        return UnaryOpNode(token: token, expr: factor());
      case TokenType.Exclamation:
        eat(TokenType.Exclamation);
        return UnaryOpNode(token: token, expr: factor());
      case TokenType.Number:
        eat(TokenType.Number);
        return NumberNode(token: token);
      case TokenType.String:
        eat(TokenType.String);
        return StringNode(token: token, value: token.value);
      case TokenType.Boolean:
        eat(TokenType.Boolean);
        return BooleanNode(token: token, value: token.value == 'true' ? true : false);

      case TokenType.LeftParen:
        eat(TokenType.LeftParen);
        var node = expr();
        eat(TokenType.RightParen);

        return node;

      case TokenType.Identifier:
        if (lexer.currentChar == '(') {
          return functionCall();
        } else {
          return variable();
        }

      default:
        return empty();
    }

    return empty();
  }

  ExpressionNode level1() {
    var node = factor();

    return node;
  }

  ExpressionNode level2() {
    var node = level1();

    return node;
  }

  ExpressionNode level3() {
    var node = level2();

    while (currentToken.type == TokenType.Asterisk || currentToken.type == TokenType.Slash) {
      var token = currentToken;
      if (token.type == TokenType.Asterisk) {
        eat(TokenType.Asterisk);
      } else if (token.type == TokenType.Slash) {
        eat(TokenType.Slash);
      }

      node = BinOpNode(left: node, token: token, right: level2());
    }

    return node;
  }

  ExpressionNode level4() {
    var node = level3();

    while (currentToken.type == TokenType.Plus || currentToken.type == TokenType.Minus) {
      var token = currentToken;
      if (token.type == TokenType.Plus) {
        eat(TokenType.Plus);
      } else if (token.type == TokenType.Minus) {
        eat(TokenType.Minus);
      }

      node = BinOpNode(left: node, token: token, right: level3());
    }

    return node;
  }

  ExpressionNode level6() {
    var node = level4();
    var token = currentToken;

    switch (token.type) {
      case TokenType.GT:
        eat(TokenType.GT);
        return CompareNode(left: node, token: token, right: level4());
      case TokenType.GTE:
        eat(TokenType.GTE);
        return CompareNode(left: node, token: token, right: level4());
      case TokenType.LT:
        eat(TokenType.LT);
        return CompareNode(left: node, token: token, right: level4());
      case TokenType.LTE:
        eat(TokenType.LTE);
        return CompareNode(left: node, token: token, right: level4());
      case TokenType.Equal:
        eat(TokenType.Equal);
        return CompareNode(left: node, token: token, right: level4());
      case TokenType.NotEqual:
        eat(TokenType.NotEqual);
        return CompareNode(left: node, token: token, right: level4());

      default:
        break;
    }

    return node;
  }

  ExpressionNode level11() {
    var node = level6();

    if (currentToken.type == TokenType.And) {
      var token = currentToken;
      eat(TokenType.And);

      node = BoolOpNode(token: token, left: node, right: level6());
    }

    return node;
  }

  ExpressionNode level12() {
    var node = level11();

    if (currentToken.type == TokenType.Or) {
      var token = currentToken;
      eat(TokenType.Or);

      node = BoolOpNode(token: token, left: node, right: level3());
    }

    return node;
  }

  ExpressionNode expr() {
    return level12();
  }

  VarNode variable() {
    var node = VarNode(token: currentToken, id: currentToken.value);
    eat(TokenType.Identifier);
    return node;
  }

  EmptyOpNode empty() {
    return EmptyOpNode(token: currentToken);
  }
}