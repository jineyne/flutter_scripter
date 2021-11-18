import 'package:flutter_scripter/ast/ast_node.dart';
import 'package:flutter_scripter/ast/statement/assign_op_node.dart';
import 'package:flutter_scripter/ast/expression/bin_op_node.dart';
import 'package:flutter_scripter/ast/expression/bool_op_node.dart';
import 'package:flutter_scripter/ast/expression/boolean_node.dart';
import 'package:flutter_scripter/ast/expression/compare_node.dart';
import 'package:flutter_scripter/ast/expression/empty_op_node.dart';
import 'package:flutter_scripter/ast/expression/number_node.dart';
import 'package:flutter_scripter/ast/expression/string_node.dart';
import 'package:flutter_scripter/ast/expression/unary_op_node.dart';
import 'package:flutter_scripter/ast/statement/block_compound_node.dart';
import 'package:flutter_scripter/ast/statement/if_node.dart';
import 'package:flutter_scripter/ast/statement/var_decl_node.dart';
import 'package:flutter_scripter/ast/expression/var_node.dart';
import 'package:flutter_scripter/ast/statement/compound_node.dart';
import 'package:flutter_scripter/exception/invalid_cast_exception.dart';
import 'package:flutter_scripter/exception/invalid_operation_exception.dart';
import 'package:flutter_scripter/exception/invalid_var_exception.dart';
import 'package:flutter_scripter/exception/undefined_exception.dart';
import 'package:flutter_scripter/exception/unsupported_exception.dart';
import 'package:flutter_scripter/machine/stack_frame.dart';
import 'package:flutter_scripter/machine/value.dart';
import 'package:flutter_scripter/token/token.dart';
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

  Value getVariable(String name) {
    var top = stackFrame.top;
    var scope = top.scope;

    if (!scope.containsKey(name)) {
      throw ArgumentError("'$name' is not variable");
    }

    return scope[name] ?? NullValue();
  }

  void setVariable(String name, Value value) {
    var top = stackFrame.top;
    var scope = top.scope;

    scope[name] = value;
  }

  Value visit(ASTNode node) {
    if (node is CompoundNode) {
      return visitCompound(node);
    } else if (node is BlockCompoundNode){
      return visitBlockCompound(node);
    } else if (node is AssignOpNode) {
      return visitAssignOp(node);
    } else if (node is IfNode) {
      return visitIf(node);
    } else if (node is BinOpNode) {
      return visitBinOp(node);
    } else if (node is BoolOpNode) {
      return visitBoolOp(node);
    } else if (node is CompareNode) {
      return visitCompare(node);
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

  Value visitAssignOp(AssignOpNode assignOp) {
    var right = visit(assignOp.right);

    if (assignOp.left is VarNode) {
      var variable = assignOp.left as VarNode;
      var top = stackFrame.top;
      top.scope[variable.id] = right;
    }

    return NullValue();
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

  Value visitEmptyOp(EmptyOpNode emptyOp) {
    return NullValue();
  }
}