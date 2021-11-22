import 'package:flutter_scripter/exception/scripter_exception.dart';
import 'package:flutter_scripter/token/token.dart';

class AlreadyDefinedException extends ScripterException {
  String id;

  AlreadyDefinedException(Token token, this.id) : super(token);

  @override
  String toString() {
    return "lineNo:$pos: '$id' is already defined";
  }
}
