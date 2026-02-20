# Gym Design System Components

Gym 디자인 시스템을 기반으로 만든 재사용 가능한 Flutter 컴포넌트 라이브러리입니다.

## 사용 방법

모든 컴포넌트를 한 번에 import하려면:

```dart
import 'package:app/components/gym_components.dart';
```

개별 컴포넌트만 import하려면:

```dart
import 'package:app/components/gym_button.dart';
import 'package:app/components/gym_card.dart';
```

## 디자인 시스템 설정

### Colors (app_colors.dart)
Gym 브랜드 컬러를 포함한 색상 팔레트:
- Primary: Gym Blue (#3182F6)
- Grayscale: 9단계의 그레이스케일
- Status Colors: Success, Error, Warning, Info

### Typography (app_text_styles.dart)
다양한 텍스트 스타일:
- Display: 큰 제목용
- Headings: 섹션 제목용 (H1-H4)
- Body: 본문 텍스트용
- Labels: 라벨 및 작은 텍스트용
- Button: 버튼 텍스트용

### Spacing (app_spacing.dart)
일관된 간격 시스템 (4px 단위):
- Base spacing: xxs(2px) ~ massive(48px)
- Component heights
- Border radius
- Icon sizes
- Avatar sizes

## 컴포넌트 목록

### 1. Buttons (GymButton)
```dart
GymButton(
  text: '확인',
  onPressed: () {},
  size: GymButtonSize.medium,
  style: GymButtonStyle.filled,
  purpose: GymButtonPurpose.primary,
)
```

**옵션:**
- Size: small, medium, large
- Style: filled, outlined, text, ghost
- Purpose: primary, secondary, success, error, warning, neutral

### 2. Text Fields (GymTextField)
```dart
GymTextField(
  labelText: 'Email',
  hintText: 'Enter your email',
  type: GymTextFieldType.email,
  prefixIcon: Icons.email_outlined,
)
```

**옵션:**
- Type: text, number, email, phone, password
- 에러 메시지 표시
- 비밀번호 보이기/숨기기 토글

### 3. Cards (GymCard, GymCardWithTitle)
```dart
GymCard(
  child: Text('Content'),
  onTap: () {},
)

GymCardWithTitle(
  title: 'Title',
  subtitle: 'Subtitle',
  child: Text('Content'),
)
```

### 4. Chips (GymChip)
```dart
GymChip(
  label: 'Chip',
  icon: Icons.star,
  selected: true,
  onTap: () {},
  onDelete: () {},
)
```

**옵션:**
- Size: small, medium, large
- Style: filled, outlined, ghost

### 5. Dividers (GymDivider, GymDividerWithText)
```dart
GymDivider()

GymDividerWithText(text: 'OR')
```

### 6. Dialogs (GymDialog)
```dart
GymDialog.showAlert(
  context: context,
  title: 'Alert',
  message: 'Message',
)

GymDialog.showConfirm(
  context: context,
  message: 'Are you sure?',
  onConfirm: () {},
)
```

### 7. Bottom Sheets (GymBottomSheet)
```dart
GymBottomSheet.show(
  context: context,
  title: 'Title',
  child: Widget(),
)

GymBottomSheet.showOptions(
  context: context,
  options: [
    GymBottomSheetOption(
      label: 'Option 1',
      icon: Icons.check,
      onTap: () {},
    ),
  ],
)
```

### 8. Loading (GymLoading)
```dart
GymLoading(size: 40)

showLoadingDialog(
  context: context,
  message: 'Loading...',
)

GymShimmer(
  child: Container(),
)
```

### 9. Avatars (GymAvatar, GymAvatarGroup)
```dart
GymAvatar(
  name: 'John Doe',
  imageUrl: 'https://...',
  size: GymAvatarSize.medium,
  showBadge: true,
)

GymAvatarGroup(
  avatars: [
    GymAvatar(name: 'A'),
    GymAvatar(name: 'B'),
  ],
  max: 3,
)
```

### 10. Snackbars (GymSnackbar)
```dart
GymSnackbar.showSuccess(
  context: context,
  message: 'Success!',
)

GymSnackbar.showError(
  context: context,
  message: 'Error!',
  actionLabel: 'Retry',
  onAction: () {},
)
```

### 11. Bottom Navigation (GymBottomNavigation)
```dart
GymBottomNavigation(
  currentIndex: _currentIndex,
  items: [
    GymBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '홈',
    ),
    GymBottomNavItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: '찾기',
    ),
    GymBottomNavItem(
      icon: Icons.card_membership_outlined,
      activeIcon: Icons.card_membership,
      label: '멤버십',
      badge: GymNavBadge.dot(),  // 빨간 점 배지
    ),
    GymBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '마이',
      badge: GymNavBadge.count(count: '3'),  // 숫자 배지
    ),
  ],
  onTap: (index) {
    setState(() => _currentIndex = index);
  },
)
```

**특징:**
- iOS/Android 플랫폼별로 최적화된 스타일
- Toss 디자인 시스템 적용
- 선택 시 부드러운 애니메이션
- 뱃지 지원 (점/숫자)
- SafeArea 자동 적용

## 데모 화면

모든 컴포넌트를 확인하려면 `DesignSystemDemoScreen`을 실행하세요:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DesignSystemDemoScreen(),
  ),
);
```

## 디자인 원칙

1. **일관성**: 모든 컴포넌트가 동일한 디자인 언어를 사용
2. **재사용성**: 다양한 상황에서 쉽게 재사용 가능
3. **접근성**: 명확한 색상 대비와 터치 영역
4. **반응성**: 다양한 화면 크기에 대응
5. **확장성**: 새로운 스타일과 옵션을 쉽게 추가 가능

## 예제

### 로그인 폼 만들기

```dart
Column(
  children: [
    GymTextField(
      labelText: 'Email',
      type: GymTextFieldType.email,
      prefixIcon: Icons.email_outlined,
    ),
    SizedBox(height: AppSpacing.lg),
    GymTextField(
      labelText: 'Password',
      obscureText: true,
      prefixIcon: Icons.lock_outlined,
    ),
    SizedBox(height: AppSpacing.xxl),
    GymButton(
      text: '로그인',
      onPressed: () {},
    ),
  ],
)
```

### 프로필 카드 만들기

```dart
GymCard(
  child: Row(
    children: [
      GymAvatar(
        name: 'John Doe',
        size: GymAvatarSize.large,
        showBadge: true,
      ),
      SizedBox(width: AppSpacing.lg),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('John Doe', style: AppTextStyles.h3),
            Text('john@example.com', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    ],
  ),
)
```
