import 'config.dart';

class CConfig {
  CConfig._privateConstructor() {
    // Config의 serverUrl을 기본값으로 사용
    serverUrl = Config.serverUrl;
  }
  static final CConfig _instance = CConfig._privateConstructor();

  factory CConfig() {
    return _instance;
  }

  String token = '';
  String serverUrl = '';

  final Map<String, dynamic> _keys = <String, dynamic>{};

  set(key, value) {
    _keys[key] = value;
  }

  get(key) {
    return _keys[key];
  }
}
