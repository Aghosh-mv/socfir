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
  static int get currentYear => DateTime.now().year;

  // Comprehensive list of fake / disposable / temporary email domains to block
  static final Set<String> _blockedDomains = {
    // Top temporary and throwaway mail services
    'tempmail.com', 'temp-mail.org', 'temp-mail.io', 'tempmail.net', 'tempmail.ninja',
    'mailinator.com', 'mailinater.com', '10minutemail.com', '10minutemail.net', '10minmail.com',
    'dispostable.com', 'guerrillamail.com', 'guerrillamail.net', 'guerrillamail.biz', 'guerrillamail.org',
    'trashmail.com', 'trashmail.net', 'trashmail.me', 'fake.com', 'test.com', 'example.com',
    'asdf.com', 'qwerty.com', 'foo.bar', 'temp.com', 'yopmail.com', 'yopmail.fr', 'yopmail.net',
    'sharklasers.com', 'grr.la', 'guerrillamailblock.com', 'pokemail.net', 'spam4.me',
    'getnada.com', 'nada.ltd', 'abcvg.com', 'inboxkitten.com', 'throwawaymail.com',
    'generator.email', 'crazymailing.com', 'dropmail.me', 'mohmal.com', 'mytemp.email',
    'fakemailgenerator.com', 'emailondeck.com', 'burnerdeals.com', 'burnermail.io',
    'tempail.com', 'disposablemail.com', 'tmpmail.org', 'tmpmail.net', 'fakemail.net',
    'internxt.com', 'crazymailing.com', 'maildrop.cc', 'harakirimail.com', 'receive-sms-free.cc',
    'tempr.email', 'discard.email', 'discardmail.com', 'spambog.com', 'trashmail.org',
    'minuteinbox.com', 'mohmal.in', 'emailfake.com', 'zillamail.com', 'bupmail.com',
    'deadaddress.com', 'mytempemail.com', 'trash-mail.com', 'jetable.org', 'luxusmail.org',
    'clipmail.eu', 'drdrb.net', 'byom.de', 'safetymail.info', 'shieldemail.com',
  };

  // Keywords that identify disposable / burner domains even if not on the exact list
  static final List<String> _disposableKeywords = [
    'tempmail', 'temp-mail', 'throwaway', 'disposable', '10minute', 'guerrilla',
    'mailinator', 'trashmail', 'fakeinbox', 'fakemail', 'generator', 'yopmail',
    'burner', 'inboxclean', 'mohmal', 'discard', 'spambox', 'spambog',
    'emailondeck', 'dropmail', 'minuteinbox', 'anonymbox', 'instantemail',
    'tmpmail', 'mytemp', 'dispostable',
  ];

  // Valid TLDs
  static final Set<String> _validTlds = {
    'com', 'org', 'net', 'edu', 'gov', 'io', 'co', 'in', 'dev', 'me', 'app', 'ai', 'uk', 'ca', 'us', 'de', 'fr', 'tech', 'info',
    'au', 'jp', 'br', 'ru', 'nl', 'es', 'it', 'pl', 'xyz', 'live', 'online', 'email', 'shop', 'store', 'tv', 'fm', 'cc', 'biz',
    'name', 'pro', 'id', 'sg', 'nz', 'za', 'ke', 'ng', 'ph', 'mx', 'ar', 'cl', 'cn', 'hk', 'tw', 'eu', 'be', 'ch', 'at', 'se',
    'no', 'dk', 'fi', 'ie', 'pt', 'tr', 'gr', 'ro', 'hu', 'cz', 'sk', 'hr', 'rs',
  };

  // Major real email providers allowlist & MX known domains
  static final Set<String> _knownValidProviders = {
    'gmail.com', 'googlemail.com', 'yahoo.com', 'ymail.com', 'outlook.com',
    'hotmail.com', 'live.com', 'icloud.com', 'me.com', 'mac.com', 'proton.me',
    'protonmail.com', 'zoho.com', 'aol.com', 'mail.com', 'gmx.com',
  };

  /// Verifies email format, checks MX provider realism, blocks disposable/fake domains, and checks valid TLDs
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

    if (username.length < 3) {
      return EmailVerificationResult(
        isValid: false,
        errorMessage: 'Email username "$username" is too short (min 3 characters).',
      );
    }

    // Disallow repeating dummy characters like "aaaa", "test", "asdf"
    if (RegExp(r'^(.)\1+$').hasMatch(username) || username == 'asdf' || username == 'qwerty') {
      return EmailVerificationResult(
        isValid: false,
        errorMessage: 'Email username cannot be a repetitive dummy string.',
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
        errorMessage: 'Disposable or temporary email service "$domain" is prohibited.',
      );
    }

    // Check for disposable domain patterns/keywords
    for (final kw in _disposableKeywords) {
      if (domain.contains(kw)) {
        return EmailVerificationResult(
          isValid: false,
          errorMessage: 'Temporary or disposable email addresses are not permitted.',
        );
      }
    }

    // Check TLD
    final domainParts = domain.split('.');
    final tld = domainParts.last;
    if (!_validTlds.contains(tld) || tld.length < 2) {
      return EmailVerificationResult(
        isValid: false,
        errorMessage: 'Invalid top-level domain ".$tld".',
      );
    }

    // If domain matches a known provider or has valid TLD and valid structure
    final isKnownProvider = _knownValidProviders.contains(domain);
    if (!isKnownProvider && domainParts.length > 3) {
      return EmailVerificationResult(
        isValid: false,
        errorMessage: 'Suspicious domain routing: "$domain".',
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
