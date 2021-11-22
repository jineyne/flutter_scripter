import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/ast_visitor.dart';
import 'package:flutter_scripter/ast/expression/function_call_node.dart';
import 'package:flutter_scripter/ast/script_node.dart';
import 'package:flutter_scripter/ast/statement/assign_node.dart';
import 'package:flutter_scripter/ast/expression/bin_op_node.dart';
import 'package:flutter_scripter/ast/expression/bool_op_node.dart';
import 'package:flutter_scripter/ast/expression/boolean_node.dart';
import 'package:flutter_scripter/ast/expression/compare_node.dart';
import 'package:flutter_scripter/ast/expression/empty_op_node.dart';
import 'package:flutter_scripter/ast/expression/number_node.dart';
import 'package:flutter_scripter/ast/expression/string_node.dart';
import 'package:flutter_scripter/ast/expression/unary_op_node.dart';
import 'package:flutter_scripter/ast/statement/block_compound_node.dart';
import 'package:flutter_scripter/ast/statement/expr_statement_node.dart';
import 'package:flutter_scripter/ast/statement/if_node.dart';
import 'package:flutter_scripter/ast/statement/procedure_call_node.dart';
import 'package:flutter_scripter/ast/statement/var_decl_node.dart';
import 'package:flutter_scripter/ast/expression/var_node.dart';
import 'package:flutter_scripter/ast/statement/compound_node.dart';
import 'package:flutter_scripter/exception/already_defined_exception.dart';
import 'package:flutter_scripter/exception/invalid_cast_exception.dart';
import 'package:flutter_scripter/exception/invalid_operation_exception.dart';
import 'package:flutter_scripter/exception/invalid_token_exception.dart';
import 'package:flutter_scripter/exception/undefined_exception.dart';
import 'package:flutter_scripter/exception/unsupported_exception.dart';
import 'package:flutter_scripter/machine/activation_record.dart';
import 'package:flutter_scripter/machine/callstack.dart';
import 'package:flutter_scripter/machine/stack_frame.dart';
import 'package:flutter_scripter/machine/value.dart';
import 'package:flutter_scripter/token/token.dart';
import 'package:flutter_scripter/token/token_type.dart';
import 'package:flutter_scripter/util/container/stack.dart';

class Machine extends ASTVisitor<Value> {
  var callstack = CallStack();
  var globalScope = <String, Value>{};

  var debugMode = false;

  Machine() {
  }

  void log(String text) {
    if (debugMode) {
      print(text);
    }
  }

  Value run(ASTNode root) {
    try {
      return visit(root);
    } catch (e) {
      print(e.toString());

      return NullValue();
    }
  }

  Value getVariable(String name) {
    if (!globalScope.containsKey(name)) {
      throw ArgumentError("'$name' is not variable");
    }

    return globalScope[name] ?? NullValue();
  }

  void setVariable(String name, Value value) {
    globalScope[name] = value;
  }

  /// set dart function to scripter.
  ///
  /// @param name function name
  /// @param func function callback
  /// @param argc function argument count
  void setExternalFunction(String name, ScriptFunctionType func, int argc) {
    globalScope[name] = ExternalFunctionValue(func, argc);
  }

  /// set dart procedure to scripter.
  ///
  /// @param name function name
  /// @param func function callback
  /// @param argc function argument count
  void setExternalProcedure(String name, ScriptProcedureType func, int argc) {
    globalScope[name] = ExternalProcedureValue(func, argc);
  }

  Value visitBoolean(BooleanNode boolean) {
    return BooleanValue(boolean.value);
  }

  Value visitNumber(NumberNode number) {
    return NumberValue(number.value);
  }

  Value visitString(StringNode string) {
    return StringValue(string.value);
  }

  Value visitBinOp(BinOpNode binOp) {
    var left = visit(binOp.left);
    var right = visit(binOp.right);

    if (left.isNumber && right.isNumber) {
      var leftValue = (left as NumberValue).value;
      var rightValue = (right as NumberValue).value;

      switch (binOp.token.type) {
        case TokenType.Plus: return NumberValue(leftValue + rightValue);
        case TokenType.Minus: return NumberValue(leftValue - rightValue);
        case TokenType.Asterisk: return NumberValue(leftValue * rightValue);
        case TokenType.Slash: return NumberValue(leftValue / rightValue);
        default: throw InvalidOperationException(binOp.token);
      }
    } else if (left.isString && right.isString) {
      var leftValue = (left as StringValue).value;
      var rightValue = (right as StringValue).value;

      switch (binOp.token.type) {
        case TokenType.Plus: return StringValue(leftValue + rightValue);
        default: throw InvalidOperationException(binOp.token);
      }
    }

    throw InvalidCastException(binOp.token);
    return NullValue();
  }

  Value visitBoolOp(BoolOpNode boolOp) {
    var left = visit(boolOp.left);
    var right = visit(boolOp.right);

    if (!left.isBoolean || !right.isBoolean) {
      throw InvalidCastException(boolOp.op);
    }

    var leftValue = (left as BooleanValue).value;
    var rightValue = (right as BooleanValue).value;

    switch (boolOp.type) {
      case TokenType.And:
        return BooleanValue(leftValue && rightValue);

      case TokenType.Or:
        return BooleanValue(leftValue || rightValue);

      default:
        throw InvalidOperationException(boolOp.op);
    }
  }

  Value visitCompare(CompareNode compare) {
    var left = visit(compare.left);
    var right = visit(compare.right);

    if (left.isNumber && right.isNumber) {
      var leftValue = (left as NumberValue).value;
      var rightValue = (right as NumberValue).value;

      switch (compare.type) {
        case TokenType.GT:
          return BooleanValue(leftValue > rightValue);
        case TokenType.GTE:
          return BooleanValue(leftValue >= rightValue);
        case TokenType.LT:
          return BooleanValue(leftValue < rightValue);
        case TokenType.LTE:
          return BooleanValue(leftValue <= rightValue);
        case TokenType.Equal:
          return BooleanValue(leftValue == rightValue);
        case TokenType.NotEqual:
          return BooleanValue(leftValue != rightValue);
        default:
          throw InvalidOperationException(compare.op);
      }
    } else if (left.isString && right.isString) {
      var leftValue = (left as StringValue).value;
      var rightValue = (right as StringValue).value;

      switch (compare.type) {
        case TokenType.Equal:
          return BooleanValue(leftValue == rightValue);
        case TokenType.NotEqual:
          return BooleanValue(leftValue != rightValue);
        default:
          throw InvalidOperationException(compare.op);
      }
    } else if (left.isBoolean && right.isBoolean) {
      var leftValue = (left as BooleanValue).value;
      var rightValue = (right as BooleanValue).value;

      switch (compare.type) {
        case TokenType.Equal:
          return BooleanValue(leftValue == rightValue);
        case TokenType.NotEqual:
          return BooleanValue(leftValue != rightValue);
        default:
          throw InvalidOperationException(compare.op);
      }
    }

    throw InvalidCastException(compare.op);
  }

  Value visitUnaryOp(UnaryOpNode unaryOp) {
    var data = visit(unaryOp.expr);

    if (data.isNumber) {
      var value = (data as NumberValue).value;

      switch (unaryOp.token.type) {
        case TokenType.Plus: return NumberValue(value);
        case TokenType.Minus: return NumberValue(-value);
        default: throw InvalidOperationException(unaryOp.token);
      }
    } else if (data.isBoolean) {
      var value = (data as BooleanValue).value;

      switch (unaryOp.token.type) {
        case TokenType.Exclamation: return BooleanValue(!value);
        default: throw InvalidOperationException(unaryOp.token);
      }
    }

    return NullValue();
  }

  Value visitVarDecl(VarDeclNode varDecl) {
    var variable = varDecl.variable as VarNode;
    var value = visit(varDecl.initializer);

    var ar = callstack.top;
    if (ar != null) {
      if (ar.containsKey(variable.id)) {
        throw AlreadyDefinedException(varDecl.token, variable.id);
      }

      ar.set(variable.id, value);
      return value;
    }

    if (globalScope.containsKey(variable.id)) {
      throw AlreadyDefinedException(varDecl.token, variable.id);
    }

    globalScope[variable.id] = value;
    return value;
  }

  Value visitVar(VarNode varNode) {
    var name = varNode.id;

    var ar = callstack.top;
    if (ar != null) {
      if (ar.containsKey(name)) {
        return ar.get(name);
      }
    }

    if (globalScope.containsKey(name)) {
      return globalScope[name] ?? NullValue();
    } else {
      throw UndefinedException(varNode.token, name);
    }
  }

  Value visitAssign(AssignNode assignOp) {
    var right = visit(assignOp.right);
    var ar = callstack.top;

    if (!(assignOp.left is VarNode)) {
      // TODO:
      throw InvalidTokenException(assignOp.left.token);
    }

    var variable = assignOp.left as VarNode;
    if (ar != null) {
      ar.set(variable.id, right);
      return right;
    }

    globalScope[variable.id] = right;
    return right;
  }

  Value visitCompound(CompoundNode compound) {
    Value result = NullValue();
    for (var exp in compound.children) {
      if (exp is EmptyOpNode) {
        continue;
      }

      var r = visit(exp);
      if (!r.isNull) {
        result = r;
      }
    }

    return result;
  }

  Value visitBlockCompound(BlockCompoundNode block) {
    for (var exp in block.children) {
      visit(exp);
    }

    return NullValue();
  }

  Value visitIf(IfNode _if) {
    var value = visit(_if.expr);
    if (!value.isBoolean) {
      throw InvalidCastException(_if.expr.op);
    }

    var condition = (value as BooleanValue).value;
    if (condition) {
      return visit(_if.body);
    } else {
      return visit(_if.orElse ?? EmptyOpNode(token: Token.empty()));
    }
  }

  @override
  Value returnNull() {
    return NullValue();
  }

  @override
  Value visitFunctionCall(FunctionCallNode node) {
    var name = node.func;
    late Value value;

    var ar = callstack.top;
    if (ar != null) {
      if (ar.containsKey(name)) {
        value = ar.get(name);
      }
    }

    if (globalScope.containsKey(name)) {
      value = globalScope[name] ?? NullValue();
    }

    if (value == null) {
      throw UndefinedException(node.token, name);
    }

    if (!(value is FunctionValue)) {
      throw UndefinedException(node.token, name);
    }

    var function = value as FunctionValue;

    var args = <Value>[];
    node.args.forEach((arg) {
      args.add(visit(arg));
    });

    ar = ActivationRecord(name: name, type: ActivationRecordType.Procedure, nestingLevel: ar != null ? ar.nestingLevel : 1);
    callstack.push(ar);

    // TODO: set args to ar

    var result = function.call(args);

    ar = callstack.pop();
    log(ar.toString());

    return result;
  }

  @override
  Value visitExprStatement(ExprStatementNode node) {
    return visit(node.expr);
  }

  @override
  Value visitScriptNode(ScriptNode node) {
    // var ar = ActivationRecord(name: node.name, type: ActivationRecordType.Script, nestingLevel: 1);
    // callstack.push(ar);

    return visit(node.compound);

    // ar = callstack.pop();
    // log(ar.toString());

  }

  @override
  Value visitProcedureCall(ProcedureCallNode node) {
    var name = node.func;
    late Value value;

    var ar = callstack.top;
    if (ar != null) {
      if (ar.containsKey(name)) {
        value = ar.get(name);
      }
    }

    if (globalScope.containsKey(name)) {
      value = globalScope[name] ?? NullValue();
    }

    if (value == null) {
      throw UndefinedException(node.token, name);
    }

    if (!(value is ProcedureValue)) {
      throw UndefinedException(node.token, name);
    }

    var function = value as ProcedureValue;

    var args = <Value>[];
    node.args.forEach((arg) {
      args.add(visit(arg));
    });

    ar = ActivationRecord(name: name, type: ActivationRecordType.Procedure, nestingLevel: ar != null ? ar.nestingLevel : 1);
    callstack.push(ar);

    // TODO: set args to ar

    function.call(args);

    ar = callstack.pop();
    log(ar.toString());

    return NullValue();
  }
}