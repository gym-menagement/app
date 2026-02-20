# Firebase Cloud Messaging (FCM) 설정 가이드

## 1. Firebase Console 설정

### 1.1 Firebase 프로젝트 생성/선택
1. https://console.firebase.google.com/ 접속
2. 기존 프로젝트 선택 또는 "프로젝트 추가" 클릭
3. 프로젝트 이름 입력: `gym-app` (또는 원하는 이름)
4. Google Analytics 활성화 (선택사항)

### 1.2 Android 앱 등록
1. Firebase 콘솔에서 프로젝트 선택
2. "앱 추가" → Android 아이콘 클릭
3. **Android 패키지 이름**: `com.example.app` (기본값, 변경 가능)
   - 실제 패키지명은 `android/app/build.gradle`에서 확인
4. 앱 닉네임: `Gym App Android` (선택사항)
5. SHA-1 인증서 지문: (선택사항, 나중에 추가 가능)
6. **`google-services.json` 파일 다운로드**
7. 다운로드한 파일을 `android/app/` 디렉토리에 저장

### 1.3 iOS 앱 등록
1. Firebase 콘솔에서 프로젝트 선택
2. "앱 추가" → iOS 아이콘 클릭
3. **iOS 번들 ID**: `com.example.app` (Xcode에서 확인)
   - Xcode에서 Runner.xcworkspace 열기
   - Runner → General → Bundle Identifier 확인
4. 앱 닉네임: `Gym App iOS` (선택사항)
5. **`GoogleService-Info.plist` 파일 다운로드**
6. Xcode에서:
   - Runner 폴더에 파일 드래그 앤 드롭
   - "Copy items if needed" 체크
   - Target: Runner 선택

### 1.4 Cloud Messaging 설정
1. 프로젝트 설정 → Cloud Messaging 탭
2. iOS 설정:
   - APNs 인증 키 업로드 (Apple Developer에서 생성)
   - 또는 APNs 인증서 업로드
3. Android는 자동으로 설정됨

## 2. 파일 배치

### Android
```
android/app/google-services.json  ← 여기에 파일 저장
```

### iOS
```
ios/Runner/GoogleService-Info.plist  ← 여기에 파일 저장 (Xcode 사용 권장)
```

## 3. 설정 파일 확인 사항

### google-services.json 예시
```json
{
  "project_info": {
    "project_number": "123456789",
    "project_id": "your-project-id",
    "storage_bucket": "your-project-id.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:...",
        "android_client_info": {
          "package_name": "com.example.app"
        }
      }
    }
  ]
}
```

### GoogleService-Info.plist 예시
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CLIENT_ID</key>
	<string>123456789-xxxxxxxx.apps.googleusercontent.com</string>
	<key>REVERSED_CLIENT_ID</key>
	<string>com.googleusercontent.apps.123456789-xxxxxxxx</string>
	<key>API_KEY</key>
	<string>AIza...</string>
	<key>GCM_SENDER_ID</key>
	<string>123456789</string>
	<key>PLIST_VERSION</key>
	<string>1</string>
	<key>BUNDLE_ID</key>
	<string>com.example.app</string>
	<key>PROJECT_ID</key>
	<string>your-project-id</string>
</dict>
</plist>
```

## 4. 현재 앱 정보

### 패키지 정보
- **Flutter 프로젝트명**: `app`
- **Android 패키지명**: `android/app/build.gradle`에서 `applicationId` 확인 필요
- **iOS Bundle ID**: Xcode에서 확인 필요

### 확인 방법

#### Android 패키지명 확인
```bash
# build.gradle에서 applicationId 찾기
grep -r "applicationId" android/app/build.gradle
```

#### iOS Bundle ID 확인
```bash
# Xcode 프로젝트 파일에서 확인
cat ios/Runner.xcodeproj/project.pbxproj | grep PRODUCT_BUNDLE_IDENTIFIER
```

또는 Xcode에서:
1. `ios/Runner.xcworkspace` 열기
2. Runner 선택 → General 탭
3. Bundle Identifier 확인

## 5. 테스트

### 5.1 앱 실행 및 FCM 토큰 확인
```bash
flutter run
```

앱 실행 후 로그에서 FCM 토큰 확인:
```
FCM Token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 5.2 Firebase Console에서 테스트 알림 전송
1. Firebase Console → Cloud Messaging
2. "새 알림" 클릭
3. 알림 제목과 텍스트 입력
4. "테스트 메시지 전송" 클릭
5. FCM 토큰 입력
6. 전송

## 6. 문제 해결

### Android에서 Firebase 초기화 오류
- `google-services.json` 파일 위치 확인
- 패키지 이름 일치 여부 확인
- `android/app/build.gradle`에 플러그인 추가 확인:
  ```gradle
  apply plugin: 'com.google.gms.google-services'
  ```

### iOS에서 Firebase 초기화 오류
- `GoogleService-Info.plist` 파일이 Xcode 프로젝트에 추가되었는지 확인
- Bundle ID 일치 여부 확인
- Xcode에서 "Copy Bundle Resources"에 포함되어 있는지 확인

### 알림이 오지 않을 때
1. 알림 권한 확인
2. FCM 토큰이 올바르게 생성되었는지 확인
3. APNs 인증 키/인증서 업로드 확인 (iOS)
4. 앱이 포그라운드/백그라운드인지 확인

## 7. 다음 단계

파일 배치 완료 후:
1. ✅ 앱 실행해서 Firebase 초기화 확인
2. ✅ FCM 토큰 생성 확인
3. ✅ 테스트 알림 전송
4. ✅ 백엔드 API에 FCM 토큰 전송 기능 구현
5. ✅ 이용권 구매 시 만료 알림 스케줄링 구현
6. ✅ 운동 독려 알림 로직 구현

---

**중요**: `google-services.json`과 `GoogleService-Info.plist` 파일은 민감한 정보를 포함하고 있으므로 `.gitignore`에 추가하는 것을 권장합니다.
