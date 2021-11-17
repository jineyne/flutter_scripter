import 'package:flutter/material.dart';
import 'package:flutter_scripter/exception/invalid_token_exception.dart';
import 'package:flutter_scripter/token/token.dart';
import 'package:flutter_scripter/token/token_type.dart';
import 'package:flutter_scripter/util/extension/string_extension.dart';

class Lexer {
  static var keyword = <String, TokenType>{
    'var' : TokenType.Variable,
    'if' : TokenType.If,
    'else' : TokenType.Else,
    'true' : TokenType.Boolean,
    'false' : TokenType.Boolean,
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
      currentChar = text[pos];
    }
  }

  String peek() {
    var peekPos = pos + 1;
    if (peekPos >= text.length) {
      return  '';
    } else {
      return text.characters.elementAt(peekPos);
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
      return Token.keyword(keyword[id] ?? TokenType.EOF, id, lineNo, pos);
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
          var token = Token(TokenType.EOL, lineNo, cursorPos);

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
        if (peek() == '=') {
          var token = makeToken(TokenType.Equal);
          advance();
          advance();

          return token;
        }

        var token = makeToken(TokenType.Assign);
        advance();

        return token;
      }

      if (currentChar == '!') {
        if (peek() == '=') {
          var token = makeToken(TokenType.NotEqual);
          advance();
          advance();

          return token;
        }

        var token = makeToken(TokenType.Exclamation);
        advance();

        return token;
      }

      if (currentChar == '<') {
        if (peek() == '=') {
          var token = makeToken(TokenType.LTE);
          advance();
          advance();

          return token;
        }

        var token = makeToken(TokenType.LT);
        advance();

        return token;
      }
      if (currentChar == '>') {
        if (peek() == '=') {
          var token = makeToken(TokenType.GTE);
          advance();
          advance();

          return token;
        }

        var token = makeToken(TokenType.GT);
        advance();

        return token;
      }

      if (currentChar == '+') {
        var token = makeToken(TokenType.Plus);
        advance();

        return token;
      }

      if (currentChar == '-') {
        var token = makeToken(TokenType.Minus);
        advance();

        return token;
      }

      if (currentChar == '/') {
        var token = makeToken(TokenType.Slash);
        advance();

        return token;
      }

      if (currentChar == '*') {
        var token = makeToken(TokenType.Asterisk);
        advance();

        return token;
      }

      if (currentChar == '&') {
        if (peek() == '&') {
          var token = makeToken(TokenType.And);
          advance();
          advance();

          return token;
        }
      }

      if (currentChar == '|') {
        if (peek() == '|') {
          var token = makeToken(TokenType.Or);
          advance();
          advance();

          return token;
        }
      }

      if (currentChar == '(') {
        var token = makeToken(TokenType.LeftParen);
        advance();

        return token;
      }

      if (currentChar == ')') {
        var token = makeToken(TokenType.RightParen);
        advance();

        return token;
      }

      if (currentChar == '{') {
        var token = makeToken(TokenType.LeftBracket);
        advance();

        return token;
      }

      if (currentChar == '}') {
        var token = makeToken(TokenType.RightBracket);
        advance();

        return token;
      }

      throw InvalidTokenException(Token.unknown(currentChar, lineNo, pos));
    }

    return makeToken(TokenType.EOF);
  }

  Token makeToken(TokenType type) {
    return Token(type, lineNo, cursorPos);
  }
}