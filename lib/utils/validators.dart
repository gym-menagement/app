class Validators {
  // Login ID validation: 4-20 characters, alphanumeric only
  static String? validateLoginId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '아이디를 입력해주세요';
    }

    final trimmed = value.trim();

    if (trimmed.length < 4) {
      return '아이디는 4자 이상이어야 합니다';
    }

    if (trimmed.length > 20) {
      return '아이디는 20자 이하여야 합니다';
    }

    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    if (!alphanumeric.hasMatch(trimmed)) {
      return '아이디는 영문자와 숫자만 사용 가능합니다';
    }

    return null;
  }

  // Password validation: 8+ characters, must include letters and numbers
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }

    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }

    if (value.length > 50) {
      return '비밀번호는 50자 이하여야 합니다';
    }

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);

    if (!hasLetter || !hasDigit) {
      return '비밀번호는 영문자와 숫자를 포함해야 합니다';
    }

    return null;
  }

  // Password confirmation validation
  static String? validatePasswordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }

    if (value != password) {
      return '비밀번호가 일치하지 않습니다';
    }

    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요';
    }

    final trimmed = value.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return '올바른 이메일 형식이 아닙니다';
    }

    return null;
  }

  // Name validation: 2+ characters
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이름을 입력해주세요';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return '이름은 2자 이상이어야 합니다';
    }

    if (trimmed.length > 50) {
      return '이름은 50자 이하여야 합니다';
    }

    return null;
  }

  // Phone validation: Korean format (010-XXXX-XXXX or 01XXXXXXXXX)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '전화번호를 입력해주세요';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return '올바른 전화번호 형식이 아닙니다';
    }

    if (!digitsOnly.startsWith('01')) {
      return '올바른 전화번호 형식이 아닙니다';
    }

    return null;
  }

  // Birth date validation
  static String? validateBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '생년월일을 입력해주세요';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length != 8) {
      return '생년월일은 8자리 숫자여야 합니다 (YYYYMMDD)';
    }

    try {
      final year = int.parse(digitsOnly.substring(0, 4));
      final month = int.parse(digitsOnly.substring(4, 6));
      final day = int.parse(digitsOnly.substring(6, 8));

      final date = DateTime(year, month, day);
      final now = DateTime.now();

      if (date.isAfter(now)) {
        return '미래 날짜는 입력할 수 없습니다';
      }

      if (date.year < 1900) {
        return '올바른 생년월일을 입력해주세요';
      }

      if (now.year - date.year > 150) {
        return '올바른 생년월일을 입력해주세요';
      }

      return null;
    } catch (e) {
      return '올바른 생년월일 형식이 아닙니다 (YYYYMMDD)';
    }
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    return null;
  }
}
