# FCM 설정 완료 및 테스트 가이드

## ✅ 완료된 설정

### Android
- ✅ `android/settings.gradle.kts` - Google Services 플러그인 추가
- ✅ `android/app/build.gradle.kts` - Firebase Messaging 의존성 추가
- ✅ `android/app/google-services.json` - Firebase 설정 파일 배치

### iOS
- ⚠️ `ios/Runner/GoogleService-Info.plist` - **수동 추가 필요** (Xcode 사용)

### Flutter
- ✅ `pubspec.yaml` - Firebase 패키지 설치됨
- ✅ `lib/services/notification_service.dart` - FCM 초기화 및 토큰 관리
- ✅ `lib/main.dart` - 앱 시작 시 NotificationService 초기화

## 📱 앱 실행 및 FCM 토큰 확인

### 방법 1: Android 기기/에뮬레이터에서 실행

```bash
flutter run
```

### 방법 2: iOS 시뮬레이터에서 실행 (GoogleService-Info.plist 추가 후)

1. **GoogleService-Info.plist 추가**:
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Firebase Console에서 다운로드한 파일을 Runner 폴더로 드래그
   - "Copy items if needed" 체크
   - Target: Runner 선택

2. **앱 실행**:
   ```bash
   flutter run -d ios
   ```

### 로그 확인

앱이 실행되면 콘솔에서 다음 메시지를 확인하세요:

#### 성공 시:
```
FCM Token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
알림 권한 상태: AuthorizationStatus.authorized
```

#### Firebase 설정 파일 없을 때:
```
Firebase 초기화 실패 (로컬 알림만 사용): [오류 메시지]
```
→ 이 경우에도 로컬 알림은 정상 작동합니다.

## 🔥 Firebase Console에서 테스트 알림 전송

1. **Firebase Console 접속**: https://console.firebase.google.com/
2. **프로젝트 선택**
3. **Messaging** 섹션으로 이동
4. **"첫 번째 캠페인 만들기"** 또는 **"새 알림"** 클릭
5. **알림 메시지 작성**:
   - 알림 제목: `테스트 알림`
   - 알림 텍스트: `Firebase가 정상적으로 연결되었습니다!`
6. **"테스트 메시지 전송"** 클릭
7. **FCM 등록 토큰 추가**:
   - 앱 로그에서 복사한 FCM Token 입력
8. **테스트** 클릭

### 예상 결과

- **포그라운드 (앱 실행 중)**: 앱 내에서 알림 표시
- **백그라운드 (앱 최소화)**: 시스템 알림 트레이에 표시

## 🐛 문제 해결

### Android

#### 1. Firebase 초기화 오류
```
[ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: [core/no-app]
```

**해결방법**:
- `android/app/google-services.json` 파일 위치 확인
- 파일 내 `package_name`이 `com.example.app`인지 확인
- `flutter clean` 후 재실행

#### 2. Gradle 빌드 실패
```
A problem occurred configuring project ':app'.
```

**해결방법**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 3. NDK 오류
```
NDK at /path/to/ndk did not have a source.properties file
```

**해결방법**:
```bash
# NDK 폴더 삭제 (Android Gradle Plugin이 자동으로 재다운로드)
rm -rf ~/Library/Android/sdk/ndk/28.2.13676358
```

또는 에뮬레이터/실제 기기에서 직접 실행:
```bash
flutter run
```

### iOS

#### 1. GoogleService-Info.plist not found
```
[VERBOSE-2:dart_vm_initializer.cc(41)] Unhandled Exception: [core/no-app]
```

**해결방법**:
- Xcode에서 `ios/Runner.xcworkspace` 열기
- `GoogleService-Info.plist` 파일이 Runner 폴더에 있는지 확인
- Xcode의 "Copy Bundle Resources"에 포함되어 있는지 확인

#### 2. APNs 인증 필요
**실제 기기에서 테스트하려면**:
- Firebase Console → 프로젝트 설정 → Cloud Messaging
- APNs 인증 키 또는 인증서 업로드 필요

## 📊 현재 상태

### 구현 완료
- [x] Firebase Android 설정
- [x] FCM 토큰 생성 및 로그 출력
- [x] 포그라운드 메시지 처리
- [x] 백그라운드 메시지 처리
- [x] 로컬 스케줄 알림 (이용권 만료 D-7, D-3, D-1, D-Day)
- [x] 알림 권한 요청
- [x] 알림 설정 화면

### 구현 예정
- [ ] iOS Firebase 설정 (GoogleService-Info.plist 추가)
- [ ] FCM 토큰 서버 전송 API
- [ ] 이용권 구매 시 만료 알림 자동 스케줄링
- [ ] 운동 독려 알림 (3일 미출석)
- [ ] 서버에서 FCM 푸시 알림 전송

## 🚀 다음 단계

1. **iOS 설정 완료** (선택사항, Android만으로도 테스트 가능)
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **앱 실행 및 FCM 토큰 확인**
   ```bash
   flutter run
   ```

3. **Firebase Console에서 테스트 알림 전송**

4. **FCM 토큰 서버 전송 API 구현**
   - `lib/services/notification_service.dart`의 TODO 부분 구현
   - 서버 API 엔드포인트: `POST /api/user/fcm-token`
   - 바디: `{ "fcm_token": "..." }`

5. **이용권 구매 시 자동 알림 스케줄링**
   - 결제 완료 후 `NotificationProvider.scheduleMembershipExpiryNotifications()` 호출

---

**문의사항이나 오류가 발생하면 로그를 확인하고 위의 문제 해결 섹션을 참고하세요!**
