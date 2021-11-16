import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/expression/assign_op_node.dart';
import 'package:flutter_scripter/ast/expression/bin_op_node.dart';
import 'package:flutter_scripter/ast/expression/bool_op_node.dart';
import 'package:flutter_scripter/ast/expression/boolean_node.dart';
import 'package:flutter_scripter/ast/expression/compare_node.dart';
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
    switch (token.type) {
      case TokenType.plus:
        eat(TokenType.plus);
        return UnaryOpNode(token: token, expr: factor());
      case TokenType.minus:
        eat(TokenType.minus);
        return UnaryOpNode(token: token, expr: factor());

      case TokenType.number:
        eat(TokenType.number);
        return NumberNode(token: token);
      case TokenType.string:
        eat(TokenType.string);
        return StringNode(token: token, value: token.value);
      case TokenType.boolean:
        eat(TokenType.boolean);
        return BooleanNode(token: token, value: token.value == 'true' ? true : false);

      case TokenType.leftParen:
        eat(TokenType.leftParen);
        var node = expr();
        eat(TokenType.rightParen);

        return node;

      case TokenType.identifier:
        return variable();

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

    while (currentToken.type == TokenType.asterisk || currentToken.type == TokenType.slash) {
      var token = currentToken;
      if (token.type == TokenType.asterisk) {
        eat(TokenType.asterisk);
      } else if (token.type == TokenType.slash) {
        eat(TokenType.slash);
      }

      node = BinOpNode(left: node, token: token, right: level2());
    }

    return node;
  }

  ExpressionNode level4() {
    var node = level3();

    while (currentToken.type == TokenType.plus || currentToken.type == TokenType.minus) {
      var token = currentToken;
      if (token.type == TokenType.plus) {
        eat(TokenType.plus);
      } else if (token.type == TokenType.minus) {
        eat(TokenType.minus);
      }

      node = BinOpNode(left: node, token: token, right: level3());
    }

    return node;
  }

  ExpressionNode level6() {
    var node = level4();
    var token = currentToken;

    switch (token.type) {
      case TokenType.gt:
        eat(TokenType.gt);
        return CompareNode(left: node, token: token, right: level4());
      case TokenType.gte:
        eat(TokenType.gte);
        return CompareNode(left: node, token: token, right: level4());
      case TokenType.lt:
        eat(TokenType.lt);
        return CompareNode(left: node, token: token, right: level4());
      case TokenType.lte:
        eat(TokenType.lte);
        return CompareNode(left: node, token: token, right: level4());
      case TokenType.equal:
        eat(TokenType.equal);
        return CompareNode(left: node, token: token, right: level4());
      case TokenType.notEqual:
        eat(TokenType.notEqual);
        return CompareNode(left: node, token: token, right: level4());

      default:
        break;
    }

    return node;
  }

  ExpressionNode level11() {
    var node = level6();

    if (currentToken.type == TokenType.and) {
      var token = currentToken;
      eat(TokenType.and);

      node = BoolOpNode(token: token, left: node, right: level6());
    }

    return node;
  }

  ExpressionNode level12() {
    var node = level11();

    if (currentToken.type == TokenType.or) {
      var token = currentToken;
      eat(TokenType.or);

      node = BoolOpNode(token: token, left: node, right: level3());
    }

    return node;
  }

  ExpressionNode expr() {
    return level12();
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