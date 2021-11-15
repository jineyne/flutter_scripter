extension StringExtension on String {
  static var spaceExp = RegExp(r'\s+');
  static var alphaExp = RegExp(r'^[A-Za-z]+$');
  static var digitExp = RegExp(r'^\d+$');

  bool isSpace() {
    return spaceExp.hasMatch(this);
  }

  bool isAlpha() {
    return alphaExp.hasMatch(this);
  }

  bool isDigit() {
    return digitExp.hasMatch(this);
  }

  bool isAlphaOrDigit() {
    return isAlpha() || isDigit();
  }
}