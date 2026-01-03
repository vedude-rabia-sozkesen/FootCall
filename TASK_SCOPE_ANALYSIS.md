# Task Scope Analysis: Provider Architecture (Auth State + Global State)

## 📌 Task Description Scope

**Provider mimarisi (Auth state + global state tasarımı)**
- ChangeNotifier providers for auth state + data state management
- App reacts automatically to login/logout and data changes
- Admin state management

---

## ✅ ITEMS WITHIN THIS TASK'S SCOPE

### 1. **AuthProvider** ✅ IN SCOPE
- **Status**: ❌ NOT IMPLEMENTED
- **Task Requirement**: 
  - Current user management
  - Auth status tracking
  - Login/logout calls (uses AuthService)
- **Location**: `lib/providers/auth_provider.dart`
- **Key Features Needed**:
  - `User? _user` - Current user state
  - `bool _isLoading` - Loading state
  - `String? _error` - Error state
  - Methods: `login()`, `signUp()`, `signOut()`
  - Stream subscription to `authStateChanges()`
  - `notifyListeners()` strategy (loading→success→error)

### 2. **MatchesProvider** ✅ IN SCOPE
- **Status**: ❌ NOT IMPLEMENTED
- **Task Requirement**: 
  - List state management
  - Loading/error state
- **Location**: `lib/providers/matches_provider.dart`
- **Key Features Needed**:
  - `List<MatchModel> _matches` - Matches list state
  - `bool _isLoading` - Loading state
  - `String? _error` - Error state
  - Stream subscription to matches collection
  - Methods: `loadMatches()`, `createMatch()`, `updateMatch()`, `deleteMatch()`
  - `notifyListeners()` on state changes

### 3. **TeamsProvider** ✅ IN SCOPE
- **Status**: ❌ NOT IMPLEMENTED
- **Task Requirement**: 
  - List state management
  - Loading/error state
- **Location**: `lib/providers/teams_provider.dart`
- **Key Features Needed**:
  - `List<TeamModel> _teams` - Teams list state
  - `bool _isLoading` - Loading state
  - `String? _error` - Error state
  - Stream subscription to teams collection
  - Methods: `loadTeams()`, `createTeam()`, `updateTeam()`, `deleteTeam()`
  - `notifyListeners()` on state changes

### 4. **MultiProvider Wiring** ✅ IN SCOPE
- **Status**: ❌ NOT IMPLEMENTED
- **Task Requirement**: 
  - Provider dependencies (AuthService/FirestoreService) injection
  - Coordinate with Person 1
- **Location**: `lib/core/di/providers.dart`
- **Key Features Needed**:
  - Register `AuthProvider` with `AuthService` dependency
  - Register `MatchesProvider` with `MatchService` dependency
  - Register `TeamsProvider` with `TeamService` dependency
  - Ensure proper dependency order
  - Use `ChangeNotifierProvider` or `ChangeNotifierProxyProvider`

### 5. **State Rules Implementation** ✅ IN SCOPE
- **Status**: ❌ NOT IMPLEMENTED
- **Task Requirement**: 
  - Stop passing shared state deeply through constructors
  - `notifyListeners()` strategy (loading→success→error)
- **Key Features Needed**:
  - Pages should use `context.watch<Provider>()` or `Consumer<Provider>`
  - Avoid passing state through widget constructors
  - Implement loading→success→error flow in all providers
  - Automatic UI updates when state changes

### 6. **Update Pages to Use Providers** ✅ IN SCOPE (Partial)
- **Status**: ❌ NOT IMPLEMENTED
- **Task Requirement**: 
  - Pages should use providers instead of direct service calls
  - Avoid passing state through constructors
- **Files to Update**:
  - `lib/pages/matches_screen.dart` - Use `MatchesProvider` instead of `MatchService`
  - `lib/pages/teams_screen.dart` - Use `TeamsProvider` instead of `TeamService`
  - `lib/main.dart` - Update `AuthGate` to use `AuthProvider`
  - `lib/pages/home_page.dart` - Use `AuthProvider` for current user
  - `lib/pages/login_page.dart` - Use `AuthProvider.login()`
  - `lib/pages/sign_up_page.dart` - Use `AuthProvider.signUp()`

---

## ❌ ITEMS OUT OF SCOPE (Not in this task)

### 1. **PlayersProvider** ❌ OUT OF SCOPE
- **Reason**: Task description only mentions `MatchesProvider` and `TeamsProvider`
- **Note**: May be needed later, but not part of this specific task

### 2. **Firestore Security Rules** ❌ OUT OF SCOPE
- **Reason**: Task is about Provider architecture, not security rules
- **Status**: Still needs to be done, but in a different task

### 3. **Sign Up Error Handling** ❌ OUT OF SCOPE
- **Reason**: Task focuses on Provider state management, not UI error messages
- **Status**: Still needs to be done, but in a different task

### 4. **Delete Operations** ❌ OUT OF SCOPE
- **Reason**: Task is about state management, not CRUD completeness
- **Status**: Still needs to be done, but in a different task

### 5. **Repository Migration** ❌ OUT OF SCOPE
- **Reason**: Task is about Provider setup, not repository refactoring
- **Status**: Still needs to be done, but in a different task

### 6. **MatchModel Structure Updates** ❌ OUT OF SCOPE
- **Reason**: Task is about Provider architecture, not model structure
- **Status**: Still needs to be done, but in a different task

---

## 📋 TASK CHECKLIST

### Required Deliverables:
- [ ] `lib/providers/auth_provider.dart` - Created and implemented
- [ ] `lib/providers/matches_provider.dart` - Created and implemented
- [ ] `lib/providers/teams_provider.dart` - Created and implemented
- [ ] `lib/core/di/providers.dart` - Updated with new providers
- [ ] `lib/main.dart` - Updated to use `AuthProvider` in `AuthGate`
- [ ] `lib/pages/login_page.dart` - Updated to use `AuthProvider`
- [ ] `lib/pages/sign_up_page.dart` - Updated to use `AuthProvider`
- [ ] `lib/pages/matches_screen.dart` - Updated to use `MatchesProvider`
- [ ] `lib/pages/teams_screen.dart` - Updated to use `TeamsProvider`
- [ ] `lib/pages/home_page.dart` - Updated to use `AuthProvider`

### Done Criteria:
- [ ] Provider correctly set up
- [ ] Auth state managed from provider and affects entire app
- [ ] No passing shared state through constructors
- [ ] `notifyListeners()` strategy implemented (loading→success→error)
- [ ] Automatic UI updates when auth state changes
- [ ] Automatic UI updates when data state changes

---

## 🎯 SUMMARY

**Items IN SCOPE (6 items):**
1. ✅ AuthProvider creation
2. ✅ MatchesProvider creation
3. ✅ TeamsProvider creation
4. ✅ MultiProvider wiring
5. ✅ State rules implementation (no deep passing, notifyListeners strategy)
6. ✅ Update pages to use providers

**Items OUT OF SCOPE (6 items):**
1. ❌ PlayersProvider (not mentioned in task)
2. ❌ Firestore security rules
3. ❌ Sign up error handling
4. ❌ Delete operations
5. ❌ Repository migration
6. ❌ MatchModel structure updates

**Focus**: This task is specifically about implementing the Provider architecture layer for state management, not about completing all Firebase integration features.




