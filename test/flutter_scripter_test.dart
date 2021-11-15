import 'package:flutter_scripter/exception/invalid_token_exception.dart';
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

void main() {
  test_lexer();
}
