# 🏋️ Gym Management App

헬스장 회원 관리를 위한 Flutter 기반 모바일 애플리케이션입니다.  
회원가입, 이용권 관리, QR 출석체크, 운동 기록, 결제 내역 조회 등 헬스장 이용에 필요한 모든 기능을 제공합니다.

---

## 📋 주요 기능

### 🔐 인증 & 계정
- **로그인 / 회원가입** — 일반 로그인 및 소셜 로그인 (카카오, 네이버, 구글, Apple)
- **아이디/비밀번호 찾기** — SMS / 이메일 인증 기반 계정 복구
- **자동 로그인** — 토큰 기반 자동 인증 유지
- **프로필 관리** — 개인정보 수정 및 계정 설정

### 🏢 체육관
- **체육관 검색** — 이름, 위치 기반 검색 및 필터링
- **체육관 상세 정보** — 시설 정보, 운영 시간, 위치 등 확인

### 🎫 이용권 & 결제
- **이용권 관리** — 활성 이용권 확인, 잔여 일수 표시
- **이용권 플랜 선택** — 기간별, 타입별 다양한 이용권 선택
- **결제** — 이용권 결제 처리
- **결제 내역** — 결제 이력 조회 및 상세 영수증 확인

### 📱 QR 출석 체크
- **QR 코드 생성** — 회원 고유 QR 코드 표시
- **전체 화면 QR** — 체육관 스캐너에 편리한 전체 화면 모드

### 💪 운동 관리
- **운동 기록** — 일별 운동 내용 기록 및 관리
- **통계** — 주간/월간 출석 통계, 운동 데이터 시각화 (차트)

### 🔔 알림
- **푸시 알림** — Firebase Cloud Messaging (FCM) 기반 알림
- **로컬 알림** — 앱 내 로컬 알림 지원
- **알림 설정** — 카테고리별 알림 ON/OFF 관리

### ⚙️ 설정
- **앱 설정** — 테마, 알림 등 개인화 설정
- **버전 정보** — 앱 버전 확인

---

## 🛠 기술 스택

| 구분 | 기술 |
|------|------|
| **Framework** | Flutter (Dart SDK ^3.7.2) |
| **상태 관리** | Provider |
| **HTTP 통신** | http 패키지 |
| **로컬 저장소** | SharedPreferences |
| **푸시 알림** | Firebase Messaging + flutter_local_notifications |
| **차트** | fl_chart |
| **캘린더** | table_calendar |
| **QR 코드** | qr_flutter |
| **아이콘** | Cupertino Icons |
| **폰트** | Pretendard |

---

## 📁 프로젝트 구조

```
lib/
├── main.dart                  # 앱 엔트리포인트 & 라우팅
├── components/                # 재사용 가능한 UI 컴포넌트
│   ├── gym_button.dart        #   커스텀 버튼
│   ├── gym_textfield.dart     #   커스텀 텍스트 필드
│   ├── gym_card.dart          #   체육관 정보 카드
│   ├── gym_layout.dart        #   공통 레이아웃
│   ├── gym_dialog.dart        #   다이얼로그
│   ├── gym_snackbar.dart      #   스낵바
│   ├── gym_loading.dart       #   로딩 인디케이터
│   ├── gym_bottom_navigation.dart  #   바텀 네비게이션
│   ├── social_login_button.dart    #   소셜 로그인 버튼
│   ├── infinite_scroll_list.dart   #  무한 스크롤 리스트
│   └── ...
├── config/                    # 설정 파일
│   ├── config.dart            #   서버 URL & API 엔드포인트
│   ├── app_colors.dart        #   앱 컬러 시스템
│   ├── app_text_styles.dart   #   텍스트 스타일
│   ├── app_spacing.dart       #   간격 상수
│   └── http.dart              #   HTTP 클라이언트 설정
├── model/                     # 데이터 모델 (46개)
│   ├── user.dart              #   사용자
│   ├── gym.dart               #   체육관
│   ├── membership.dart        #   이용권
│   ├── payment.dart           #   결제
│   ├── attendance.dart        #   출석
│   ├── workoutlog.dart        #   운동 기록
│   └── ...
├── providers/                 # 상태 관리 (Provider)
│   ├── auth_provider.dart     #   인증 상태
│   ├── gym_provider.dart      #   체육관 데이터
│   ├── membership_provider.dart  #   이용권 상태
│   ├── workout_provider.dart  #   운동 기록 상태
│   ├── statistics_provider.dart  #   통계 데이터
│   ├── notification_provider.dart  #   알림 상태
│   ├── order_provider.dart    #   주문/결제 상태
│   ├── settings_provider.dart #   설정 상태
│   └── usehealth_provider.dart  #   건강 데이터
├── screens/                   # 화면 (17개)
│   ├── login_screen.dart      #   로그인
│   ├── signup_screen.dart     #   회원가입
│   ├── find_id_pw_screen.dart #   아이디/비밀번호 찾기
│   ├── home_screen.dart       #   홈
│   ├── gym_search_screen.dart #   체육관 검색
│   ├── membership_screen.dart #   이용권 관리
│   ├── membership_detail_screen.dart  #   이용권 상세
│   ├── membership_plan_screen.dart    #   이용권 플랜
│   ├── payment_screen.dart    #   결제
│   ├── payment_history_screen.dart    #   결제 내역
│   ├── payment_detail_screen.dart     #   결제 상세
│   ├── workout_screen.dart    #   운동 기록
│   ├── statistics_screen.dart #   통계
│   ├── profile_screen.dart    #   프로필
│   ├── settings_screen.dart   #   설정
│   ├── notification_settings_screen.dart  #   알림 설정
│   └── membership_screen_fullscreen_qr.dart  #   전체화면 QR
├── services/                  # 서비스
│   └── notification_service.dart  #   알림 서비스 (FCM + 로컬)
└── utils/                     # 유틸리티
```

---

## 🚀 시작하기

### 사전 준비

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.7.2)
- Android Studio 또는 Xcode (플랫폼별)
- 백엔드 API 서버 실행 (`back/` 디렉토리)

### 설치 및 실행

```bash
# 1. 의존성 설치
flutter pub get

# 2. 서버 URL 설정 (lib/config/config.dart)
# static const serverUrl = 'http://localhost:8004';

# 3. 앱 실행
flutter run
```

### 빌드

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🔗 API 서버

이 앱은 백엔드 API 서버와 통신합니다. 주요 API 엔드포인트:

| 엔드포인트 | 설명 |
|-----------|------|
| `/api/auth` | 인증 (로그인, 회원가입, 토큰) |
| `/api/user` | 사용자 정보 관리 |
| `/api/gym` | 체육관 정보 |
| `/api/membership` | 이용권 관리 |
| `/api/payment` | 결제 처리 |
| `/api/attendance` | 출석 체크 |
| `/api/health` | 건강/운동 데이터 |
| `/api/notice` | 공지사항 |
| `/api/inquiry` | 문의사항 |

> 서버 URL은 `lib/config/config.dart`에서 환경에 맞게 변경하세요.

---

## 📱 지원 플랫폼

- ✅ Android
- ✅ iOS
- 🔲 Web (기본 지원, 제한적)

---

## 📂 관련 프로젝트

```
gym_management/
├── app/          ← 현재 프로젝트 (Flutter 모바일 앱)
├── back/         ← 백엔드 API 서버
├── front/        ← 프론트엔드 웹
├── kotlin/       ← Kotlin 프로젝트
└── design_assets/  ← 디자인 리소스
```
