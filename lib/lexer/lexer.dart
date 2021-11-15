import 'package:flutter/material.dart';
import 'package:flutter_scripter/exception/invalid_token_exception.dart';
import 'package:flutter_scripter/token/token.dart';
import 'package:flutter_scripter/token/token_type.dart';
import 'package:flutter_scripter/util/extension/string_extension.dart';

class Lexer {
  static var keyword = <String, TokenType>{
    'var' : TokenType.variable,
    'true' : TokenType.boolean,
    'false' : TokenType.boolean,
  };

  String text;
  String currentChar;
  int pos = 0;

  int lineNo = 1;
  int cursorPos = 1;

  Lexer({required this.text}) : currentChar = text[0];

  void advance() {
    pos += 1;
    cursorPos += 1;

    if (pos >= text.length) {
      currentChar = '';
    } else {
      currentChar = text.characters.elementAt(pos);
    }
  }

  void skipWhitespace() {
    while (currentChar.isSpace() && currentChar != '\n') {
      advance();
    }
  }

  Token identifier() {
    var sb = StringBuffer();

    while (currentChar != '' && (currentChar.isAlphaOrDigit() || currentChar == '_')) {
      sb.write(currentChar);
      advance();
    }

    var id = sb.toString();
    if (keyword.containsKey(id)) {
      return Token.keyword(keyword[id] ?? TokenType.eof, id, lineNo, pos);
    }

    return Token.identifier(id, lineNo, pos);
  }

  Token number() {
    var sb = StringBuffer();

    while (currentChar != '' && currentChar.isDigit()) {
      sb.write(currentChar);
      advance();
    }
    
    return Token.number(double.parse(sb.toString()), lineNo, cursorPos);
  }

  Token string() {
    var sb = StringBuffer();

    // skip "
    advance();

    while (currentChar != '' && currentChar != '"') {
      sb.write(currentChar);
      advance();
    }

    // skip "
    advance();

    return Token.string(sb.toString(), lineNo, cursorPos);
  }

  Token getNextToken() {
    while (currentChar != '') {
      if (currentChar.isSpace()) {
        if (currentChar != '\n') {
          skipWhitespace();
        } else {
          var token = Token(TokenType.eol, lineNo, cursorPos);

          lineNo += 1;
          cursorPos = 0;

          advance();
          return token;
        }
      }

      if (currentChar.isAlpha()) {
        return identifier();
      }

      if (currentChar.isDigit()) {
        return number();
      }

      if (currentChar == '"') {
        return string();
      }

      if (currentChar == '=') {
        var token = makeToken(TokenType.assign);
        advance();

        return token;
      }

      if (currentChar == '+') {
        var token = makeToken(TokenType.plus);
        advance();

        return token;
      }

      if (currentChar == '-') {
        var token = makeToken(TokenType.minus);
        advance();

        return token;
      }

      if (currentChar == '/') {
        var token = makeToken(TokenType.slash);
        advance();

        return token;
      }

      if (currentChar == '*') {
        var token = makeToken(TokenType.asterisk);
        advance();

        return token;
      }

      if (currentChar == '(') {
        var token = makeToken(TokenType.leftParen);
        advance();

        return token;
      }

      if (currentChar == ')') {
        var token = makeToken(TokenType.rightParen);
        advance();

        return token;
      }

      throw InvalidTokenException(Token.unknown(currentChar, lineNo, pos));
    }

    return makeToken(TokenType.eof);
  }

  Token makeToken(TokenType type) {
    return Token(type, lineNo, cursorPos);
  }
}