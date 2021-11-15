import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/expression/assign_op_node.dart';
import 'package:flutter_scripter/ast/expression/bin_op_node.dart';
import 'package:flutter_scripter/ast/expression/boolean_node.dart';
import 'package:flutter_scripter/ast/expression/empty_op_node.dart';
import 'package:flutter_scripter/ast/expression/number_node.dart';
import 'package:flutter_scripter/ast/expression/string_node.dart';
import 'package:flutter_scripter/ast/expression/unary_op_node.dart';
import 'package:flutter_scripter/ast/expression/var_decl_node.dart';
import 'package:flutter_scripter/ast/expression/var_node.dart';
import 'package:flutter_scripter/ast/expression_node.dart';
import 'package:flutter_scripter/ast/statement/compound_node.dart';
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
    return compoundStatement();
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

  ASTNode statement() {
    switch (currentToken.type) {
      case TokenType.identifier: return assignmentStatement();
      case TokenType.variable: return varDeclStatement();
      default: return empty();
    }
  }

  List<ASTNode> statementList() {
    var result = <ASTNode>[];
    result.add(statement());

    while (currentToken.type == TokenType.eol) {
      eat(TokenType.eol);
      result.add(statement());
    }

    if (currentToken.type == TokenType.identifier) {
      error('Invalid identifier');
    }

    return result;
  }

  ASTNode compoundStatement() {
    var token = currentToken;
    // TODO: {} 확인하기
    var nodes = statementList();

    return CompoundNode(token: token, children: nodes);
  }

  VarDeclNode varDeclStatement() {
    var token = currentToken;
    eat(TokenType.variable);

    var id = variable();

    eat(TokenType.assign);
    var initializer = expr();

    return VarDeclNode(variable: id, token: token, initializer: initializer);
  }

  AssignOpNode assignmentStatement() {
    var left = variable();
    var token = currentToken;
    eat(TokenType.assign);
    var right = expr();

    return AssignOpNode(left: left, token: token, right: right);
  }

  ExpressionNode factor() {
    var token = currentToken;
    if (token.type == TokenType.plus) {
      eat(TokenType.plus);
      return UnaryOpNode(token: token, expr: factor());
    } else if (token.type == TokenType.minus) {
      eat(TokenType.minus);
      return UnaryOpNode(token: token, expr: factor());
    } else if (token.type == TokenType.number) {
      eat(TokenType.number);
      return NumberNode(token: token);
    } else if (token.type == TokenType.string) {
      eat(TokenType.string);
      return StringNode(token: token, value: token.value);
    } else if (token.type == TokenType.boolean) {
      eat(TokenType.boolean);
      return BooleanNode(token: token, value: token.value == 'true' ? true : false);
    } else if (token.type == TokenType.leftParen) {
      eat(TokenType.leftParen);
      var node = expr();
      eat(TokenType.rightParen);

      return node;
    } else if (token.type == TokenType.identifier) {
      return variable();
    }

    return empty();
  }

  ExpressionNode term() {
    var node = factor();

    while (currentToken.type == TokenType.asterisk || currentToken.type == TokenType.slash) {
      var token = currentToken;
      if (token.type == TokenType.asterisk) {
        eat(TokenType.asterisk);
      } else if (token.type == TokenType.slash) {
        eat(TokenType.slash);
      }

      node = BinOpNode(left: node, token: token, right: factor());
    }

    return node;
  }

  ExpressionNode expr() {
    var node = term();

    while (currentToken.type == TokenType.plus || currentToken.type == TokenType.minus) {
      var token = currentToken;
      if (token.type == TokenType.plus) {
        eat(TokenType.plus);
      } else if (token.type == TokenType.minus) {
        eat(TokenType.minus);
      }

      node = BinOpNode(left: node, token: token, right: term());
    }

    return node;
  }

  VarNode variable() {
    var node = VarNode(token: currentToken, id: currentToken.value);
    eat(TokenType.identifier);
    return node;
  }

  EmptyOpNode empty() {
    return EmptyOpNode(token: currentToken);
  }
}