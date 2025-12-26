import 'package:app/model/user.dart';
import 'package:app/model/apple.dart';
import 'package:app/model/google.dart';
import 'package:app/model/kakao.dart';
import 'package:app/model/naver.dart';
import 'package:app/config/http.dart';
import 'package:flutter/foundation.dart';

class LoginManager {
  static Future<User> login(String loginid, String passwd) async {
    try {
      var url = '/api/jwt?loginid=$loginid&passwd=$passwd';
      if (kDebugMode) {
        print('=== LoginManager.login ===');
        print('URL: $url');
      }

      var result = await Http.get(url);

      if (kDebugMode) {
        print('=== API Response ===');
        print('Result: $result');
        print('Token: ${result['token']}');
        print('User: ${result['user']}');
      }

      // token과 user 필드가 있으면 성공으로 판단
      if (result['token'] == null || result['user'] == null) {
        if (kDebugMode) {
          print('Login failed - missing token or user');
        }
        return User();
      }

      final token = result['token'];
      final user = User.fromJson(result['user']);
      user.extra["token"] = token;

      if (kDebugMode) {
        print('Login success - User ID: ${user.id}, Name: ${user.name}, Token: $token');
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('=== LoginManager Error ===');
        print('Error: $e');
      }
    }

    return User();
  }

  static Future<User> kakaoLogin(String type, String accessToken) async {
    try {
      var url = '/api/jwt?type=$type&token=$accessToken';
      var result = await Http.get(url);

      // token과 user가 있으면 로그인 성공
      if (result['token'] != null && result['user'] != null) {
        final token = result['token'];
        final user = User.fromJson(result['user']);
        user.extra["token"] = token;
        return user;
      }

      // 신규 사용자인 경우 (item 정보만 있음)
      if (result['item'] != null) {
        final kakaoUser = KakaoUser.fromJson(result['item']);
        var user =
            User()
              ..connectid = kakaoUser.id.toString()
              ..email = kakaoUser.kakaoAccount.email
              ..name = kakaoUser.properties.nickname;
        return user;
      }

      return User();
    } catch (e) {
      if (kDebugMode) {
        print('Kakao login error: $e');
      }
    }

    return User();
  }

  static Future<User> naverLogin(String type, String accessToken) async {
    try {
      var url = '/api/jwt?type=$type&token=$accessToken';
      var result = await Http.get(url);

      // token과 user가 있으면 로그인 성공
      if (result['token'] != null && result['user'] != null) {
        final token = result['token'];
        final user = User.fromJson(result['user']);
        user.extra["token"] = token;
        return user;
      }

      // 신규 사용자인 경우 (item 정보만 있음)
      if (result['item'] != null && result['item']['response'] != null) {
        final naverUser = NaverUser.fromJson(result['item']['response']);
        var user =
            User()
              ..connectid = naverUser.id
              ..email = naverUser.email
              ..name = naverUser.nickname;
        return user;
      }

      return User();
    } catch (e) {
      if (kDebugMode) {
        print('Naver login error: $e');
      }
    }

    return User();
  }

  static Future<User> googleLogin(String type, String accessToken) async {
    try {
      var url = '/api/jwt?type=$type&token=$accessToken';
      var result = await Http.get(url);

      // token과 user가 있으면 로그인 성공
      if (result['token'] != null && result['user'] != null) {
        final token = result['token'];
        final user = User.fromJson(result['user']);
        user.extra["token"] = token;
        return user;
      }

      // 신규 사용자인 경우 (item 정보만 있음)
      if (result['item'] != null) {
        final googleUser = GoogleUser.fromJson(result['item']);
        var user =
            User()
              ..connectid = googleUser.sub
              ..email = googleUser.email
              ..name = googleUser.name;
        return user;
      }

      return User();
    } catch (e) {
      if (kDebugMode) {
        print('Google login error: $e');
      }
    }

    return User();
  }

  static Future<User> appleLogin(String type, String identityToken) async {
    try {
      var url = '/api/jwt?type=$type&token=$identityToken';
      var result = await Http.get(url);

      // token과 user가 있으면 로그인 성공
      if (result['token'] != null && result['user'] != null) {
        final token = result['token'];
        final user = User.fromJson(result['user']);
        user.extra["token"] = token;
        return user;
      }

      // 신규 사용자인 경우 (item 정보만 있음)
      if (result['item'] != null) {
        final appleUser = AppleUser.fromJson(result['item']);
        var user =
            User()
              ..connectid = appleUser.sub
              ..email = appleUser.email!
              ..name = '';
        return user;
      }

      return User();
    } catch (e) {
      if (kDebugMode) {
        print('Apple login error: $e');
      }
    }

    return User();
  }

  static Future fcm(String token, String old) async {
    var url =
        '/api/user/fcm/${Uri.encodeFull(token)}?old=${Uri.encodeFull(old)}';
    await Http.get(url);
  }
}
