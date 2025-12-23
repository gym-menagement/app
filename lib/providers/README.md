# Provider Architecture

This directory contains the state management providers for the Gym App using the Provider pattern.

## Overview

The app uses `provider` package for state management, following a clean architecture with separation of concerns:

- **AuthProvider**: User authentication and session management
- **GymProvider**: Gym data, search, filters, and favorites
- **MembershipProvider**: Membership operations and statistics

## Provider Architecture

### AuthProvider

Manages all authentication-related state:

```dart
// Login
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await authProvider.login(loginId, password, rememberMe: true);

// Check authentication status
final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
final currentUser = context.watch<AuthProvider>().currentUser;

// Logout
await authProvider.logout();
```

**Features:**
- Email/password login
- Social login (Kakao, Naver, Google, Apple)
- User registration
- Password reset
- Session management
- Token handling

### GymProvider

Manages gym data and search functionality:

```dart
// Load gyms
final gymProvider = Provider.of<GymProvider>(context, listen: false);
await gymProvider.loadGyms();

// Search and filter
gymProvider.search('강남');
gymProvider.toggleFacility('PT');
gymProvider.setSortBy('distance');

// Favorites
gymProvider.toggleFavorite(gymId);
final isFavorite = gymProvider.isFavorite(gymId);

// Access filtered results
final gyms = context.watch<GymProvider>().filteredGyms;
```

**Features:**
- Gym listing with pagination
- Real-time search
- Multi-filter support (facilities, location)
- Sorting (distance, name, newest)
- Favorite management
- Location-based queries

### MembershipProvider

Manages membership state and operations:

```dart
// Load memberships
final membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
await membershipProvider.loadMemberships(userId);

// Purchase membership
await membershipProvider.purchaseMembership(
  userId: userId,
  gymId: gymId,
  plan: '6개월 이용권',
  price: 480000,
  paymentMethod: 'card',
);

// Membership operations
await membershipProvider.pauseMembership(7); // pause for 7 days
await membershipProvider.resumeMembership();
await membershipProvider.extendMembership(plan: '3개월 이용권', ...);

// Check-in
await membershipProvider.recordVisit();

// Access membership data
final activeMembership = context.watch<MembershipProvider>().activeMembership;
final stats = context.watch<MembershipProvider>().stats;
final remainingDays = membershipProvider.getRemainingDays();
```

**Features:**
- Active membership tracking
- Membership history
- Purchase and renewal
- Pause/resume operations
- Check-in recording
- Usage statistics
- Expiration alerts

## Usage Patterns

### 1. Reading State (with rebuild)

Use `context.watch<T>()` when you want the widget to rebuild when state changes:

```dart
Widget build(BuildContext context) {
  final isLoading = context.watch<AuthProvider>().isLoading;
  final gyms = context.watch<GymProvider>().filteredGyms;

  return isLoading ? CircularProgressIndicator() : GymList(gyms);
}
```

### 2. Reading State (without rebuild)

Use `context.read<T>()` for one-time reads without subscribing to changes:

```dart
void _handleLogout() {
  context.read<AuthProvider>().logout();
}
```

### 3. Calling Methods

Use `Provider.of<T>(context, listen: false)` for calling methods:

```dart
Future<void> _loadData() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final gymProvider = Provider.of<GymProvider>(context, listen: false);

  await Future.wait([
    gymProvider.loadGyms(),
    authProvider.loadSavedAuth(),
  ]);
}
```

### 4. Listening to Multiple Providers

Use `Consumer` or `Selector` for fine-grained control:

```dart
// Consumer
Consumer<AuthProvider>(
  builder: (context, auth, child) {
    return Text('Hello, ${auth.currentUser?.name}');
  },
)

// Consumer2 for multiple providers
Consumer2<AuthProvider, MembershipProvider>(
  builder: (context, auth, membership, child) {
    return MembershipCard(
      user: auth.currentUser,
      membership: membership.activeMembership,
    );
  },
)

// Selector for performance optimization
Selector<GymProvider, int>(
  selector: (_, provider) => provider.filteredGyms.length,
  builder: (_, count, __) => Text('$count gyms found'),
)
```

### 5. Error Handling

All providers have error handling built-in:

```dart
final authProvider = context.watch<AuthProvider>();

if (authProvider.error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authProvider.error!)),
  );
  authProvider.clearError();
}
```

## Best Practices

### DO:
- ✅ Use `context.watch<T>()` inside build methods
- ✅ Use `context.read<T>()` for event handlers
- ✅ Use `Provider.of<T>(context, listen: false)` in async functions
- ✅ Call `clearError()` after showing error messages
- ✅ Check `isLoading` before showing loading indicators
- ✅ Use `Selector` for performance-critical widgets
- ✅ Reset providers on logout

### DON'T:
- ❌ Use `context.watch<T>()` in event handlers (causes unnecessary rebuilds)
- ❌ Use `context.read<T>()` in build methods (won't rebuild on changes)
- ❌ Call async methods directly from build methods
- ❌ Forget to handle loading and error states
- ❌ Ignore null checks on optional data

## Example: Login Screen with Provider

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _loginIdController.text,
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error!)),
        );
        authProvider.clearError();
      });
    }

    return Scaffold(
      body: Column(
        children: [
          TextField(controller: _loginIdController),
          TextField(controller: _passwordController, obscureText: true),
          CheckboxListTile(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
            title: const Text('로그인 상태 유지'),
          ),
          GymButton(
            text: '로그인',
            loading: authProvider.isLoading,
            onPressed: authProvider.isLoading ? null : _handleLogin,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

## Integration with Existing Code

The providers are designed to work alongside your existing model classes:

- **User** model works with AuthProvider
- **Gym** model works with GymProvider
- **Membership** model works with MembershipProvider

All extended data is stored in the `extra` Map field to maintain compatibility with your existing backend structure.

## Testing

Providers can be easily tested using `ChangeNotifierProvider.value`:

```dart
testWidgets('login test', (tester) async {
  final authProvider = AuthProvider();

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: MaterialApp(home: LoginScreen()),
    ),
  );

  // Test interactions...
});
```

## Performance Optimization

1. **Use Selector for computed values:**
   ```dart
   Selector<GymProvider, bool>(
     selector: (_, provider) => provider.hasActiveFilters,
     builder: (_, hasFilters, __) => FilterBadge(show: hasFilters),
   )
   ```

2. **Use const widgets when possible:**
   ```dart
   const Text('Static content')
   ```

3. **Split large widgets:**
   Create separate widgets that listen to specific parts of state

4. **Avoid rebuilding entire screens:**
   Use Consumer widgets for specific sections that need updates
