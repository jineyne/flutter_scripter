import 'package:flutter_scripter/exception/scripter_exception.dart';
import 'package:flutter_scripter/token/token.dart';

class InvalidCastException extends ScripterException {
  InvalidCastException(Token token) : super(token);

  @override
  String toString() {
    return '$lineNo:$pos: Invalid cast';
  }
}