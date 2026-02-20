# Provider Implementation Guide

Complete guide for implementing Provider-based state management in your Gym App screens.

## Table of Contents
1. [Quick Start](#quick-start)
2. [Screen-by-Screen Migration](#screen-by-screen-migration)
3. [Common Patterns](#common-patterns)
4. [Testing](#testing)

## Quick Start

### Setup (Already Done ✅)

1. Provider package added to `pubspec.yaml`
2. Three providers created:
   - `AuthProvider` - Authentication
   - `GymProvider` - Gym data and search
   - `MembershipProvider` - Memberships
3. `main.dart` wrapped with `MultiProvider`

### Accessing Providers in Screens

```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/gym_provider.dart';
import '../providers/membership_provider.dart';

// In your widget:
final authProvider = context.watch<AuthProvider>();  // Rebuilds on change
final gymProvider = context.read<GymProvider>();     // No rebuild

// Call methods:
Provider.of<AuthProvider>(context, listen: false).login(...);
```

---

## Screen-by-Screen Migration

### 1. Login Screen

**Before:**
```dart
class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      // API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  }
}
```

**After (with Provider):**
```dart
class _LoginScreenState extends State<LoginScreen> {
  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _loginIdController.text,
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (success && mounted) {
      // Load user-specific data after login
      final membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
      final gymProvider = Provider.of<GymProvider>(context, listen: false);

      await Future.wait([
        membershipProvider.loadMemberships(authProvider.currentUser!.id),
        gymProvider.loadFavorites(authProvider.currentUser!.id),
      ]);

      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show error if exists
    if (authProvider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error!)),
        );
        authProvider.clearError();
      });
    }

    return GymLayout(
      // ... your UI
      body: Column(
        children: [
          // ... text fields
          GymButton(
            text: '로그인',
            loading: authProvider.isLoading,
            onPressed: authProvider.isLoading ? null : _handleLogin,
          ),
        ],
      ),
    );
  }
}
```

**Benefits:**
- No local `_isLoading` state needed
- Error handling centralized
- User data persists across screens
- Easy to add social login methods

---

### 2. Gym Search Screen

**Before:**
```dart
class _GymSearchScreenState extends State<GymSearchScreen> {
  List<Gym> _allGyms = [];
  List<Gym> _filteredGyms = [];
  Set<int> _favoriteGymIds = {};
  bool _isLoading = false;
  String _sortBy = 'distance';
  Set<String> _selectedFacilities = {};

  void _applyFilters() {
    setState(() {
      _filteredGyms = _allGyms.where((gym) { /* filter logic */ }).toList();
      // sorting logic...
    });
  }

  void _toggleFavorite(Gym gym) {
    setState(() {
      if (_favoriteGymIds.contains(gym.id)) {
        _favoriteGymIds.remove(gym.id);
      } else {
        _favoriteGymIds.add(gym.id);
      }
    });
  }
}
```

**After (with Provider):**
```dart
class _GymSearchScreenState extends State<GymSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load gyms on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GymProvider>(context, listen: false).loadGyms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = context.watch<GymProvider>();

    return GymLayout(
      title: '체육관 검색',
      body: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (query) => gymProvider.search(query),
            // ... decoration
          ),

          // Filter Button
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterBottomSheet(context, gymProvider),
          ),

          // Results
          Expanded(
            child: gymProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: gymProvider.filteredGyms.length,
                    itemBuilder: (context, index) {
                      final gym = gymProvider.filteredGyms[index];
                      return GymCard(
                        gym: gym,
                        isFavorite: gymProvider.isFavorite(gym.id),
                        onFavorite: () => gymProvider.toggleFavorite(gym.id),
                        onTap: () => _navigateToGymDetail(gym),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, GymProvider gymProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        sortBy: gymProvider.sortBy,
        selectedFacilities: gymProvider.selectedFacilities,
        onApply: (sortBy, facilities) {
          gymProvider.setSortBy(sortBy);
          gymProvider.setFacilities(facilities);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

**Benefits:**
- All filter state managed centrally
- Favorites persist across app
- Search query preserved when navigating away
- Filters can be accessed from other screens
- No need to pass data between screens

---

### 3. Membership Screen

**Before:**
```dart
class _MembershipScreenState extends State<MembershipScreen> {
  bool _isLoading = true;
  Membership? _activeMembership;
  Gym? _gym;
  List<Membership> _membershipHistory = [];

  Future<void> _loadMembershipData() async {
    setState(() => _isLoading = true);
    try {
      // Load from API...
      setState(() {
        _activeMembership = mockMembership;
        _gym = mockGym;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
}
```

**After (with Provider):**
```dart
class _MembershipScreenState extends State<MembershipScreen> {
  @override
  void initState() {
    super.initState();
    _loadMemberships();
  }

  Future<void> _loadMemberships() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final membershipProvider = Provider.of<MembershipProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await membershipProvider.loadMemberships(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membershipProvider = context.watch<MembershipProvider>();

    return GymLayout(
      title: '내 이용권',
      body: membershipProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : membershipProvider.hasActiveMembership
              ? _buildActiveMembership(membershipProvider)
              : _buildEmptyState(),
    );
  }

  Widget _buildActiveMembership(MembershipProvider provider) {
    return RefreshIndicator(
      onRefresh: _loadMemberships,
      child: SingleChildScrollView(
        child: Column(
          children: [
            MembershipCard(
              membership: provider.activeMembership!,
              gym: provider.activeGym,
              remainingDays: provider.getRemainingDays(),
              onExtend: () => _navigateToPayment(provider),
              onPause: () => _showPauseDialog(provider),
            ),

            // Statistics
            if (provider.stats != null)
              StatisticsSection(stats: provider.stats!),

            // History
            if (provider.membershipHistory.isNotEmpty)
              HistorySection(history: provider.membershipHistory),
          ],
        ),
      ),
    );
  }

  void _showPauseDialog(MembershipProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용권 일시정지'),
        content: const Text('일시정지 기간을 선택하세요'),
        actions: [
          TextButton(
            onPressed: () async {
              await provider.pauseMembership(7);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('7일'),
          ),
          TextButton(
            onPressed: () async {
              await provider.pauseMembership(14);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('14일'),
          ),
        ],
      ),
    );
  }
}
```

**Benefits:**
- Membership data available across the app
- QR code data accessible from anywhere
- Statistics automatically updated
- Easy to implement check-in from multiple screens

---

### 4. Payment Screen

**After (with Provider):**
```dart
class _PaymentScreenState extends State<PaymentScreen> {
  int _currentStep = 0;
  int _selectedPlanIndex = 0;
  String _selectedPaymentMethod = '';

  Future<void> _processPayment() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final membershipProvider = Provider.of<MembershipProvider>(context, listen: false);

    final plan = _membershipPlans[_selectedPlanIndex];

    final success = await membershipProvider.purchaseMembership(
      userId: authProvider.currentUser!.id,
      gymId: widget.gym.id,
      plan: plan['name'],
      price: plan['discountPrice'] ?? plan['price'],
      paymentMethod: _selectedPaymentMethod,
    );

    if (success && mounted) {
      setState(() => _currentStep = 2);
      _pageController.animateToPage(2, ...);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(membershipProvider.error ?? '결제 실패')),
      );
      membershipProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final membershipProvider = context.watch<MembershipProvider>();

    return GymLayout(
      title: '이용권 결제',
      body: Column(
        children: [
          // Progress indicator
          PaymentProgressIndicator(currentStep: _currentStep),

          // Payment steps...
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPlanSelection(),
                _buildPaymentMethod(),
                _buildReceipt(),
              ],
            ),
          ),

          // Next button
          GymButton(
            text: _getButtonText(),
            loading: membershipProvider.isLoading,
            onPressed: membershipProvider.isLoading ? null : _handleNextStep,
          ),
        ],
      ),
    );
  }
}
```

**Benefits:**
- Membership automatically created and stored
- Can navigate to membership screen after purchase
- Payment history tracked
- User can view receipt from membership screen

---

## Common Patterns

### Pattern 1: Load Data on Screen Init

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<GymProvider>(context, listen: false);
    provider.loadGyms();
  });
}
```

### Pattern 2: Multiple Provider Access

```dart
@override
Widget build(BuildContext context) {
  final auth = context.watch<AuthProvider>();
  final membership = context.watch<MembershipProvider>();

  return Text('Hello ${auth.currentUser?.name}, ${membership.getRemainingDays()} days left');
}
```

### Pattern 3: Conditional Loading

```dart
Future<void> _loadUserData() async {
  final auth = Provider.of<AuthProvider>(context, listen: false);

  if (!auth.isAuthenticated) {
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  final membership = Provider.of<MembershipProvider>(context, listen: false);
  await membership.loadMemberships(auth.currentUser!.id);
}
```

### Pattern 4: Error Display with PostFrameCallback

```dart
@override
Widget build(BuildContext context) {
  final provider = context.watch<GymProvider>();

  if (provider.error != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
      provider.clearError();
    });
  }

  return /* your widget */;
}
```

### Pattern 5: Pull-to-Refresh

```dart
Widget build(BuildContext context) {
  final provider = context.watch<GymProvider>();

  return RefreshIndicator(
    onRefresh: () => provider.loadGyms(),
    child: ListView.builder(
      itemCount: provider.filteredGyms.length,
      itemBuilder: (context, index) => GymCard(gym: provider.filteredGyms[index]),
    ),
  );
}
```

---

## Testing

### Unit Testing Providers

```dart
void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('login sets authenticated state', () async {
      expect(authProvider.isAuthenticated, false);

      await authProvider.login('testuser', 'password');

      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser, isNotNull);
    });

    test('logout clears user data', () async {
      await authProvider.login('testuser', 'password');
      await authProvider.logout();

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, isNull);
    });
  });
}
```

### Widget Testing with Provider

```dart
testWidgets('Login screen shows error on failed login', (tester) async {
  final authProvider = AuthProvider();

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: MaterialApp(home: LoginScreen()),
    ),
  );

  // Enter credentials
  await tester.enterText(find.byType(TextField).first, 'baduser');
  await tester.enterText(find.byType(TextField).last, 'badpass');

  // Tap login
  await tester.tap(find.text('로그인'));
  await tester.pumpAndSettle();

  // Verify error is shown
  expect(find.text('로그인 실패'), findsOneWidget);
});
```

---

## Migration Checklist

For each screen:

- [ ] Import provider package
- [ ] Replace local state variables with provider access
- [ ] Replace setState() calls with provider methods
- [ ] Move API calls to provider methods
- [ ] Use context.watch() for UI updates
- [ ] Use context.read() for event handlers
- [ ] Handle loading and error states from provider
- [ ] Test the screen functionality

---

## Next Steps

1. **Start with Login Screen**: Simplest integration
2. **Then Gym Search**: Shows filter management
3. **Then Membership**: Shows data sharing
4. **Finally Payment**: Shows cross-provider coordination

## Support

Refer to:
- `/lib/providers/README.md` - Provider architecture documentation
- Provider package docs: https://pub.dev/packages/provider
- Flutter state management: https://flutter.dev/docs/development/data-and-backend/state-mgmt

Happy coding! 🚀
