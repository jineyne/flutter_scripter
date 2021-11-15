import 'package:flutter_scripter/machine/value.dart';

class StackFrame {
  var scope = <String, Value>{};
  Value? returnValue;
}