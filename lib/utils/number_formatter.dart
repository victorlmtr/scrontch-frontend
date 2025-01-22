class NumberFormatter {
  static String format(double number) {
    String formatted = number.toString();
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'\.0+$'), '');  // Remove .0
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');    // Remove trailing zeros
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');    // Remove trailing dot
    }
    return formatted;
  }
}