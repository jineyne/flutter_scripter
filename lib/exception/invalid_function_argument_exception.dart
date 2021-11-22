import 'package:flutter_scripter/exception/scripter_exception.dart';
import 'package:flutter_scripter/token/token.dart';

enum InvalidFunctionArgumentType {
  few,
  many
}

class InvalidFunctionArgumentsException extends ScripterException {
  InvalidFunctionArgumentType type;

  InvalidFunctionArgumentsException.many(Token token)
      : type = InvalidFunctionArgumentType.many, super(token);
  InvalidFunctionArgumentsException.few(Token token)
      : type = InvalidFunctionArgumentType.few, super(token);

  @override
  String toString() {
    switch (type) {
      case InvalidFunctionArgumentType.few:
        return 'Too few arguments in function call';
      case InvalidFunctionArgumentType.many:
        return 'Too many arguments in function call';
      default:
        return 'Unknown error';
    }
  }
}