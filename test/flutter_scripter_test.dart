import 'package:flutter_scripter/ast/expression/bin_op_node.dart';
import 'package:flutter_scripter/ast/expression/number_node.dart';
import 'package:flutter_scripter/ast/expression/unary_op_node.dart';
import 'package:flutter_scripter/ast/script_node.dart';
import 'package:flutter_scripter/ast/statement/if_node.dart';
import 'package:flutter_scripter/ast/statement/var_decl_node.dart';
import 'package:flutter_scripter/ast/statement/compound_node.dart';
import 'package:flutter_scripter/exception/already_defined_exception.dart';
import 'package:flutter_scripter/exception/invalid_cast_exception.dart';
import 'package:flutter_scripter/exception/invalid_token_exception.dart';
import 'package:flutter_scripter/exception/undefined_exception.dart';
import 'package:flutter_scripter/flutter_scripter.dart';
import 'package:flutter_scripter/lexer/lexer.dart';
import 'package:flutter_scripter/machine/activation_record.dart';
import 'package:flutter_scripter/machine/callstack.dart';
import 'package:flutter_scripter/machine/machine.dart';
import 'package:flutter_scripter/machine/value.dart';
import 'package:flutter_scripter/parser/parser.dart';
import 'package:flutter_scripter/semantic/semantic_analyzer.dart';
import 'package:flutter_scripter/semantic/symbol_table/scoped_symbol_table.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbol_table.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbols/built_in_symbol.dart';
import 'package:flutter_scripter/semantic/symbol_table/symbols/var_symbol.dart';
import 'package:flutter_scripter/token/token_type.dart';
import 'package:flutter_test/flutter_test.dart';

void test_lexer() {
  test('test lexer for lexing text', () {
    var lexer = Lexer(text: '"text for test"');

    var token = lexer.getNextToken();
    expect(token.type, TokenType.String);
    expect(token.value, "text for test");
  });

  test('test lexer for lexing exp', () {
    var lexer = Lexer(text: '5 + 1');

    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.Plus);
    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.EOF);
  });

  test('test lexer for lexing complicate exp', () {
    var lexer = Lexer(text: '5 + (1 * 10)');

    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.Plus);
    expect(lexer.getNextToken().type, TokenType.LeftParen);
    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.Asterisk);
    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.RightParen);
    expect(lexer.getNextToken().type, TokenType.EOF);
  });

  test('test lexer for multi-line exp', (){
    var lexer = Lexer(text: '''
5 + 1
2 + 3
''');

    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.Plus);
    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.EOL);
    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.Plus);
    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.EOL);
  });

  test('test lexer for invalid token', () {
    var lexer = Lexer(text: '''
5 + 1
2 + 3^
''');

    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.Plus);
    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.EOL);
    expect(lexer.getNextToken().type, TokenType.Number);
    expect(lexer.getNextToken().type, TokenType.Plus);
    expect(lexer.getNextToken().type, TokenType.Number);
    expect(() => lexer.getNextToken(), throwsA(isA<InvalidTokenException>()));
  });
}

void test_parser() {
  test('test parser #1', () {
    var lexer = Lexer(text: '5 + 1');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(root is BinOpNode, true);

    var binOp = root as BinOpNode;
    expect(binOp.left is NumberNode, true);
    expect(binOp.right is NumberNode, true);
  });

  test('test parser #2', () {
    var lexer = Lexer(text: '5 + (2 * 10)');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(parser.isError, false);
    expect(root is BinOpNode, true);

    var binOp = root as BinOpNode;
    expect(binOp.left is NumberNode, true);
    expect(binOp.right is BinOpNode, true);

    var paren = binOp.right as BinOpNode;
  });

  test('test parser #3', () {
    var lexer = Lexer(text: '-3');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(parser.isError, false);
    expect(root is UnaryOpNode, true);
  });

  test('test parser #4', () {
    var lexer = Lexer(text: '''
var a = 5 + 1
var b = 2 + a
''');
    var parser = Parser(lexer);
    var root = parser.parse();
    expect(parser.isError, false);
    expect(root is ScriptNode, true);

    var script = root as ScriptNode;
    var compound = script.compound;
    expect(compound.children.length, 3);

    expect(compound.children[0] is VarDeclNode, true);
    expect(compound.children[1] is VarDeclNode, true);
  });

  test('test parser #5', () {
    var lexer = Lexer(text: '''
var a = 5 + 1
var b = 2 + sin(a)
cos(b)
''');
    var parser = Parser(lexer);
    var root = parser.parse();
    expect(parser.isError, false);
    expect(root is ScriptNode, true);

    var script = root as ScriptNode;
    var compound = script.compound;
    expect(compound.children.length, 4);
    expect(compound.children[0] is VarDeclNode, true);
    expect(compound.children[1] is VarDeclNode, true);
  });

  test('test parser if statement', () {
    var lexer = Lexer(text: '''
var a = 10
var b = 20
if (a == 10) b = 30
''');
    var parser = Parser(lexer);
    var root = parser.parse();
    expect(parser.isError, false);
    expect(root is ScriptNode, true);

    var script = root as ScriptNode;
    var compound = script.compound;
    expect(compound.children.length, 4);
    expect(compound.children[0] is VarDeclNode, true);
    expect(compound.children[1] is VarDeclNode, true);
    expect(compound.children[2] is IfNode, true);
  });
}
void test_machine() {
  test('test machine #1', () {
    var lexer = Lexer(text: '5 + 1');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(root is BinOpNode, true);

    var machine = Machine();
    var value = machine.visit(root);

    expect(value.isNumber, true);
    expect((value as NumberValue).value, 6);
  });

  test('test machine #2', () {
    var lexer = Lexer(text: '7 + 3 * (10 / (12 / (3 + 1) - 1))');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(root is BinOpNode, true);

    var machine = Machine();
    var value = machine.visit(root);

    expect(value.isNumber, true);
    expect((value as NumberValue).value, 22);
  });

  test('test machine for unary op', () {
    var lexer = Lexer(text: '5 - - - + - (3 + 4) - +2');
    var parser = Parser(lexer);

    var root = parser.expr();
    expect(root is BinOpNode, true);

    var machine = Machine();
    var value = machine.visit(root);

    expect(value.isNumber, true);
    expect((value as NumberValue).value, 10);
  });

  test('test machine for var', () {
    var lexer = Lexer(text: '''
var a = 5 + 1
var b = 2 + a
var c = false
var d = true
''');
    var parser = Parser(lexer);
    var root = parser.parse();
    expect(root is ScriptNode, true);

    var machine = Machine();
    var result = machine.visit((root as ScriptNode).compound);

    var scope = machine.globalScope;
    expect(scope.length, 4);
    expect((scope['a'] as NumberValue).value, 6);
    expect((scope['b'] as NumberValue).value, 8);
    expect((scope['c'] as BooleanValue).value, false);
    expect((scope['d'] as BooleanValue).value, true);
  });

  test('test machine for var', () {
    var lexer = Lexer(text: '''
var b = 2 + a
''');
    var parser = Parser(lexer);
    var root = parser.parse();
    expect(parser.isError, false);
    expect(root is ScriptNode, true);

    var machine = Machine();
    machine.setVariable('a', NumberValue(6));
    var result = machine.visit((root as ScriptNode).compound);

    var scope = machine.globalScope;
    expect(scope.length, 2);
    expect((scope['a'] as NumberValue).value, 6);
    expect((scope['b'] as NumberValue).value, 8);
  });

  test('test machine for string binop', () {
    var lexer = Lexer(text: '''
var a = "test"
var b = "string"
var c = a + " " + b
''');
    var parser = Parser(lexer);
    var root = parser.parse();

    expect(parser.isError, false);
    expect(root is ScriptNode, true);

    var machine = Machine();
    var result = machine.visit((root as ScriptNode).compound);
    expect(result is StringValue, true);
    expect((result as StringValue).value, 'test string');
  });

  test('test machine for var excpetion', () {
    var lexer = Lexer(text: '''
var a = 5 + 1
var b = 2 + a
var a = false
''');
    var parser = Parser(lexer);
    var root = parser.parse();

    expect(root is ScriptNode, true);

    var machine = Machine();
    expect(() => machine.visit(root), throwsA(isA<AlreadyDefinedException>()));
  });

  test('test machine for invalid cast excpetion', () {
    var lexer = Lexer(text: '''
var a = "test value"
var b = 2 + a
''');
    var parser = Parser(lexer);
    var root = parser.parse();

    expect(parser.isError, false);
    expect(root is ScriptNode, true);

    var machine = Machine();
    expect(() => machine.visit(root), throwsA(isA<InvalidCastException>()));
  });
}

void test_scripter() {
  test('test scripter #1', () {
    var scripter = FlutterScripter();
    var result = scripter.eval('5 + 2');

    expect(result is NumberValue, true);
    expect((result as NumberValue).value, 7);
  });

  test('test scripter #2', () {
    var scripter = FlutterScripter();
    var result = scripter.execute('var a = 5 + 2');

    expect(result is NumberValue, true);
    expect((result as NumberValue).value, 7);
  });

  test('test scripter #3', () {
    var scripter = FlutterScripter();
    var result = scripter.execute('var a = 5 + 2');
    expect(result is NumberValue, true);
    expect((result as NumberValue).value, 7);

    result = scripter.eval('3 + a');
    expect(result is NumberValue, true);
    expect((result as NumberValue).value, 10);
  });

  test('test scripter #4', () {
    var scripter = FlutterScripter();
    var result = scripter.execute('''
var a = false
var b = true
var equalTest = a && b
''');

    expect(result is BooleanValue, true);
    expect((result as BooleanValue).value, false);
  });

  test('test scripter #5', () {
    var scripter = FlutterScripter();
    var result = scripter.execute('''
var a = 10
var b = 20
var gt = a > b
var gte = a >= b
var lt = a < b
var lte = a <= b
var eq = a == b
var neq = a != b
''');

    var valueTest = (String name, bool expectValue) {
      var v = scripter.getValue(name);
      expect(v is BooleanValue, true);
      expect((v as BooleanValue).value, expectValue);
    };

    valueTest('gt', false);
    valueTest('gte', false);
    valueTest('lt', true);
    valueTest('lte', true);
    valueTest('eq', false);
    valueTest('neq', true);

    result = scripter.eval('!eq');
    expect(result is BooleanValue, true);
    expect((result as BooleanValue).value, true);
  });

  test('test scripter #6', () {
    var scripter = FlutterScripter();
    var result = scripter.execute('''
var a = 10
var b = 0

if (a == 10) b = 10
else b = 20
''');

    var value = scripter.getValue('b');
    expect(value is NumberValue, true);
    expect((value as NumberValue).value, 10);

    result = scripter.execute('''
if (a < 5) {
  b = 5
} else if (a < 10) {
  b = 10
} else if (a < 15) {
  b = 20
}
''');

    value = scripter.getValue('b');
    expect(value is NumberValue, true);
    expect((value as NumberValue).value, 20);
  });

  test('test scripter #7', () {
    var scripter = FlutterScripter();
    scripter.enableDebugMode();

    scripter.setExternalProcedure('foo', (args) => print(args[0]), 1);
    scripter.setExternalFunction('bar', (args) => args[0], 1);

    var result = scripter.run('''
var a = 10
var b = 0
foo(a)
b = bar(a)
''');

    var value = scripter.getValue('b');
    expect(value is NumberValue, true);
    expect((value as NumberValue).value, 10);
  });
}

void test_symbol() {
  test('test symbol table #1', () {
    var lexer = Lexer(text: '''
var a = 10
var b = 0
if (a == 10) {
  b = 10
} else var c = false
''');
    var parser = Parser(lexer);
    var root = parser.parse();

    var analyzer = SemanticAnalyzer();
    var result = analyzer.visit(root);
  });

  test('test symbol table #1', () {
    var lexer = Lexer(text: '''
var a = 10
var b = 0
if (a == 10) {
  b = 10
} else var c = false
c = true
''');
    var parser = Parser(lexer);
    var root = parser.parse();

    var analyzer = SemanticAnalyzer();
    expect(() => analyzer.visit(root), throwsA(isA<UndefinedException>()));
  });

  test('test symbol table #2', () {
    var lexer = Lexer(text: '''
var a = 10
var b = 0
foo(a)
''');
    var parser = Parser(lexer);
    var root = parser.parse();

    // TODO: set

    var analyzer = SemanticAnalyzer();
    expect(() => analyzer.visit(root), throwsA(isA<UndefinedException>()));
  });
}

void test_stack() {
  test('test stack #1', () {
    var scripter = FlutterScripter();
    scripter.enableDebugMode();
    scripter.setVariable('a', NumberValue(10));

    scripter.run('''
var b = a * 10
''');
  });
}

void main() {
  test_lexer();
  test_parser();
  test_machine();
  test_scripter();
  test_symbol();
  test_stack();
}
