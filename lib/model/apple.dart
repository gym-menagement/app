class AppleUser {
  final String iss;
  final String aud;
  final int exp;
  final int iat;
  final String sub;
  final String? email;
  final bool? emailVerified;
  final bool? isPrivateEmail;
  final int? authTime;
  final bool? nonceSupported;

  AppleUser({
    required this.iss,
    required this.aud,
    required this.exp,
    required this.iat,
    required this.sub,
    this.email,
    this.emailVerified,
    this.isPrivateEmail,
    this.authTime,
    this.nonceSupported,
  });

  factory AppleUser.fromJson(Map<String, dynamic> json) {
    return AppleUser(
      iss: json['iss'] as String,
      aud: json['aud'] as String,
      exp: int.parse(json['exp'].toString()),
      iat: int.parse(json['iat'].toString()),
      sub: json['sub'] as String,
      email: json['email'] as String?,
      emailVerified:
          json['email_verified'] == 'true' || json['email_verified'] == true,
      isPrivateEmail: json['is_private_email'] == 'true' ||
          json['is_private_email'] == true,
      authTime: json['auth_time'] != null
          ? int.parse(json['auth_time'].toString())
          : null,
      nonceSupported: json['nonce_supported'] == 'true' ||
          json['nonce_supported'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iss': iss,
      'aud': aud,
      'exp': exp,
      'iat': iat,
      'sub': sub,
      'email': email,
      'email_verified': emailVerified,
      'is_private_email': isPrivateEmail,
      'auth_time': authTime,
      'nonce_supported': nonceSupported,
    };
  }
}