import 'package:flutter_scripter/exception/invalid_token_exception.dart';
import 'package:flutter_scripter/machine/machine.dart';
import 'package:flutter_scripter/machine/value.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_scripter/flutter_scripter.dart';

void test_lexer() {
  test('test lexer for lexing text', () {
    var lexer = Lexer(text: '"text for test"');

    var token = lexer.getNextToken();
    expect(token.type, TokenType.string);
    expect(token.value, "text for test");
  });

  test('test lexer for lexing exp', () {
    var lexer = Lexer(text: '5 + 1');

    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.plus);
    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.eof);
  });

  test('test lexer for lexing complicate exp', () {
    var lexer = Lexer(text: '5 + (1 * 10)');

    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.plus);
    expect(lexer.getNextToken().type, TokenType.leftParen);
    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.asterisk);
    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.rightParen);
    expect(lexer.getNextToken().type, TokenType.eof);
  });

  test('test lexer for multi-line exp', (){
    var lexer = Lexer(text: '''
5 + 1
2 + 3
''');

    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.plus);
    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.eol);
    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.plus);
    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.eol);
  });

  test('test lexer for invalid token', () {
    var lexer = Lexer(text: '''
5 + 1
2 + 3^
''');

    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.plus);
    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.eol);
    expect(lexer.getNextToken().type, TokenType.number);
    expect(lexer.getNextToken().type, TokenType.plus);
    expect(lexer.getNextToken().type, TokenType.number);
    expect(() => lexer.getNextToken(), throwsA(isA<InvalidTokenException>()));
  });
}

void test_parser() {
  test('test parser #1', () {
    var lexer = Lexer(text: '5 + 1');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(root is BinOpNode, true);

    var binOp = root as BinOpNode;
    expect(binOp.left is NumberNode, true);
    expect(binOp.right is NumberNode, true);
  });

  test('test parser #2', () {
    var lexer = Lexer(text: '5 + (2 * 10)');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(parser.isError, false);
    expect(root is BinOpNode, true);

    var binOp = root as BinOpNode;
    expect(binOp.left is NumberNode, true);
    expect(binOp.right is BinOpNode, true);

    var paren = binOp.right as BinOpNode;
  });

  test('test parser #3', () {
    var lexer = Lexer(text: '-3');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(parser.isError, false);
    expect(root is UnaryOpNode, true);
  });

  test('test parser #4', () {
    var lexer = Lexer(text: '''
var a = 5 + 1
var b = 2 + a
''');
    var parser = Parser(lexer);
    var root = parser.parse();
    expect(parser.isError, false);

    expect(root is CompoundNode, true);

    var compound = root as CompoundNode;
    expect(compound.children.length, 3);

    expect(compound.children[0] is VarDeclNode, true);
    expect(compound.children[1] is VarDeclNode, true);
  });
}
void test_machine() {
  test('test machine #1', () {
    var lexer = Lexer(text: '5 + 1');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(root is BinOpNode, true);

    var machine = Machine();
    var value = machine.visit(root);

    expect(value.isNumber, true);
    expect((value as NumberValue).value, 6);
  });

  test('test machine #2', () {
    var lexer = Lexer(text: '7 + 3 * (10 / (12 / (3 + 1) - 1))');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(root is BinOpNode, true);

    var machine = Machine();
    var value = machine.visit(root);

    expect(value.isNumber, true);
    expect((value as NumberValue).value, 22);
  });

  test('test machine for unary op', () {
    var lexer = Lexer(text: '5 - - - + - (3 + 4) - +2');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(root is BinOpNode, true);

    var machine = Machine();
    var value = machine.visit(root);

    expect(value.isNumber, true);
    expect((value as NumberValue).value, 10);
  });

  test('test machine for var', () {
    var lexer = Lexer(text: '''
var a = 5 + 1
var b = 2 + a
var c = false
var d = true
''');
    var parser = Parser(lexer);
    var root = parser.parse();

    expect(root is CompoundNode, true);

    var machine = Machine();
    var result = machine.visit(root);

    var stack = machine.stackFrame.top;
    expect(stack.scope.length, 4);
    expect((stack.scope['a'] as NumberValue).value, 6);
    expect((stack.scope['b'] as NumberValue).value, 8);
    expect((stack.scope['c'] as BooleanValue).value, false);
    expect((stack.scope['d'] as BooleanValue).value, true);
  });

  test('test machine for var excpetion', () {
    var lexer = Lexer(text: '''
var a = 5 + 1
var b = 2 + a
var a = false
''');
    var parser = Parser(lexer);
    var root = parser.parse();

    expect(root is CompoundNode, true);

    var machine = Machine();
    expect(() => machine.visit(root), throwsA(isA<InvalidVarException>()));
  });
}

void main() {
  test_lexer();
  test_parser();
  test_machine();
}
