import 'package:flutter_scripter/exception/scripter_exception.dart';
import 'package:flutter_scripter/token/token.dart';

class UndefinedException extends ScripterException {
  String id;

  UndefinedException(Token token, this.id) : super(token);

  @override
  String toString() {
    return "$lineNo:$pos: '$id' is undefined";
  }
}