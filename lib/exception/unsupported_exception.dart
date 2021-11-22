import 'package:flutter_scripter/exception/scripter_exception.dart';
import 'package:flutter_scripter/token/token.dart';

class UnSupportedException extends ScripterException {
  UnSupportedException(Token token) : super(token);

  @override
  String toString() {
    return "$lineNo:$pos: '$token' is unsupported";
  }
}