import 'dart:io';

class Config {
  static const serverUrl = 'http://10.0.1.62:9004';

  static String platform() {
    try {
      if (Platform.isAndroid) {
        return 'android';
      } else if (Platform.isIOS) {
        return 'ios';
      }
    } catch (e) {
      return 'web';
    }

    return 'web';
  }
}
