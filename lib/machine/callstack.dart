import 'package:flutter_scripter/machine/activation_record.dart';

class CallStack {
  final _records = <ActivationRecord>[];

  ActivationRecord? get top => _records.isEmpty ? null : _records.last;

  void push(ActivationRecord record) {
    _records.add(record);
  }

  ActivationRecord pop() {
    return _records.removeLast();
  }

  @override
  String toString() {
    var sb = StringBuffer();
    sb.writeln('CALL STACK');
    sb.writeln(_records.join('\n'));

    return sb.toString();
  }
}