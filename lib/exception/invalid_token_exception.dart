import 'package:flutter_scripter/exception/scripter_exception.dart';
import 'package:flutter_scripter/token/token.dart';

class InvalidTokenException extends ScripterException {
  InvalidTokenException(Token token) : super(token);

  @override
  String toString() {
    return "$lineNo:$pos: Invalid token '$token'";
  }
}
