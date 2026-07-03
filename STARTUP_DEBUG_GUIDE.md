# 📋 Startup Flow Debugging Guide

## 🎯 Overview
This document explains the comprehensive debug logging added to the BarberBook app startup flow to help diagnose navigation and authentication issues.

---

## 📊 Expected Debug Output

### **Scenario 1: User NOT Logged In**
```
[Startup] === APP STARTING ===
[Startup] Orientation locked to portrait
[Startup] ✅ Firebase Initialized
[Startup] Initializing SharedPreferences...
[Startup] ✅ SharedPreferences Initialized
[Startup] === CALLING runApp() ===
[SplashScreen] 🚀 SplashScreen initialized
[SplashScreen] ⏳ Waiting for splash animation (2s)...
[AuthService] Creating authStateChanges stream
[AuthService] 📡 Firebase auth state: no user
[AuthProvider] Setting up authStateChanges stream listener
[AuthProvider] 🚫 No Firebase user (not logged in)
[SplashScreen] ✅ Splash animation complete
[SplashScreen] 🌐 Checking internet connectivity...
[SplashScreen] ✅ Internet Connected
[SplashScreen] 👂 Listening to auth state changes...
[SplashScreen] 📡 Auth state changed: AsyncData<UserModel?>
[SplashScreen] 📦 Auth data received
[SplashScreen] 🚫 User not logged in
[SplashScreen] 🔄 Redirect to Login Screen
[SplashScreen] 🚀 Navigating to: /login
[RouteGuards] User is null (not authenticated)
[RouteGuards] ✅ Allowing access to public route: /login
```

### **Scenario 2: User Logged In as CUSTOMER**
```
[Startup] === APP STARTING ===
[Startup] ✅ Firebase Initialized
[Startup] ✅ SharedPreferences Initialized
[Startup] === CALLING runApp() ===
[SplashScreen] 🚀 SplashScreen initialized
[AuthService] Creating authStateChanges stream
[AuthService] 📡 Firebase auth state: user=abc123, email=customer@example.com
[AuthProvider] Setting up authStateChanges stream listener
[AuthProvider] ✅ Firebase user found: abc123
[AuthProvider] Fetching user profile from Firestore...
[AuthService] 🔍 Fetching user profile from Firestore: abc123
[AuthService] ✅ User profile fetched successfully
[AuthProvider] ✅ User Profile Loaded:
[AuthProvider]   - Name: John Doe
[AuthProvider]   - Email: customer@example.com
[AuthProvider]   - Role: customer
[SplashScreen] ✅ Splash animation complete
[SplashScreen] 🌐 Checking internet connectivity...
[SplashScreen] ✅ Internet Connected
[SplashScreen] 👂 Listening to auth state changes...
[SplashScreen] 📡 Auth state changed: AsyncData<UserModel?>
[SplashScreen] 📦 Auth data received
[SplashScreen] 👤 User is CUSTOMER
[SplashScreen] 🔄 Redirect to Customer Dashboard
[SplashScreen] 🚀 Navigating to: /customer/home
[RouteGuards] ✅ User authenticated (role: customer)
[RouteGuards] ✅ Access allowed to: /customer/home
```

### **Scenario 3: User Logged In as ADMIN**
```
[Startup] === APP STARTING ===
[Startup] ✅ Firebase Initialized
[Startup] === CALLING runApp() ===
[SplashScreen] 🚀 SplashScreen initialized
[AuthService] Creating authStateChanges stream
[AuthService] 📡 Firebase auth state: user=xyz789, email=admin@barberbook.com
[AuthProvider] ✅ Firebase user found: xyz789
[AuthProvider] Fetching user profile from Firestore...
[AuthService] 🔍 Fetching user profile from Firestore: xyz789
[AuthService] ✅ User profile fetched successfully
[AuthProvider] ✅ User Profile Loaded:
[AuthProvider]   - Name: Admin User
[AuthProvider]   - Email: admin@barberbook.com
[AuthProvider]   - Role: admin
[SplashScreen] ✅ Splash animation complete
[SplashScreen] 🌐 Checking internet connectivity...
[SplashScreen] ✅ Internet Connected
[SplashScreen] 👂 Listening to auth state changes...
[SplashScreen] 📡 Auth state changed: AsyncData<UserModel?>
[SplashScreen] 📦 Auth data received
[SplashScreen] 👑 User is ADMIN
[SplashScreen] 🔄 Redirect to Admin Dashboard
[SplashScreen] 🚀 Navigating to: /admin/home
[RouteGuards] ✅ User authenticated (role: admin)
[RouteGuards] ✅ Access allowed to: /admin/home
```

---

## 🔍 Files Modified

### 1. **lib/main.dart**
**Changes:**
- Added `debugPrint()` at each startup phase
- Logs Firebase initialization
- Logs SharedPreferences initialization
- Marks when `runApp()` is called

**Purpose:** Track app initialization before UI renders

---

### 2. **lib/features/auth/services/auth_service.dart**
**Changes:**
- Added logging to `authStateChanges` stream
- Added logging to `getUserProfile()` method
- Tracks Firebase Auth state emissions
- Tracks Firestore document fetch operations

**Purpose:** Monitor Firebase Authentication and Firestore operations

---

### 3. **lib/features/auth/providers/auth_provider.dart**
**Changes:**
- Added comprehensive logging in `authStateProvider`
- Logs Firebase user detection
- Logs user profile fetching
- Logs user details (name, email, role)

**Purpose:** Track Riverpod provider state transitions

---

### 4. **lib/features/auth/screens/splash_screen.dart**
**Changes:**
- Added logging throughout `_checkAndNavigate()`
- Added logging in `_listenToAuthState()`
- Added logging in `_navigateTo()`
- Logs internet connectivity checks
- Logs auth state changes
- Logs navigation decisions
- Logs navigation execution

**Purpose:** Track splash screen logic and navigation flow

---

### 5. **lib/core/router/app_router.dart**
**Changes:**
- Added logging in GoRouter `redirect` callback
- Logs auth state loading status
- Logs authenticated user role
- Logs redirect decisions (from → to)

**Purpose:** Monitor GoRouter redirect logic and RBAC guards

---

### 6. **lib/core/router/route_guards.dart**
**Changes:**
- Added logging in `getRedirect()` method
- Logs authentication status checks
- Logs route access decisions
- Logs RBAC violations and redirects

**Purpose:** Track route guard logic and permission checks

---

## 🚨 Common Issues & Solutions

### **Issue 1: App stuck on Splash Screen**
**Check logs for:**
- `[AuthProvider] ⏳ AuthState is loading...` repeating
- `[SplashScreen] 📡 Auth state changed:` never appearing

**Solution:**
- Verify Firebase is properly initialized
- Check internet connection
- Ensure Firebase Auth stream is emitting values

---

### **Issue 2: Infinite redirect loop**
**Check logs for:**
- `[GoRouter] 🔄 Redirect:` repeating with same paths
- `[RouteGuards] 🔄 Redirecting unauthenticated user to /login`

**Solution:**
- Already fixed in this implementation
- Splash screen now handles navigation, not GoRouter redirect
- Public routes (splash, login, register) are allowed for unauthenticated users

---

### **Issue 3: User logged in but redirected to Login**
**Check logs for:**
- `[AuthService] 📡 Firebase auth state: no user` (should show user data)
- `[AuthProvider] ⚠️ User profile not found in Firestore`

**Solution:**
- Verify user exists in Firestore `users` collection
- Check if `role` field is set correctly ('customer' or 'admin')
- Ensure Firebase Auth and Firestore are in sync

---

### **Issue 4: Wrong dashboard shown (Admin vs Customer)**
**Check logs for:**
- `[AuthProvider] - Role:` showing incorrect role
- `[RouteGuards] 🔄 Admin/Customer accessing wrong route`

**Solution:**
- Verify user's `role` field in Firestore document
- Should be exactly 'admin' or 'customer' (case-sensitive)
- Check UserModel parsing logic

---

## 🧪 Testing Checklist

Run the app and verify these scenarios:

### ✅ **Scenario 1: First-time User (No Account)**
- [ ] Splash shows for 2 seconds
- [ ] Logs show "User not logged in"
- [ ] Redirects to `/login`
- [ ] No infinite loading

### ✅ **Scenario 2: Registered Customer**
- [ ] Splash shows for 2 seconds
- [ ] Logs show "User is CUSTOMER"
- [ ] Redirects to `/customer/home`
- [ ] Customer dashboard appears

### ✅ **Scenario 3: Registered Admin**
- [ ] Splash shows for 2 seconds
- [ ] Logs show "User is ADMIN"
- [ ] Redirects to `/admin/home`
- [ ] Admin dashboard appears

### ✅ **Scenario 4: Logout from Dashboard**
- [ ] Click logout button
- [ ] Logs show Firebase auth state change to null
- [ ] Redirects to `/login`
- [ ] Cannot access dashboard without login

### ✅ **Scenario 5: No Internet Connection**
- [ ] Disable internet
- [ ] Splash shows "No Internet Connection" dialog
- [ ] Click "Retry" to try again
- [ ] Re-enable internet and retry should succeed

---

## 📝 How to View Debug Logs

### **In Terminal:**
```bash
flutter run
```
Logs will appear in the terminal where you ran the command.

### **In VS Code:**
1. Open Debug Console (View → Debug Console)
2. Run the app with F5
3. Filter logs by typing `[Startup]` or `[SplashScreen]`

### **In Android Studio:**
1. Open Logcat tab
2. Filter by `flutter`
3. Search for debug print tags

---

## 🎯 Key Improvements

1. ✅ **Comprehensive Logging**: Every startup phase is logged
2. ✅ **No Infinite Loading**: Proper async/await and stream listening
3. ✅ **Clear Navigation Flow**: Splash → Auth Check → Dashboard/Login
4. ✅ **Firebase Integration**: Firebase fully initialized before runApp
5. ✅ **RBAC Route Guards**: Role-based access control with logging
6. ✅ **Error Handling**: All errors logged with context
7. ✅ **Internet Check**: Connectivity verified before navigation
8. ✅ **Mounted Checks**: Prevents navigation on unmounted widgets

---

## 🔧 Maintenance Tips

- **Remove logs in production**: Use `kDebugMode` to conditionally print
- **Monitor Firestore**: Ensure user documents exist for all Firebase Auth users
- **Check role values**: Only 'admin' and 'customer' are valid roles
- **Test edge cases**: Network loss, Firebase errors, missing profiles

---

## 📚 Related Documentation

- Clean Architecture: See project README
- GoRouter RBAC: See `lib/core/router/route_guards.dart`
- Auth Provider: See `lib/features/auth/providers/auth_provider.dart`
- Firebase Setup: See Firebase console and `google-services.json`

---

**Last Updated:** 2026-06-27
**Author:** AI Assistant
**Status:** ✅ Complete
