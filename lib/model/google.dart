class GoogleUser {
  final String iss;
  final String azp;
  final String aud;
  final String sub;
  final String email;
  final bool emailVerified;
  final String atHash;
  final String nonce;
  final String name;
  final String picture;
  final String givenName;
  final String familyName;
  final int iat;
  final int exp;
  final String alg;
  final String kid;
  final String type;

  GoogleUser({
    required this.iss,
    required this.azp,
    required this.aud,
    required this.sub,
    required this.email,
    required this.emailVerified,
    required this.atHash,
    required this.nonce,
    required this.name,
    required this.picture,
    required this.givenName,
    required this.familyName,
    required this.iat,
    required this.exp,
    required this.alg,
    required this.kid,
    required this.type,
  });

  factory GoogleUser.fromJson(Map<String, dynamic> json) {
    return GoogleUser(
      iss: json['iss'] as String,
      azp: json['azp'] as String,
      aud: json['aud'] as String,
      sub: json['sub'] as String,
      email: json['email'] as String,
      emailVerified:
          json['email_verified'] == 'true' || json['email_verified'] == true,
      atHash: json['at_hash'] as String,
      nonce: json['nonce'] as String,
      name: json['name'] as String,
      picture: json['picture'] as String,
      givenName: json['given_name'] as String,
      familyName: json['family_name'] as String,
      iat: int.parse(json['iat'].toString()),
      exp: int.parse(json['exp'].toString()),
      alg: json['alg'] as String,
      kid: json['kid'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iss': iss,
      'azp': azp,
      'aud': aud,
      'sub': sub,
      'email': email,
      'email_verified': emailVerified,
      'at_hash': atHash,
      'nonce': nonce,
      'name': name,
      'picture': picture,
      'given_name': givenName,
      'family_name': familyName,
      'iat': iat,
      'exp': exp,
      'alg': alg,
      'kid': kid,
      'type': type,
    };
  }
}
