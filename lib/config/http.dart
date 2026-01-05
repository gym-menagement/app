import 'dart:convert';

import 'package:app/config/cconfig.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// HTTP 통신을 위한 유틸리티 클래스
/// CConfig의 serverUrl과 token을 사용하여 API 통신을 수행합니다.
///
/// 사용 예시:
/// ```dart
/// // GET 요청
/// var data = await Http.get('/api/gyms', {'page': 1, 'limit': 10});
///
/// // POST 요청
/// var result = await Http.post('/api/auth/login', {
///   'email': 'user@example.com',
///   'password': 'password123'
/// });
///
/// // PUT 요청
/// await Http.put('/api/user/profile', {'name': 'New Name'});
///
/// // DELETE 요청
/// await Http.delete('/api/user/account', {'id': 123});
/// ```
class Http {
  /// URL 쿼리 파라미터 생성
  static makeParams(Map<String, dynamic>? items, [String? etc]) {
    if (items == null) {
      return '';
    }

    var params = '';
    for (String key in items.keys) {
      if (params != '') {
        params += '&';
      }

      params += '$key=${items[key]}';
    }

    if (etc != null && etc != '') {
      if (params != '') {
        params += '&';
      }

      params += etc;
    }

    return params;
  }

  /// GET 요청
  /// [path]: API 엔드포인트 (예: '/api/gyms')
  /// [params]: 쿼리 파라미터 (예: {'page': 1, 'limit': 10})
  /// [etc]: 추가 쿼리 문자열
  static get(String path, [Map<String, dynamic>? params, String? etc]) async {
    var param = makeParams(params, etc);

    final config = CConfig();

    try {
      var url = '${config.serverUrl}$path';
      if (param != '') {
        url += '?$param';
      }

      if (kDebugMode) {
        print('[HTTP GET] $url');
      }

      var result = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${config.token}'},
      );

      if (kDebugMode) {
        print('[HTTP GET Response] Status: ${result.statusCode}');
      }

      if (result.statusCode == 200) {
        final parsed = json.decode(utf8.decode(result.bodyBytes));
        return parsed;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HTTP GET Error] $e');
      }
    }

    return null;
  }

  /// POST 요청
  /// [path]: API 엔드포인트
  /// [item]: 전송할 데이터 (Map 또는 Object)
  static post(String path, Object item) async {
    final config = CConfig();

    try {
      final url = '${config.serverUrl}$path';
      if (kDebugMode) {
        print('[HTTP POST] $url');
        print('[HTTP POST Body] ${jsonEncode(item)}');
      }

      var result = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.token}',
        },
        body: jsonEncode(item),
      );

      if (kDebugMode) {
        print('[HTTP POST Response] Status: ${result.statusCode}');
      }

      if (result.statusCode == 200) {
        return json.decode(utf8.decode(result.bodyBytes));
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HTTP POST Error] $e');
      }
    }

    return null;
  }

  /// INSERT 요청 (POST와 유사하지만 생성된 ID를 반환)
  /// [path]: API 엔드포인트
  /// [item]: 생성할 데이터
  /// 반환: 생성된 항목의 ID
  static insert(String path, Object item) async {
    final config = CConfig();

    try {
      var result = await http.post(
        Uri.parse('${config.serverUrl}$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.token}',
        },
        body: jsonEncode(item),
      );
      if (result.statusCode == 200) {
        final parsed = json.decode(utf8.decode(result.bodyBytes));
        return parsed["id"];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    return 0;
  }

  /// PUT 요청 (업데이트)
  /// [path]: API 엔드포인트
  /// [item]: 업데이트할 데이터
  static put(String path, Object item) async {
    final config = CConfig();

    try {
      var result = await http.put(
        Uri.parse('${config.serverUrl}$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.token}',
        },
        body: jsonEncode(item),
      );
      if (result.statusCode == 200) {
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// DELETE 요청
  /// [path]: API 엔드포인트
  /// [item]: 삭제할 항목 정보
  static delete(String path, Object item) async {
    final config = CConfig();

    try {
      var result = await http.delete(
        Uri.parse('${config.serverUrl}$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.token}',
        },
        body: jsonEncode(item),
      );
      if (result.statusCode == 200) {}
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// 파일 업로드
  /// [url]: 업로드 API 엔드포인트
  /// [name]: 파일 필드 이름
  /// [path]: 업로드할 파일 경로
  /// 반환: 업로드된 파일명
  static upload(String url, String name, String path) async {
    final config = CConfig();

    Map<String, String> headers = {'Authorization': "Bearer ${config.token}"};

    http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse('${config.serverUrl}$url'),
    );
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath(name, path));

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      var responseData = await json.decode(utf8.decode(responsed.bodyBytes));

      return responseData['filename'];
    }

    return '';
  }
}
