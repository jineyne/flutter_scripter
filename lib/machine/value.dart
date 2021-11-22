abstract class Value {
  bool get isBoolean => false;
  bool get isNumber => false;
  bool get isString => false;
  bool get isFunction => false;
  bool get isNull => false;
}

class BooleanValue extends Value {
  bool value;

  @override
  bool get isBoolean => true;

  BooleanValue(this.value);

  @override
  String toString() {
    return '$value';
  }
}

class NumberValue extends Value {
  double value;

  @override
  bool get isNumber => true;

  NumberValue(this.value);

  @override
  String toString() {
    return value.toString();
  }
}

class StringValue extends Value {
  String value;

  @override
  bool get isString => true;

  StringValue(this.value);

  @override
  String toString() {
    return value;
  }
}

abstract class FunctionValue extends Value {
  int argc;

  @override
  bool get isFunction => true;

  FunctionValue(this.argc);

  Value call(List<Value> args);
}

typedef ScriptFunctionType = Value Function(List<Value> args);

class ExternalFunctionValue extends FunctionValue {
  ScriptFunctionType value;

  ExternalFunctionValue(this.value, int argc) : super(argc);

  @override
  Value call(List<Value> args) {
    return value(args);
  }

  @override
  String toString() {
    return value.toString();
  }
}

abstract class ProcedureValue extends Value {
  int argc;

  @override
  bool get isFunction => true;

  ProcedureValue(this.argc);

  void call(List<Value> args);
}

typedef ScriptProcedureType = void Function(List<Value> args);

class ExternalProcedureValue extends ProcedureValue {
  ScriptProcedureType value;

  ExternalProcedureValue(this.value, int argc) : super(argc);

  @override
  Value call(List<Value> args) {
    value(args);
    return NullValue();
  }

  @override
  String toString() {
    return value.toString();
  }
}

class NullValue extends Value {
  @override
  bool get isNull => true;

  @override
  String toString() {
    return "null";
  }
}