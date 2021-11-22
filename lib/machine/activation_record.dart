import 'package:flutter/foundation.dart';
import 'package:flutter_scripter/machine/value.dart';
import 'package:format/format.dart';

enum ActivationRecordType {
  Program,
  Script,
  Procedure,
  Function
}

class ActivationRecord {
  String name;
  ActivationRecordType type;
  int nestingLevel;

  var members = <String, Value>{};
  Value? returnValue;

  ActivationRecord({required this.name, required this.type, required this.nestingLevel});

  void set(String key, Value value) {
    members[key] = value;
  }

  Value get(String key) {
    return members[key] ?? NullValue();
  }

  bool containsKey(String key) {
    return members.containsKey(key);
  }

  @override
  String toString() {
    var lines = <String>[
      format('{0}: {1}, {2}', nestingLevel, describeEnum(type), name),
    ];

    members.forEach((key, value) {
      lines.add(format('    {0:20}: {1}', key, value));
    });

    if (returnValue != null) {
      lines.add(format('RETURN: {0}', returnValue ?? NullValue()));
    }

    return lines.join('\n');
  }
}