library flutter_scripter;

import 'package:flutter_scripter/lexer/lexer.dart';
import 'package:flutter_scripter/machine/machine.dart';
import 'package:flutter_scripter/machine/value.dart';
import 'package:flutter_scripter/parser/parser.dart';

class FlutterScripter {
  var machine = Machine();

  void setVariable(String name, Value value) {
    machine.setVariable(name, value);
  }

  Value getValue(String name) {
    return machine.getVariable(name);
  }

  Value execute(String text) {
    var lexer = Lexer(text: text);
    var parser = Parser(lexer);
    try {
      var root = parser.parse();

      if (parser.isError) {
        print(parser.errorMessage);
        return NullValue();
      }

      return machine.visit(root);
    } catch (e) {
      print(e.toString());
      return NullValue();
    }
  }

  Value eval(String text) {
    var lexer = Lexer(text: text);
    var parser = Parser(lexer);
    try {
      var root = parser.expr();

      if (parser.isError) {
        print(parser.errorMessage);
        return NullValue();
      }

      return machine.visit(root);
    } catch (e) {
      print(e.toString());
      return NullValue();
    }
  }
}
