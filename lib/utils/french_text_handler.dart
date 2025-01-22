class FrenchTextHandler {
  static String handlePlural(String text, double quantity) {
    if (text == 'undefined') return '';

    // If quantity is 1, use singular form
    if (quantity == 1) {
      return text.replaceAllMapped(
        RegExp(r'(\w+)\((s|x)\)(\s+\w+\((s|x)\))*'),
            (match) {
          return match.group(0)!
              .replaceAll('(s)', '')
              .replaceAll('(x)', '');
        },
      );
    }

    // Otherwise use plural form (replace (s) with s and (x) with x)
    return text
        .replaceAll('(s)', 's')
        .replaceAll('(x)', 'x');
  }
}