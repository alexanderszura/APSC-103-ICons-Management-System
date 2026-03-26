abstract class StringHelper {

  StringHelper._();

  static bool isAlpha(String string) {
    final alphaRegex = RegExp(r'^[a-zA-Z]+$');
    return alphaRegex.hasMatch(string);
  }

  static bool isNumeric(String string) => num.tryParse(string) != null;

  static bool isAlphaNumeric(String string) {
    final RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumeric.hasMatch(string);
  }
  
}