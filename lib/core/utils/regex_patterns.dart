class RegexPatterns {
  RegexPatterns._();

  // General character classes
  static final RegExp nonDigit = RegExp(r'[^\d]');
  static final RegExp digit = RegExp(r'\d');
  static final RegExp anyWhitespace = RegExp(r'\s');
  static final RegExp alphanumeric = RegExp('[A-Za-z0-9]');

  // Turkish letters
  static final RegExp turkishLettersAndSpaces = RegExp(
    r'[a-zA-ZğüşöçıİĞÜŞÖÇ\s]',
  );

  // HTML
  static final RegExp htmlTags = RegExp('<[^>]*>');
  static final RegExp htmlParagraphTags = RegExp('<p[^>]*>');
  static final RegExp htmlBoldGroup = RegExp('<b>(.*?)</b>');

  // Email patterns
  static final RegExp emailSimple = RegExp(r'^[\w\.]+@[\w]+\.[a-zA-Z]+$');
  static final RegExp emailStrict = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  ); // global validator
  static final RegExp emailKolas = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  static final RegExp emailChange = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp emailResetPassword = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$',
  );
  static final RegExp emailDomainPart = RegExp('@.*');
  static final RegExp emailOnlyOneAt = RegExp('@.*@');

  // Phone patterns
  static final RegExp phoneInternational = RegExp(
    r'^\+?[\d\s\-\(\)]+$',
  ); // with +, spaces, dashes, parens
  static final RegExp phoneDigitsPlusSpace = RegExp(r'[0-9\s+]');
  static final RegExp sixDigitGroup = RegExp(r'(\d{6})');
  static final RegExp sixDigitExact = RegExp(r'^\d{6}$');
  static final RegExp fourDigitExact = RegExp(r'^\d{4}$');
  static final RegExp tenDigitExact = RegExp(r'^\d{10}$');
  static final RegExp elevenDigitExact = RegExp(r'^[0-9]{11}$');

  // Sequential 6-digit passwords
  static final RegExp sixDigitSequential = RegExp(
    '(012345|123456|234567|345678|456789|987654|876543|765432|654321)',
  );

  // Bill subscriber numbers (8 to 12 digits)
  static final RegExp subscriberNumber8to12 = RegExp(r'^\d{8,12}$');

  // Number formatting / parsing
  static final RegExp nonNumericCommaDot = RegExp('[^0-9.,]');
  static final RegExp thousandSeparator = RegExp(
    r'(\d{1,3})(?=(\d{3})+(?!\d))',
  );

  // IBAN
  static final RegExp ibanTrCompact = RegExp(r'^TR[0-9A-Z]{24}$');
  static final RegExp ibanTrFormatted = RegExp(
    r'^TR\d{2}\s?\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\s?\d{2}$',
  );

  // Firebase PEM certificate parsing
  static final RegExp pemCertificatePattern1 = RegExp(
    r'-----BEGIN CERTIFICATE-----[\s\S]*?-----END CERTIFICATE-----',
    multiLine: true,
    dotAll: true,
  );
  static final RegExp pemCertificatePattern2 = RegExp(
    r'-----BEGIN CERTIFICATE----- [\s\S]*? -----END CERTIFICATE-----',
    multiLine: true,
    dotAll: true,
  );

  // Title-case helpers
  static final RegExp turkishTitleTokenSeparator = RegExp(r"([ \t\r\n\-'\.])");
  static final RegExp turkishTitleSeparatorMatcher = RegExp(r"[ \t\r\n\-'\.]");

  // Mask formatter helpers
  static final RegExp maskDigit = RegExp('[0-9]');
  static final RegExp maskNonDigit = RegExp('[^0-9]');

  // Last login failed sheet parsing
  static final RegExp lastFailedLoginDateTime = RegExp(r'Tarih-Saat:\s*(.+)');
  static final RegExp lastFailedLoginIp = RegExp(r'IP Adresi:\s*(.+)');

  // TC Kimlik Numarası Doğrulama
  static bool isValidTurkishId(String input) {
    if (!RegExp(r'^[1-9]\d{10}$').hasMatch(input)) {
      return false;
    }
    final digits = input.split('').map(int.parse).toList();

    final sumOdd = digits[0] + digits[2] + digits[4] + digits[6] + digits[8];
    final sumEven = digits[1] + digits[3] + digits[5] + digits[7];

    final rule10 = ((sumOdd * 7) - sumEven) % 10;
    if (rule10 != digits[9]) {
      return false;
    }

    final sumFirst10 = digits.sublist(0, 10).fold(0, (a, b) => a + b);
    final rule11 = sumFirst10 % 10;
    if (rule11 != digits[10]) {
      return false;
    }

    return true;
  }
}
