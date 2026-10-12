class EmailVerificationResult {
  final bool isValid;
  final String? errorMessage;
  final int? inferredBirthYear;
  final int? inferredAge;

  EmailVerificationResult({
    required this.isValid,
    this.errorMessage,
    this.inferredBirthYear,
    this.inferredAge,
  });
}

class EmailVerifier {
  static const int currentYear = 2026;

  // Common fake / disposable email domains to block
  static final Set<String> _blockedDomains = {
    'tempmail.com', 'mailinator.com', '10minutemail.com', 'dispostable.com',
    'guerrillamail.com', 'trashmail.com', 'fake.com', 'test.com', 'example.com',
    'asdf.com', 'qwerty.com', 'foo.bar', 'temp.com', 'yopmail.com', 'sharklasers.com',
  };

  // Valid TLDs
  static final Set<String> _validTlds = {
    'com', 'org', 'net', 'edu', 'gov', 'io', 'co', 'in', 'dev', 'me', 'app', 'ai', 'uk', 'ca', 'us', 'de', 'fr', 'tech', 'info',
  };

  /// Verifies email format, blocks disposable/fake domains, and checks valid TLDs
  static EmailVerificationResult verifyEmail(String email) {
    final trimmed = email.trim().toLowerCase();
    final parts = trimmed.split('@');

    if (parts.length != 2) {
      return EmailVerificationResult(
        isValid: false,
        errorMessage: 'Invalid email format. Expected format: name@domain.com',
      );
    }

    final username = parts[0];
    final domain = parts[1];

    if (username.length < 2) {
      return EmailVerificationResult(
        isValid: false,
        errorMessage: 'Email prefix before "@" is too short.',
      );
    }

    if (!domain.contains('.')) {
      return EmailVerificationResult(
        isValid: false,
        errorMessage: 'Email domain must contain a valid extension (e.g. .com).',
      );
    }

    // Check disposable/fake domain blocklist
    if (_blockedDomains.contains(domain)) {
      return EmailVerificationResult(
        isValid: false,
        errorMessage: 'Disposable or fake email domain "$domain" is not allowed.',
      );
    }

    // Check TLD
    final domainParts = domain.split('.');
    final tld = domainParts.last;
    if (!_validTlds.contains(tld)) {
      return EmailVerificationResult(
        isValid: false,
        errorMessage: 'Invalid email top-level domain ".$tld".',
      );
    }

    // Infer birth year from username prefix if present
    final inferredYear = _extractBirthYear(username);
    int? inferredAge;
    if (inferredYear != null) {
      inferredAge = currentYear - inferredYear;
    }

    return EmailVerificationResult(
      isValid: true,
      inferredBirthYear: inferredYear,
      inferredAge: inferredAge,
    );
  }

  /// Extracts 4-digit or 2-digit birth year from email username (e.g. user1998 -> 1998, alex05 -> 2005)
  static int? _extractBirthYear(String username) {
    // Look for 4-digit year first (1940 - 2022)
    final fourDigitMatch = RegExp(r'(19[4-9]\d|20[0-2]\d)').firstMatch(username);
    if (fourDigitMatch != null) {
      return int.tryParse(fourDigitMatch.group(0)!);
    }

    // Look for trailing 2-digit year at end of username (e.g. mark95, sarah08)
    final twoDigitMatch = RegExp(r'([a-zA-Z_]+)(\d{2})$').firstMatch(username);
    if (twoDigitMatch != null) {
      final digits = int.tryParse(twoDigitMatch.group(2)!);
      if (digits != null) {
        if (digits >= 0 && digits <= 22) {
          return 2000 + digits; // 00 -> 2000, 08 -> 2008
        } else if (digits >= 40 && digits <= 99) {
          return 1900 + digits; // 95 -> 1995
        }
      }
    }

    return null;
  }

  /// Compares entered age against inferred email age
  static String? verifyAgeMatch({required String email, required int enteredAge}) {
    final verification = verifyEmail(email);
    if (!verification.isValid || verification.inferredAge == null) {
      return null; // No age detected in email to compare against
    }

    final inferredAge = verification.inferredAge!;
    final inferredYear = verification.inferredBirthYear!;

    // Allow a +/- 3 year tolerance
    if ((enteredAge - inferredAge).abs() > 3) {
      return 'Age conflict! Email ($email) indicates birth year $inferredYear (~$inferredAge yrs old), but you entered age $enteredAge.';
    }

    return null;
  }
}
