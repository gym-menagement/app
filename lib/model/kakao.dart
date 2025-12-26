class KakaoUser {
  final int id;
  final String connectedAt;
  final KakaoProperties properties;
  final KakaoAccount kakaoAccount;

  KakaoUser({
    required this.id,
    required this.connectedAt,
    required this.properties,
    required this.kakaoAccount,
  });

  factory KakaoUser.fromJson(Map<String, dynamic> json) {
    return KakaoUser(
      id: json['id'],
      connectedAt: json['connected_at'],
      properties: KakaoProperties.fromJson(json['properties']),
      kakaoAccount: KakaoAccount.fromJson(json['kakao_account']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'connected_at': connectedAt,
    'properties': properties.toJson(),
    'kakao_account': kakaoAccount.toJson(),
  };
}

class KakaoProperties {
  final String nickname;

  KakaoProperties({required this.nickname});

  factory KakaoProperties.fromJson(Map<String, dynamic> json) {
    return KakaoProperties(nickname: json['nickname']);
  }

  Map<String, dynamic> toJson() => {'nickname': nickname};
}

class KakaoAccount {
  final bool profileNicknameNeedsAgreement;
  final KakaoProfile profile;
  final bool hasEmail;
  final bool emailNeedsAgreement;
  final bool isEmailValid;
  final bool isEmailVerified;
  final String email;

  KakaoAccount({
    required this.profileNicknameNeedsAgreement,
    required this.profile,
    required this.hasEmail,
    required this.emailNeedsAgreement,
    required this.isEmailValid,
    required this.isEmailVerified,
    required this.email,
  });

  factory KakaoAccount.fromJson(Map<String, dynamic> json) {
    return KakaoAccount(
      profileNicknameNeedsAgreement: json['profile_nickname_needs_agreement'],
      profile: KakaoProfile.fromJson(json['profile']),
      hasEmail: json['has_email'],
      emailNeedsAgreement: json['email_needs_agreement'],
      isEmailValid: json['is_email_valid'],
      isEmailVerified: json['is_email_verified'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'profile_nickname_needs_agreement': profileNicknameNeedsAgreement,
    'profile': profile.toJson(),
    'has_email': hasEmail,
    'email_needs_agreement': emailNeedsAgreement,
    'is_email_valid': isEmailValid,
    'is_email_verified': isEmailVerified,
    'email': email,
  };
}

class KakaoProfile {
  final String nickname;
  final bool isDefaultNickname;

  KakaoProfile({required this.nickname, required this.isDefaultNickname});

  factory KakaoProfile.fromJson(Map<String, dynamic> json) {
    return KakaoProfile(
      nickname: json['nickname'],
      isDefaultNickname: json['is_default_nickname'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'is_default_nickname': isDefaultNickname,
  };
}
