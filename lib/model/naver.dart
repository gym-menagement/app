class NaverUser {
  final String id;
  final String email;
  final String name;
  final String nickname;
  final String profileImage;

  NaverUser({
    required this.id,
    required this.email,
    required this.name,
    required this.nickname,
    required this.profileImage,
  });

  factory NaverUser.fromJson(Map<String, dynamic> json) {
    return NaverUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      profileImage: json['profile_image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'nickname': nickname,
      'profile_image': profileImage,
    };
  }
}
