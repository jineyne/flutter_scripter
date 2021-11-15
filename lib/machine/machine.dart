import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/expression/assign_op_node.dart';
import 'package:flutter_scripter/ast/expression/bin_op_node.dart';
import 'package:flutter_scripter/ast/expression/boolean_node.dart';
import 'package:flutter_scripter/ast/expression/empty_op_node.dart';
import 'package:flutter_scripter/ast/expression/number_node.dart';
import 'package:flutter_scripter/ast/expression/string_node.dart';
import 'package:flutter_scripter/ast/expression/unary_op_node.dart';
import 'package:flutter_scripter/ast/expression/var_decl_node.dart';
import 'package:flutter_scripter/ast/expression/var_node.dart';
import 'package:flutter_scripter/ast/statement/compound_node.dart';
import 'package:flutter_scripter/exception/invalid_cast_exception.dart';
import 'package:flutter_scripter/exception/invalid_operation_exception.dart';
import 'package:flutter_scripter/exception/invalid_var_exception.dart';
import 'package:flutter_scripter/exception/undefined_exception.dart';
import 'package:flutter_scripter/exception/unsupported_exception.dart';
import 'package:flutter_scripter/machine/stack_frame.dart';
import 'package:flutter_scripter/machine/value.dart';
import 'package:flutter_scripter/token/token_type.dart';
import 'package:flutter_scripter/util/container/stack.dart';

class Machine {
  var stackFrame = Stack<StackFrame>();

  Machine() {
    stackFrame.push(StackFrame());
  }

  Value run(ASTNode root) {
    try {
      return visit(root);
    } catch (e) {
      print(e.toString());

      return NullValue();
    }
  }

  Value visit(ASTNode node) {
    if (node is CompoundNode) {
      return visitCompound(node);
    } else if (node is BinOpNode) {
      return visitBinOp(node);
    } else if (node is BooleanNode) {
      return visitBoolean(node);
    } else if (node is NumberNode) {
      return visitNumber(node);
    } else if (node is StringNode) {
      return visitString(node);
    } else if (node is UnaryOpNode) {
      return visitUnaryOp(node);
    } else if (node is VarDeclNode) {
      return visitVarDecl(node);
    } else if (node is VarNode) {
      return visitVar(node);
    } else if (node is EmptyOpNode) {
      return visitEmptyOp(node);
    }

    throw UnSupportedException(node.token);
    return NullValue();
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

  Value visitAssignOp(AssignOpNode assignOp) {
    var right = visit(assignOp.right);

    if (assignOp.left is VarNode) {
      var variable = assignOp.left as VarNode;
      var top = stackFrame.top;
      top.scope[variable.id] = right;
    }

    return NullValue();
  }

  Value visitBinOp(BinOpNode binOp) {
    var left = visit(binOp.left);
    var right = visit(binOp.right);

    if (left.isNumber && right.isNumber) {
      var leftValue = (left as NumberValue).value;
      var rightValue = (right as NumberValue).value;

      switch (binOp.token.type) {
        case TokenType.plus: return NumberValue(leftValue + rightValue);
        case TokenType.minus: return NumberValue(leftValue - rightValue);
        case TokenType.asterisk: return NumberValue(leftValue * rightValue);
        case TokenType.slash: return NumberValue(leftValue / rightValue);
        default: throw InvalidOperationException(binOp.token);
      }
    } else if (left.isString && right.isString) {
      var leftValue = (left as StringValue).value;
      var rightValue = (right as StringValue).value;

      switch (binOp.token.type) {
        case TokenType.plus: return StringValue(leftValue + rightValue);
        default: throw InvalidOperationException(binOp.token);
      }
    }

    throw InvalidCastException(binOp.token);
    return NullValue();
  }

  Value visitUnaryOp(UnaryOpNode unaryOp) {
    var data = visit(unaryOp.expr);

    if (!data.isNumber) {
      return NullValue();
    }

    var value = (data as NumberValue).value;

    switch (unaryOp.token.type) {
      case TokenType.plus: return NumberValue(value);
      case TokenType.minus: return NumberValue(-value);
      default: throw InvalidOperationException(unaryOp.token);
    }
  }

  Value visitVarDecl(VarDeclNode varDecl) {
    var top = stackFrame.top;
    var variable = varDecl.variable as VarNode;
    var initializer = varDecl.initializer;

    if (top.scope.containsKey(variable.id)) {
      throw InvalidVarException(variable);
    }

    return (top.scope[variable.id] = visit(initializer));
  }

  Value visitVar(VarNode varNode) {
    var top = stackFrame.top;
    if (!top.scope.containsKey(varNode.id)) {
      throw UndefinedException(varNode.op, varNode.id);
      return NullValue();
    }

    return top.scope[varNode.id] ?? NullValue();
  }

  Value visitCompound(CompoundNode compound) {
    for (var exp in compound.children) {
      visit(exp);
    }

    return NullValue();
  }

  Value visitEmptyOp(EmptyOpNode emptyOp) {
    return NullValue();
  }
}