# Gym App - Screen Architecture Design

## Design Overview

This document outlines the comprehensive screen architecture for the Gym Management App, applying design patterns learned from the player app project.

### Key Design Patterns Applied

1. **Component-based Architecture**: Reusable UI components (buttons, text fields, layouts)
2. **Consistent Styling**: Unified color scheme and design language
3. **State Management**: StatefulWidget for interactive screens
4. **Model-driven Development**: Utilizing existing model classes (User, Gym, Membership, Payment)
5. **Navigation Architecture**: Named routes with clear navigation flow

---

## 1. Authentication Screens

### 1.1 Login Screen (로그인)

**File**: `lib/screens/login_screen.dart`

**Current Status**: Basic implementation exists
**Enhancement**: Apply player app design patterns

#### Design Features
- Custom background image support
- Branded header with gym icon
- Social login support (Kakao, Naver, Google, Apple)
- Remember me functionality
- Error state handling with validation

#### Component Structure
```
LoginScreen (StatefulWidget)
├── Background Layout (Optional image)
├── AppBar
│   └── Center Title: "로그인"
├── Body (Center-aligned Column)
│   ├── Logo/Brand Icon
│   ├── Login Form
│   │   ├── ID TextField (with icon)
│   │   ├── Password TextField (with obscure text)
│   │   └── Error Messages (conditional)
│   ├── Login Button
│   ├── Social Login Buttons
│   │   ├── Kakao Login
│   │   ├── Naver Login
│   │   ├── Google Login
│   │   └── Apple Login
│   └── Bottom Actions Row
│       ├── Find ID/Password Button
│       └── Sign Up Button
```

#### Key Components to Create
- `GymTextField`: Custom text field with validation
- `GymButton`: Styled button with different types (filled, outlined, social)
- `SocialLoginButton`: Specialized button for OAuth providers

#### User Flow
1. User enters loginid and password
2. Validation on both fields
3. API call to `/api/user/login`
4. On success: Navigate to home/gym search
5. On failure: Show error message
6. Alternative: Social login redirects to OAuth flow

#### API Integration
```dart
// Login endpoint
POST /api/user/login
Body: {
  "loginid": String,
  "passwd": String
}
Response: {
  "user": User,
  "token": String
}
```

---

### 1.2 Sign Up Screen (회원가입)

**File**: `lib/screens/signup_screen.dart`

**Current Status**: Placeholder
**Enhancement**: Complete implementation with multi-step form

#### Design Features
- Multi-step registration process
- Real-time validation
- Terms and conditions acceptance
- Profile image upload (optional)
- Duplicate check for loginid/email

#### Component Structure
```
SignupScreen (StatefulWidget)
├── AppBar
│   └── Title: "회원가입"
│   └── Back Button
├── Progress Indicator (Step 1/2/3)
├── Body (Scrollable)
│   ├── Step 1: Account Information
│   │   ├── Login ID TextField (with duplicate check)
│   │   ├── Password TextField (with strength indicator)
│   │   ├── Password Confirm TextField
│   │   └── Email TextField (with verification)
│   ├── Step 2: Personal Information
│   │   ├── Name TextField
│   │   ├── Phone TextField
│   │   ├── Birth Date Picker
│   │   ├── Gender Selector
│   │   └── Address TextField (optional)
│   ├── Step 3: Terms Agreement
│   │   ├── All Agree Checkbox
│   │   ├── Terms of Service (Required)
│   │   ├── Privacy Policy (Required)
│   │   └── Marketing Consent (Optional)
│   └── Submit Button
```

#### Validation Rules
- **Login ID**: 4-20 characters, alphanumeric only
- **Password**: 8+ characters, must include letters and numbers
- **Email**: Valid email format
- **Phone**: Korean phone format (010-XXXX-XXXX)
- **Name**: 2+ characters

#### User Flow
1. Enter account information → Validate → Next
2. Enter personal information → Next
3. Accept terms → Submit
4. API call to `/api/user/register`
5. On success: Show success dialog → Navigate to login
6. On failure: Show error and allow retry

#### API Integration
```dart
// Check duplicate loginid
GET /api/user/check-loginid?loginid={loginid}
Response: { "available": Boolean }

// Register user
POST /api/user/register
Body: {
  "loginid": String,
  "passwd": String,
  "email": String,
  "name": String,
  "tel": String,
  "birth": String,
  "sex": int,
  "address": String?,
  "type": int (UserType.normal)
}
Response: {
  "id": int,
  "message": String
}
```

---

### 1.3 Find ID/Password Screen (아이디/비밀번호 찾기)

**File**: `lib/screens/find_id_pw_screen.dart`

**Current Status**: Placeholder
**Enhancement**: Tab-based interface for ID and password recovery

#### Design Features
- Tab interface (Find ID / Find Password)
- Email or Phone verification
- Verification code system
- Password reset functionality

#### Component Structure
```
FindIdPwScreen (StatefulWidget)
├── AppBar
│   └── Title: "아이디/비밀번호 찾기"
├── TabBar
│   ├── Tab: "아이디 찾기"
│   └── Tab: "비밀번호 찾기"
├── TabBarView
│   ├── Find ID Tab
│   │   ├── Name TextField
│   │   ├── Phone TextField
│   │   ├── Verification Code TextField
│   │   ├── Send Code Button
│   │   ├── Timer Display
│   │   └── Find ID Button
│   │   └── Result Display (conditional)
│   └── Find Password Tab
│       ├── Login ID TextField
│       ├── Name TextField
│       ├── Email TextField
│       ├── Verification Code TextField
│       ├── Send Code Button
│       ├── New Password TextField
│       ├── Confirm Password TextField
│       └── Reset Password Button
```

#### User Flow - Find ID
1. Enter name and phone number
2. Click "인증번호 발송"
3. Receive verification code via SMS
4. Enter code within 3 minutes
5. API verifies and returns masked login ID
6. Display: "귀하의 아이디는 abc***입니다"

#### User Flow - Find Password
1. Enter login ID, name, and email
2. Click "인증번호 발송"
3. Receive verification code via email
4. Enter code and new password
5. API resets password
6. Show success → Navigate to login

#### API Integration
```dart
// Send verification code for ID recovery
POST /api/user/send-code-id
Body: { "name": String, "tel": String }
Response: { "success": Boolean, "expires": DateTime }

// Verify code and get ID
POST /api/user/find-id
Body: { "name": String, "tel": String, "code": String }
Response: { "loginid": String (masked) }

// Send verification code for password reset
POST /api/user/send-code-password
Body: { "loginid": String, "name": String, "email": String }
Response: { "success": Boolean, "expires": DateTime }

// Reset password
POST /api/user/reset-password
Body: { "loginid": String, "code": String, "newPasswd": String }
Response: { "success": Boolean }
```

---

## 2. Main Feature Screens

### 2.1 Gym Search Screen (체육관 검색)

**File**: `lib/screens/gym_search_screen.dart`

**Current Status**: Placeholder
**Enhancement**: Search with filters and map integration

#### Design Features
- Search bar with real-time suggestions
- Filter by location, facilities, price range
- List and map view toggle
- Gym card with key information
- Favorite/bookmark functionality

#### Component Structure
```
GymSearchScreen (StatefulWidget)
├── AppBar
│   └── Search TextField (persistent)
├── Filter Bar
│   ├── Location Filter Chip
│   ├── Price Range Chip
│   └── Facilities Chip
├── View Toggle (List/Map)
├── Body
│   ├── Search Results List
│   │   └── Gym Card (repeating)
│   │       ├── Gym Image
│   │       ├── Gym Name
│   │       ├── Address
│   │       ├── Phone Number
│   │       ├── Price Info
│   │       ├── Rating (if available)
│   │       └── Favorite Icon Button
│   └── Map View (alternative)
│       └── Gym Markers
└── Floating Action Button (My Location)
```

#### Gym Card Component
```dart
class GymCard {
  - Gym image (fallback to default)
  - Name (bold, prominent)
  - Address with location icon
  - Phone with call button
  - Distance from user location
  - Basic membership price
  - Bookmark/favorite button
  - onTap: Navigate to gym detail
}
```

#### Search Features
- **Real-time Search**: As user types, filter results
- **Filters**:
  - Location (current location, radius)
  - Price range slider
  - Facilities (PT available, shower, parking, etc.)
- **Sorting**: Distance, price, rating, newest

#### User Flow
1. Screen opens with nearby gyms (requires location permission)
2. User can search by name or address
3. Apply filters to narrow results
4. Toggle between list and map view
5. Tap gym card to view details
6. From details, can view membership options
7. Can bookmark favorite gyms

#### API Integration
```dart
// Search gyms
GET /api/gym/search?q={query}&lat={lat}&lng={lng}&radius={radius}
Response: {
  "items": [Gym],
  "total": int
}

// Get nearby gyms
GET /api/gym/nearby?lat={lat}&lng={lng}&radius={radius}
Response: {
  "items": [Gym],
  "total": int
}

// Bookmark gym
POST /api/user/bookmark
Body: { "gymId": int }
```

---

### 2.2 Membership Screen (이용권 확인)

**File**: `lib/screens/membership_screen.dart`

**Current Status**: Placeholder
**Enhancement**: User membership management with QR code

#### Design Features
- Active membership display
- QR code for check-in
- Remaining days/visits counter
- Membership history
- Usage statistics
- Renewal/extension options

#### Component Structure
```
MembershipScreen (StatefulWidget)
├── AppBar
│   └── Title: "내 이용권"
├── Body (Scrollable)
│   ├── Active Membership Section
│   │   ├── If No Active Membership
│   │   │   ├── Empty State Illustration
│   │   │   ├── Message: "활성 이용권이 없습니다"
│   │   │   └── Search Gym Button
│   │   └── If Has Active Membership
│   │       ├── Membership Card
│   │       │   ├── Gym Name
│   │       │   ├── Membership Type
│   │       │   ├── Start/End Date
│   │       │   ├── Remaining Days Display
│   │       │   ├── QR Code (expandable)
│   │       │   └── Status Badge
│   │       ├── Usage Progress Bar
│   │       └── Action Buttons
│   │           ├── Extend/Renew Button
│   │           ├── Pause/Stop Button
│   │           └── Details Button
│   ├── Statistics Section
│   │   ├── Total Visits This Month
│   │   ├── Average Visits Per Week
│   │   └── Workout Streak
│   └── History Section
│       ├── Section Header: "이용권 내역"
│       └── Membership History List
│           └── History Card (repeating)
│               ├── Gym Name
│               ├── Membership Period
│               ├── Status (active/expired/stopped)
│               └── Details Button
```

#### Membership Card Design
- **Visual Priority**: Large, prominent card
- **Color Coding**: Different colors for membership status
  - Active: Green/Blue gradient
  - Expiring Soon (<7 days): Orange
  - Expired: Grey
- **QR Code**: Tap to expand full screen for scanning
- **Information Hierarchy**:
  - Primary: Gym name, remaining days
  - Secondary: Dates, membership type
  - Tertiary: Additional details

#### QR Code Feature
```dart
// QR Code contains:
{
  "membershipId": int,
  "userId": int,
  "gymId": int,
  "validUntil": DateTime,
  "signature": String (for verification)
}
```

#### User Flow
1. Screen shows active membership(s)
2. User can tap QR code to expand for gym check-in
3. View remaining days/visits
4. Tap "연장하기" to extend membership
5. Tap "일시정지" to pause membership (if allowed)
6. View usage statistics
7. Scroll to see membership history

#### API Integration
```dart
// Get user memberships
GET /api/membership/user/{userId}
Response: {
  "active": [Membership],
  "history": [Membership]
}

// Get membership details with gym info
GET /api/membership/{id}/details
Response: {
  "membership": Membership,
  "gym": Gym,
  "stats": {
    "totalVisits": int,
    "remainingDays": int,
    "usagePercentage": double
  }
}

// Generate QR code
GET /api/membership/{id}/qrcode
Response: {
  "qrData": String,
  "expiresAt": DateTime
}
```

---

### 2.3 Payment Screen (이용권 결제)

**File**: `lib/screens/payment_screen.dart`

**Current Status**: Placeholder
**Enhancement**: Multi-step payment process

#### Design Features
- Membership plan selection
- Payment method selection
- Terms agreement
- Payment gateway integration
- Receipt/confirmation

#### Component Structure
```
PaymentScreen (StatefulWidget)
├── AppBar
│   └── Title: "이용권 결제"
│   └── Close Button
├── Progress Indicator (Step 1/2/3)
├── Body (Scrollable)
│   ├── Step 1: Membership Selection
│   │   ├── Gym Information Card
│   │   │   ├── Gym Name
│   │   │   ├── Address
│   │   │   └── Phone
│   │   ├── Membership Plans List
│   │   │   └── Plan Card (repeating)
│   │   │       ├── Plan Name (1개월권, 3개월권, etc.)
│   │   │       ├── Duration
│   │   │       ├── Price (with discount badge)
│   │   │       ├── Features List
│   │   │       └── Select Radio Button
│   │   └── Next Button
│   ├── Step 2: Payment Method
│   │   ├── Selected Plan Summary
│   │   │   ├── Plan Details
│   │   │   └── Total Amount
│   │   ├── Payment Methods
│   │   │   ├── Credit Card
│   │   │   ├── Bank Transfer
│   │   │   ├── Kakao Pay
│   │   │   ├── Naver Pay
│   │   │   └── Toss Pay
│   │   ├── Discount Code Input
│   │   ├── Terms Agreement
│   │   │   ├── Payment Terms (Required)
│   │   │   └── Refund Policy (Required)
│   │   └── Pay Button
│   └── Step 3: Payment Result
│       ├── Success Icon
│       ├── Receipt Information
│       │   ├── Order Number
│       │   ├── Gym Name
│       │   ├── Membership Plan
│       │   ├── Amount Paid
│       │   ├── Payment Method
│       │   └── Payment Date
│       └── Action Buttons
│           ├── View Membership Button
│           ├── Receipt Button
│           └── Home Button
```

#### Membership Plan Card
```dart
class MembershipPlanCard {
  - Plan name
  - Duration (days)
  - Original price
  - Discount (if applicable)
  - Final price (prominent)
  - Features included
  - Popular badge (if popular)
  - Selected indicator
  - onTap: Select plan
}
```

#### Payment Flow
1. **Plan Selection**
   - Display available plans for the gym
   - Show prices, durations, features
   - User selects one plan
   - Click "다음"

2. **Payment Method**
   - Show plan summary
   - Select payment method
   - Apply discount code (optional)
   - Accept payment terms
   - Click "결제하기"

3. **Payment Processing**
   - Show loading indicator
   - Integrate with payment gateway (PG)
   - Wait for callback

4. **Result**
   - On success: Show receipt, create membership
   - On failure: Show error, allow retry

#### Payment Methods Integration
```dart
// Supported PG providers:
- BootPay
- Iamport
- TossPayments
- KakaoPay SDK
- NaverPay SDK

// Payment flow:
1. Create order in backend
2. Get payment token
3. Open PG SDK
4. User completes payment
5. PG calls webhook
6. Backend verifies payment
7. Create membership
8. Return result to app
```

#### API Integration
```dart
// Get available plans for gym
GET /api/gym/{gymId}/plans
Response: {
  "plans": [{
    "id": int,
    "name": String,
    "duration": int,
    "price": int,
    "discountPrice": int?,
    "features": [String]
  }]
}

// Create order
POST /api/payment/create-order
Body: {
  "gymId": int,
  "planId": int,
  "userId": int,
  "discountCode": String?
}
Response: {
  "orderId": int,
  "amount": int,
  "paymentToken": String
}

// Verify and complete payment
POST /api/payment/complete
Body: {
  "orderId": int,
  "paymentId": String,
  "pgProvider": String
}
Response: {
  "success": Boolean,
  "membershipId": int,
  "receipt": {
    "orderNumber": String,
    "amount": int,
    "paymentMethod": String,
    "date": DateTime
  }
}
```

---

## 3. Component Library

### Custom Components to Create

Based on player app patterns, create these reusable components:

#### 3.1 GymTextField
**File**: `lib/components/gym_textfield.dart`

- Consistent styling across all forms
- Built-in validation
- Error message display
- Icons support
- Obscure text option
- Disabled state

```dart
enum GymTextFieldType { text, number, email, phone }

class GymTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final IconData? prefixIcon;
  final bool obscureText;
  final GymTextFieldType type;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  // ... more properties
}
```

#### 3.2 GymButton
**File**: `lib/components/gym_button.dart`

- Multiple styles (filled, outlined, text)
- Size variants (small, medium, large)
- Purpose variants (primary, secondary, danger, success)
- Loading state
- Disabled state
- Icon support

```dart
enum GymButtonSize { small, medium, large }
enum GymButtonStyle { filled, outlined, text }
enum GymButtonPurpose { primary, secondary, danger, success }

class GymButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final GymButtonSize size;
  final GymButtonStyle style;
  final GymButtonPurpose purpose;
  final bool disabled;
  final bool loading;
  final IconData? icon;
  // ... more properties
}
```

#### 3.3 GymLayout
**File**: `lib/components/gym_layout.dart`

- Consistent layout wrapper
- AppBar integration
- Background support
- Safe area handling
- Scrollable option

```dart
class GymLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final bool scrollable;
  final String? backgroundImage;
  final Color? backgroundColor;
  // ... more properties
}
```

#### 3.4 SocialLoginButton
**File**: `lib/components/social_login_button.dart`

- Branded buttons for OAuth providers
- Kakao (yellow)
- Naver (green)
- Google (white)
- Apple (black)
- Consistent sizing

```dart
enum SocialProvider { kakao, naver, google, apple }

class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;
  // ... styling properties
}
```

#### 3.5 MembershipCard
**File**: `lib/components/membership_card.dart`

- Visual card for membership display
- Status-based color coding
- QR code integration
- Progress indicators

```dart
class MembershipCard extends StatelessWidget {
  final Membership membership;
  final Gym gym;
  final VoidCallback? onTap;
  final bool showQRCode;
  // ... more properties
}
```

#### 3.6 GymCard
**File**: `lib/components/gym_card.dart`

- Display gym information in lists
- Image, name, address, price
- Favorite button
- Distance indicator

```dart
class GymCard extends StatelessWidget {
  final Gym gym;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final double? distance;
  // ... more properties
}
```

---

## 4. Navigation Architecture

### Route Structure

```dart
// lib/main.dart routes
routes: {
  '/': (context) => SplashScreen(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/find_id_pw': (context) => FindIdPwScreen(),
  '/home': (context) => HomeScreen(),
  '/gym_search': (context) => GymSearchScreen(),
  '/gym_detail': (context) => GymDetailScreen(),
  '/membership': (context) => MembershipScreen(),
  '/membership_detail': (context) => MembershipDetailScreen(),
  '/payment': (context) => PaymentScreen(),
  '/profile': (context) => ProfileScreen(),
}
```

### Navigation Flow

```
Splash Screen
    ↓
Check Authentication
    ↓
├─ Logged In → Home Screen
│                  ↓
│           [Bottom Navigation]
│              ↓        ↓        ↓
│          Gym Search  Membership  Profile
│              ↓           ↓
│          Gym Detail   QR Code
│              ↓
│          Payment
│              ↓
│          Payment Success → Membership
│
└─ Not Logged In → Login Screen
                       ↓
                   [Register] → Sign Up
                       ↓           ↓
                   Find ID/PW   Complete → Login
```

---

## 5. State Management

### Recommended Approach: Provider Pattern

```dart
// lib/providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;

  bool get isAuthenticated => _user != null;
  User? get user => _user;

  Future<bool> login(String loginid, String password) async { }
  Future<void> logout() async { }
  Future<bool> register(User user) async { }
}

// lib/providers/gym_provider.dart
class GymProvider extends ChangeNotifier {
  List<Gym> _gyms = [];
  List<Gym> _favorites = [];

  List<Gym> get gyms => _gyms;
  List<Gym> get favorites => _favorites;

  Future<void> searchGyms(String query) async { }
  Future<void> toggleFavorite(Gym gym) async { }
}

// lib/providers/membership_provider.dart
class MembershipProvider extends ChangeNotifier {
  List<Membership> _activeMemberships = [];
  List<Membership> _history = [];

  List<Membership> get active => _activeMemberships;

  Future<void> loadMemberships(int userId) async { }
  Future<String> generateQRCode(int membershipId) async { }
}
```

---

## 6. Design System

### Color Palette

```dart
// lib/config/app_colors.dart
class AppColors {
  // Primary Colors
  static const primary = Color(0xFF6750A4);  // Deep Purple
  static const onPrimary = Color(0xFFFFFFFF);

  // Secondary Colors
  static const secondary = Color(0xFF625B71);
  static const onSecondary = Color(0xFFFFFFFF);

  // Surface Colors
  static const surface = Color(0xFFFEF7FF);
  static const onSurface = Color(0xFF1D1B20);

  // Status Colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFB3261E);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF2196F3);

  // Neutral Colors
  static const grey900 = Color(0xFF212121);
  static const grey700 = Color(0xFF616161);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey100 = Color(0xFFF5F5F5);
}
```

### Typography

```dart
// lib/config/app_text_styles.dart
class AppTextStyles {
  // Headings
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Labels
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
```

### Spacing

```dart
// lib/config/app_spacing.dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
```

---

## 7. Implementation Priority

### Phase 1: Core Authentication (Week 1)
1. ✓ Create component library (GymTextField, GymButton, GymLayout)
2. ✓ Implement Login Screen with full functionality
3. ✓ Implement Sign Up Screen (all steps)
4. ✓ Implement Find ID/Password Screen
5. ✓ Set up AuthProvider for state management
6. ✓ Integrate authentication APIs

### Phase 2: Gym Search & Discovery (Week 2)
1. ✓ Create GymCard component
2. ✓ Implement Gym Search Screen
3. ✓ Add filtering and sorting
4. ✓ Implement Gym Detail Screen
5. ✓ Add map view integration
6. ✓ Set up GymProvider

### Phase 3: Membership Management (Week 3)
1. ✓ Create MembershipCard component
2. ✓ Implement Membership Screen
3. ✓ Add QR code generation
4. ✓ Implement usage statistics
5. ✓ Add membership history
6. ✓ Set up MembershipProvider

### Phase 4: Payment Integration (Week 4)
1. ✓ Design payment flow
2. ✓ Implement Payment Screen (3 steps)
3. ✓ Integrate PG providers (Bootpay/Iamport)
4. ✓ Test payment scenarios
5. ✓ Add receipt generation
6. ✓ Handle payment callbacks

---

## 8. Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Validation logic
- Business logic in providers

### Widget Tests
- Custom components (GymTextField, GymButton)
- Screen layouts
- User interactions

### Integration Tests
- Authentication flow
- Payment process
- API integration

---

## 9. Accessibility Considerations

1. **Semantic Labels**: All interactive elements have proper labels
2. **Contrast Ratios**: Text meets WCAG AA standards
3. **Touch Targets**: Minimum 44x44 dp for all buttons
4. **Screen Reader Support**: Proper focus order and announcements
5. **Text Scaling**: Supports system text scaling

---

## 10. Performance Optimization

1. **Image Optimization**
   - Use cached network images
   - Lazy loading for lists
   - Proper image sizing

2. **List Performance**
   - ListView.builder for large lists
   - Pagination for API calls
   - Efficient state updates

3. **API Optimization**
   - Request debouncing for search
   - Caching strategies
   - Proper error handling

---

## 11. Security Considerations

1. **Authentication**
   - Secure token storage (flutter_secure_storage)
   - Token refresh mechanism
   - Biometric authentication option

2. **Payment Security**
   - PCI DSS compliant PG integration
   - No card data stored locally
   - SSL/TLS for all API calls

3. **Data Privacy**
   - Encrypt sensitive local data
   - Proper permission handling
   - GDPR compliance

---

## Conclusion

This design document provides a comprehensive blueprint for implementing the Gym App screens, applying best practices learned from the player app project. The architecture emphasizes:

- **Reusability**: Component-based approach
- **Maintainability**: Clear separation of concerns
- **Scalability**: Modular design patterns
- **User Experience**: Intuitive navigation and interactions

Next steps:
1. Review and approve design specifications
2. Begin Phase 1 implementation
3. Set up CI/CD pipeline
4. Conduct design review sessions
5. Iterate based on user feedback

---

## Appendix

### Dependencies Required

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.1

  # Networking
  http: ^1.1.0
  dio: ^5.4.0

  # Secure Storage
  flutter_secure_storage: ^9.0.0

  # QR Code
  qr_flutter: ^4.1.0
  mobile_scanner: ^3.5.5

  # UI Components
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

  # Maps
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0

  # Social Login
  kakao_flutter_sdk: ^1.7.0
  flutter_naver_login: ^1.8.0
  google_sign_in: ^6.1.6
  sign_in_with_apple: ^5.0.0

  # Payment
  bootpay: ^4.3.4
  # or iamport_flutter: ^2.0.0

  # Utils
  intl: ^0.18.1
  image_picker: ^1.0.5
```

### Folder Structure

```
lib/
├── main.dart
├── config/
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   ├── app_spacing.dart
│   └── app_config.dart
├── models/
│   ├── user.dart
│   ├── gym.dart
│   ├── membership.dart
│   ├── payment.dart
│   └── ... (existing models)
├── providers/
│   ├── auth_provider.dart
│   ├── gym_provider.dart
│   ├── membership_provider.dart
│   └── payment_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── find_id_pw_screen.dart
│   ├── home_screen.dart
│   ├── gym_search_screen.dart
│   ├── gym_detail_screen.dart
│   ├── membership_screen.dart
│   ├── membership_detail_screen.dart
│   ├── payment_screen.dart
│   └── profile_screen.dart
├── components/
│   ├── gym_textfield.dart
│   ├── gym_button.dart
│   ├── gym_layout.dart
│   ├── social_login_button.dart
│   ├── membership_card.dart
│   ├── gym_card.dart
│   └── ... (more components)
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── storage_service.dart
│   └── payment_service.dart
└── utils/
    ├── validators.dart
    ├── formatters.dart
    └── constants.dart
```
