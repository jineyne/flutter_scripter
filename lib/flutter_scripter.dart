library flutter_scripter;

import 'package:flutter_scripter/ast/script_node.dart';
import 'package:flutter_scripter/exception/scripter_exception.dart';
import 'package:flutter_scripter/lexer/lexer.dart';
import 'package:flutter_scripter/machine/machine.dart';
import 'package:flutter_scripter/machine/value.dart';
import 'package:flutter_scripter/parser/parser.dart';
import 'package:flutter_scripter/semantic/semantic_analyzer.dart';
import 'package:format/format.dart';

class FlutterScripter {
  var machine = Machine();
  var debugMode = false;

  void enableDebugMode() {
    debugMode = true;
    machine.debugMode = true;
  }

  void setVariable(String name, Value value) {
    machine.setVariable(name, value);
  }

  Value getValue(String name) {
    return machine.getVariable(name);
  }

  /// @copydoc machine.setExternalFunction
  void setExternalFunction(String name, ScriptFunctionType func, int argc) {
    machine.setExternalFunction(name, func, argc);
  }

  /// @copydoc machine.setExternalProcedure
  void setExternalProcedure(String name, ScriptProcedureType func, int argc) {
    machine.setExternalProcedure(name, func, argc);
  }

  Value run(String text) {
    var lexer = Lexer(text: text);
    var parser = Parser(lexer);
    try {
      var root = parser.parse();

      if (parser.isError) {
        print(parser.errorMessage);
        return NullValue();
      }

      var analyzer = SemanticAnalyzer();
      analyzer.apply(machine.globalScope);
      analyzer.visit(root);

      return machine.visit(root);
    } catch (e) {
      return throwException(e, text);
    }
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

      var analyzer = SemanticAnalyzer();
      analyzer.apply(machine.globalScope);
      analyzer.visit(root);

      return machine.visit((root as ScriptNode).compound);
    } catch (e) {
      return throwException(e, text);
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

      var analyzer = SemanticAnalyzer();
      analyzer.apply(machine.globalScope);
      analyzer.visit(root);

      return machine.visit(root);
    } catch (e) {
      return throwException(e, text);
    }
  }

  Value throwException(Object e, String text) {
    if (e is ScripterException) {
      var exception = e as ScripterException;
      var lineNo = exception.lineNo - 1;
      var pos = exception.pos;

      var begin = text.indexOf('\n');
      String line = begin == -1 ? text : text.substring(0, begin);
      while (lineNo > 0 && begin != -1) {
        var end = text.indexOf('\n', begin + 1);
        if (end == -1) {
          // invalid text
          line = '';
          break;
        }

        line = text.substring(begin, end);
        begin = end;
        lineNo--;
      }

      var sb = StringBuffer();
      sb.writeln(exception);
      if (line.isNotEmpty) {
        sb.writeln(line);
        sb.writeln('^'.padLeft(pos));
      }
      sb.writeln(machine.callstack);

      throw Exception(sb.toString());
    } else {
      throw e;
    }
  }
}
