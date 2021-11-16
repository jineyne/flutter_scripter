abstract class Value {
  bool get isBoolean => false;
  bool get isNumber => false;
  bool get isString => false;
  bool get isNull => false;

  String asString();
}

class BooleanValue extends Value {
  bool value;

  @override
  bool get isBoolean => true;

  BooleanValue(this.value);

  @override
  String asString() {
    return '$value';
  }

  @override
  String toString() {
    return asString();
  }
}

class NumberValue extends Value {
  double value;

  @override
  bool get isNumber => true;

  NumberValue(this.value);

  @override
  String asString() {
    return value.toString();
  }

  @override
  String toString() {
    return asString();
  }
}

class StringValue extends Value {
  String value;

  @override
  bool get isString => true;

  StringValue(this.value);

  @override
  String asString() {
    return value;
  }

  @override
  String toString() {
    return asString();
  }
}

class NullValue extends Value {
  @override
  bool get isNull => true;

  @override
  String asString() {
    return "null";
  }

  @override
  String toString() {
    return asString();
  }
}