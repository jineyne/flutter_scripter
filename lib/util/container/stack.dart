class Stack<T> {
  var data = <T>[];

  T get top => data.last;
  int get length => data.length;

  void push(T raw) {
    data.add(raw);
  }

  T pop() {
    return data.removeLast();
  }
}