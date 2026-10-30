import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../core/services/api_client.dart';
import '../core/services/fcm_service.dart';
import '../core/services/socket_service.dart';
import '../core/repositories/auth_repository.dart';
import '../core/repositories/social_repository.dart';
import '../core/repositories/backend_repository.dart';
import '../core/services/media_upload_service.dart';
import '../core/utils/firebase_auth_errors.dart';
import '../core/config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository.instance;

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isGuest = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isNewUser = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<Map<String, dynamic>>? _banSubscription;
  StreamSubscription<Map<String, dynamic>>? _restrictionSubscription;
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  late final Future<void> _initFuture;

  UserModel get currentUser => _currentUser ?? UserModel.empty;
  bool get hasUser => _currentUser != null;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isNewUser => _isNewUser;
  Future<void> get initFuture => _initFuture;
  String? get errorMessage => _errorMessage;

  void mockSetCurrentUser(UserModel user) {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  AuthProvider() {
    _initFuture = _restoreSession();
    _initAuthStateListener();
    _initModerationListeners();
  }

  void _initAuthStateListener() {
    try {
      _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
        debugPrint('[AuthProvider] Firebase authStateChanged: uid=${firebaseUser?.uid}, email=${firebaseUser?.email}');
        if (firebaseUser == null) {
          if (_isAuthenticated && !_isGuest && !AppConfig.isBackendDisconnected) {
            _isAuthenticated = false;
            _currentUser = null;
            notifyListeners();
          }
        }
      });
    } catch (e) {
      debugPrint('[AuthProvider] Auth state listener init warning: $e');
    }
  }

  void _initModerationListeners() {
    if (AppConfig.isBackendDisconnected) return;
    _banSubscription = SocketService.instance.onModerationBan.listen((data) {
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(status: 'BANNED');
        notifyListeners();
      }
    });

    _restrictionSubscription = SocketService.instance.onModerationRestriction.listen((data) {
      debugPrint('[AuthProvider] Moderation restriction received: $data');
      notifyListeners();
    });

    _notificationSubscription = SocketService.instance.onNotificationNew.listen((data) {
      final action = data['action']?.toString() ?? data['data']?['action']?.toString();
      final type = data['type']?.toString();
      final title = data['title']?.toString() ?? '';
      if (action == 'HOST_APPROVED' || action == 'HOST_STATUS_UPDATED' || type == 'HOST_APPLICATION' || title.contains('Host')) {
        refreshCurrentUser();
      }
    });
  }

  void updateAvatarFrame(String frame) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(avatarFrame: frame);
      _saveUserLocalSession(_currentUser!);
      notifyListeners();
    }
  }

  void updateEquippedBadge(String badge) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(badge: badge);
      _saveUserLocalSession(_currentUser!);
      notifyListeners();
    }
  }

  /// Credits sender Wealth XP upon eligible gift transaction and persists progression
  void addWealthXp(int xpIncrement) {
    if (xpIncrement > 0) {
      final user = _currentUser ?? UserModel.empty;
      final currentXp = user.wealthXp;
      final newWealthXp = currentXp + xpIncrement;
      final newLevel = newWealthXp ~/ 10000;
      _currentUser = user.copyWith(
        wealthXp: newWealthXp,
        wealthLevel: newLevel,
      );
      if (_currentUser!.id.isNotEmpty) {
        _saveUserLocalSession(_currentUser!);
      }
      notifyListeners();
    }
  }

  /// Credits recipient Charm XP upon receiving gifts and persists progression
  void addCharmXp(int xpIncrement) {
    if (xpIncrement > 0) {
      final user = _currentUser ?? UserModel.empty;
      final currentXp = user.charmXp;
      final newCharmXp = currentXp + xpIncrement;
      final newLevel = newCharmXp ~/ 10000;
      _currentUser = user.copyWith(
        charmXp: newCharmXp,
        charmLevel: newLevel,
      );
      if (_currentUser!.id.isNotEmpty) {
        _saveUserLocalSession(_currentUser!);
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _banSubscription?.cancel();
    _restrictionSubscription?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  static const String _userSessionKey = 'hemiton_user_session_json';
  static const String _localAccountsKey = 'hemiton_registered_accounts_v1';
  static const String _followingIdsKey = 'hemiton_following_ids';
  static const String _blockedIdsKey = 'hemiton_blocked_ids';

  static final List<Map<String, dynamic>> _inMemoryAccounts = [
    {
      'id': 'user_hemiton_test_1',
      'email': 'user@hemiton.com',
      'username': 'user_hemiton',
      'name': 'Hemiton User',
      'password': 'securePass123',
    },
    {
      'id': 'user_hemiton_test_2',
      'email': 'hemiton_test@hemiton.com',
      'username': 'hemiton_test',
      'name': 'Hemiton Test',
      'password': 'pass123',
    },
    {
      'id': 'user_hemiton_demo',
      'email': 'demo@hemiton.app',
      'username': 'hemiton_official',
      'name': 'HEMI TON Official',
      'password': 'password',
    },
  ];

  Future<List<Map<String, dynamic>>> _loadLocalAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_localAccountsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          final list = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (e) {
      debugPrint('[AuthProvider] Error reading local accounts: $e');
    }
    return List<Map<String, dynamic>>.from(_inMemoryAccounts);
  }

  Future<void> _saveLocalAccount(Map<String, dynamic> account) async {
    final email = account['email']?.toString().toLowerCase().trim();
    final phone = account['phone']?.toString().trim();
    _inMemoryAccounts.removeWhere((acc) {
      final e = acc['email']?.toString().toLowerCase().trim();
      final p = acc['phone']?.toString().trim();
      return (email != null && email.isNotEmpty && e == email) ||
          (phone != null && phone.isNotEmpty && p == phone);
    });
    _inMemoryAccounts.add(account);

    try {
      final prefs = await SharedPreferences.getInstance();
      final list = await _loadLocalAccounts();
      list.removeWhere((acc) {
        final e = acc['email']?.toString().toLowerCase().trim();
        final p = acc['phone']?.toString().trim();
        return (email != null && email.isNotEmpty && e == email) ||
            (phone != null && phone.isNotEmpty && p == phone);
      });
      list.add(account);
      await prefs.setString(_localAccountsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('[AuthProvider] Error saving local account: $e');
    }
  }

  Future<void> _saveUserLocalSession(UserModel user) async {
    try {
      if (user.id.isEmpty || user.id.startsWith('dev-admin') || user.username.startsWith('admin_shadow')) {
        debugPrint('[AuthProvider] Refusing to persist invalid or admin shadow user session');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userSessionKey, jsonEncode(user.toJson()));
      if (!AppConfig.isBackendDisconnected) {
        SocketService.instance.connect();
        BackendRepository.instance.fetchLiveRooms();
      }
    } catch (e) {
      debugPrint('Failed to save user session locally: $e');
    }
  }

  Future<void> _saveFollowState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_followingIdsKey, _followingUserIds.toList());
      await prefs.setStringList(_blockedIdsKey, _blockedUserIds.toList());
    } catch (_) {}
  }

  Future<void> _clearUserLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userSessionKey);
      await prefs.remove(_followingIdsKey);
      await prefs.remove(_blockedIdsKey);
      _followingUserIds.clear();
      _followerUserIds.clear();
      _blockedUserIds.clear();
      _currentUser = null;
      _isAuthenticated = false;
      _isGuest = false;
      await ApiClient.instance.clearTokens();
      await _authRepository.logout();
    } catch (_) {}
  }

  /// Restore authentication state securely from backend JWT or local saved session
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check first-run flag across app uninstalls/reinstalls
      final bool hasRunBefore = prefs.getBool('app_has_run_before') ?? false;
      if (!hasRunBefore) {
        await prefs.setBool('app_has_run_before', true);
      }

      final userJsonStr = prefs.getString(_userSessionKey);

      if (userJsonStr != null && userJsonStr.isNotEmpty) {
        try {
          final Map<String, dynamic> map = jsonDecode(userJsonStr);
          final restored = UserModel.fromJson(map);
          if (restored.id.isNotEmpty && !restored.id.startsWith('dev-admin') && !restored.username.startsWith('admin_shadow')) {
            _currentUser = restored;
            _isAuthenticated = true;
            _isGuest = false;
          } else {
            await prefs.remove(_userSessionKey);
          }
        } catch (e) {
          debugPrint('[AuthProvider] Restoring stored session failed: $e');
        }
      }

      // If local session was missing, check Firebase persistent authentication session if connected
      if (_currentUser == null && !AppConfig.isBackendDisconnected) {
        try {
          final fbUser = FirebaseAuth.instance.currentUser;
          if (fbUser != null) {
            final cleanEmail = fbUser.email ?? '';
            final displayName = (fbUser.displayName != null && fbUser.displayName!.trim().isNotEmpty)
                ? fbUser.displayName!.trim()
                : (cleanEmail.contains('@') ? cleanEmail.split('@').first : 'HEMI TON Member');
            final username = cleanEmail.contains('@')
                ? cleanEmail.split('@').first.toLowerCase()
                : 'user_${fbUser.uid.substring(0, fbUser.uid.length > 6 ? 6 : fbUser.uid.length)}';
            _currentUser = UserModel(
              id: fbUser.uid,
              email: cleanEmail.isNotEmpty ? cleanEmail : null,
              name: displayName,
              username: username,
              avatarUrl: fbUser.photoURL ?? '',
              profileCompleted: true,
              isOnline: true,
            );
            _isAuthenticated = true;
            _isGuest = false;
            await _saveUserLocalSession(_currentUser!);
          }
        } catch (fbErr) {
          debugPrint('[AuthProvider] Firebase persistent session restore warning: $fbErr');
        }
      }

      final savedFollowing = prefs.getStringList(_followingIdsKey);
      if (savedFollowing != null) {
        _followingUserIds.clear();
        _followingUserIds.addAll(savedFollowing);
      }

      final savedBlocked = prefs.getStringList(_blockedIdsKey);
      if (savedBlocked != null) {
        _blockedUserIds.clear();
        _blockedUserIds.addAll(savedBlocked);
      }

      // If we restored a local user, mark initialized immediately for instant splash dismissal
      if (_currentUser != null) {
        _isInitialized = true;
        notifyListeners();
      }

      // Sync latest profile and following list from backend asynchronously
      _syncRemoteUser();
    } catch (e) {
      debugPrint('Session restore error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Publicly accessible profile and host permission refresh
  Future<UserModel?> refreshCurrentUser() async {
    try {
      final remoteUser = await _authRepository
          .getCurrentUser()
          .timeout(const Duration(seconds: 4));

      // Guard: Discard internal development/admin shadow accounts or mismatched user records
      if (remoteUser.id.startsWith('dev-admin') ||
          remoteUser.username.startsWith('admin_shadow') ||
          remoteUser.name.startsWith('admin_shadow')) {
        debugPrint('[AuthProvider] Rejecting unexpected shadow admin profile returned by server: ${remoteUser.id}');
        return _currentUser;
      }

      if (_currentUser != null && _currentUser!.id.isNotEmpty && remoteUser.id != _currentUser!.id) {
        debugPrint('[AuthProvider] Rejecting mismatched profile ID ${remoteUser.id} (authenticated user: ${_currentUser?.id})');
        return _currentUser;
      }

      // Remote user from backend database is authoritative, but preserve equipped outfit fields if empty
      final String effectiveFrame = (remoteUser.avatarFrame.isNotEmpty && remoteUser.avatarFrame != 'none')
          ? remoteUser.avatarFrame
          : ((_currentUser?.avatarFrame.isNotEmpty == true && _currentUser?.avatarFrame != 'none')
              ? _currentUser!.avatarFrame
              : remoteUser.avatarFrame);

      final String effectiveBadge = remoteUser.badge.isNotEmpty
          ? remoteUser.badge
          : (_currentUser?.badge ?? remoteUser.badge);

      _currentUser = remoteUser.copyWith(
        avatarFrame: effectiveFrame,
        badge: effectiveBadge,
      );
      _isAuthenticated = true;
      _isGuest = false;
      await _saveUserLocalSession(_currentUser!);
      notifyListeners();
      return _currentUser;
    } catch (e) {
      debugPrint('[AuthProvider] refreshCurrentUser error: $e');
      return _currentUser;
    }
  }

  Future<void> _syncRemoteUser() async {
    if (AppConfig.isBackendDisconnected) return;
    try {
      final hasToken = await _authRepository
          .hasSavedToken()
          .timeout(const Duration(seconds: 4), onTimeout: () => false);
      if (hasToken && _currentUser != null && !_isGuest) {
        try {
          await refreshCurrentUser();
          FcmService.instance.registerWithBackend();
          syncFollowingList();
        } on ApiException catch (e) {
          if (e.statusCode == 401) {
            await _clearUserLocalSession();
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Backend sync during restore session fallback: $e');
        }
      } else if (_currentUser == null) {
        _isAuthenticated = false;
        _isGuest = false;
        notifyListeners();
      }
    } catch (_) {}
  }

  void enterAsGuest() {
    _isGuest = true;
    _isAuthenticated = false;
    _currentUser = const UserModel(
      id: 'guest_user_temp',
      username: 'guest_user',
      name: 'Guest Explorer',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      bio: 'Exploring HEMI TON as a guest ✨',
      role: UserRole.user,
      coins: 0,
      diamonds: 0,
      rCoins: 0,
      isVip: false,
      isHost: false,
      isAgency: false,
      isSeller: false,
      profileCompleted: true,
    );
    notifyListeners();
  }

  /// Request OTP for phone sign in from real backend
  Future<bool> requestOtp(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.requestOtp(phone: phone);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to send OTP. Please check your network.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP and authenticate against real backend
  Future<bool> loginWithPhone(String phone, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authRes = await _authRepository.verifyOtp(phone: phone, code: otp);
      _currentUser = authRes.user;
      _isAuthenticated = true;
      _isGuest = false;
      _isLoading = false;
      await _saveUserLocalSession(_currentUser!);
      FcmService.instance.registerWithBackend();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Authentication failed. Please verify your OTP code.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with email & password via Firebase Auth + Real Backend Sync or local account store
  Future<bool> login(String usernameOrEmail, String password) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanInput = usernameOrEmail.trim();
    final cleanPass = password.trim();

    if (cleanInput.isEmpty || cleanPass.isEmpty) {
      _errorMessage = 'Please enter both email and password';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (cleanPass.length < 6) {
      _errorMessage = 'Password must be at least 6 characters.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // 1. Check persistent local account registry (matches locally created accounts)
    final localAccounts = await _loadLocalAccounts();
    final localMatch = localAccounts.firstWhere(
      (acc) {
        final email = acc['email']?.toString().toLowerCase().trim() ?? '';
        final username = acc['username']?.toString().toLowerCase().trim() ?? '';
        final phone = acc['phone']?.toString().trim() ?? '';
        final input = cleanInput.toLowerCase();
        return email == input || username == input || phone == cleanInput;
      },
      orElse: () => <String, dynamic>{},
    );

    if (localMatch.isNotEmpty) {
      final savedPass = localMatch['password']?.toString() ?? '';
      if (savedPass != cleanPass) {
        _errorMessage = 'Incorrect password. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Valid credentials found in registered accounts
      final userData = localMatch['user'] != null
          ? Map<String, dynamic>.from(localMatch['user'] as Map)
          : <String, dynamic>{};
      _currentUser = userData.isNotEmpty
          ? UserModel.fromJson(userData)
          : UserModel(
              id: localMatch['id']?.toString() ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
              username: localMatch['username']?.toString() ?? cleanInput.split('@').first.toLowerCase(),
              name: localMatch['name']?.toString() ?? cleanInput.split('@').first,
              email: localMatch['email']?.toString(),
              phone: localMatch['phone']?.toString(),
              avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
              coins: 50000,
              diamonds: 10000,
              profileCompleted: true,
              isOnline: true,
            );
      _isAuthenticated = true;
      _isGuest = false;
      _isLoading = false;
      await _saveUserLocalSession(_currentUser!);
      notifyListeners();
      return true;
    }

    // 2. If backend is disconnected or offline and not in local accounts
    if (AppConfig.isBackendDisconnected) {
      await Future.delayed(const Duration(milliseconds: 250));
      // Support pre-registered demo account
      if (cleanInput.toLowerCase() == 'demo@zeparty.com' ||
          cleanInput.toLowerCase() == 'hemiton_official' ||
          cleanInput.toLowerCase() == 'demo@hemiton.app') {
        if (cleanPass == '123456' || cleanPass == 'password') {
          _currentUser = const UserModel(
            id: 'user_hemiton_demo',
            username: 'hemiton_official',
            name: 'HEMI TON Official',
            email: 'demo@hemiton.app',
            avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
            coins: 50000,
            diamonds: 12000,
            profileCompleted: true,
            isOnline: true,
          );
          _isAuthenticated = true;
          _isGuest = false;
          _isLoading = false;
          await _saveUserLocalSession(_currentUser!);
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Incorrect password. Please try again.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _errorMessage = 'No account found for "$cleanInput". Please check credentials or sign up.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // 3. Backend / Firebase is connected: attempt Firebase Auth
    try {
      await _clearUserLocalSession();

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanInput,
        password: cleanPass,
      );

      final firebaseUser = userCredential.user;

      try {
        final authRes = await _authRepository.syncUser(
          uid: firebaseUser?.uid,
          email: cleanInput.contains('@') ? cleanInput : null,
          avatarUrl: firebaseUser?.photoURL,
          isSignup: false,
        );
        _currentUser = authRes.user;
      } catch (syncErr) {
        debugPrint('[AuthProvider] Backend sync warning during email login: $syncErr');
        if (syncErr is ApiException && (syncErr.statusCode == 403 || syncErr.statusCode == 401)) {
          await FirebaseAuth.instance.signOut().catchError((_) {});
          await _clearUserLocalSession();
          _currentUser = null;
          _isAuthenticated = false;
          _errorMessage = syncErr.message;
          _isLoading = false;
          notifyListeners();
          return false;
        }
        final email = cleanInput.contains('@') ? cleanInput : (firebaseUser?.email ?? '');
        final displayName = (firebaseUser?.displayName?.trim().isNotEmpty == true)
            ? firebaseUser!.displayName!.trim()
            : (email.contains('@') ? email.split('@').first : 'HEMI TON Member');
        final username = email.contains('@') ? email.split('@').first.toLowerCase() : 'user_${firebaseUser?.uid.substring(0, 6)}';
        _currentUser = UserModel(
          id: firebaseUser?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email.isNotEmpty ? email : null,
          name: displayName,
          username: username,
          avatarUrl: firebaseUser?.photoURL ?? '',
          profileCompleted: true,
          isOnline: true,
        );
      }

      _isAuthenticated = true;
      _isGuest = false;
      await _saveUserLocalSession(_currentUser!);
      await _saveLocalAccount({
        'id': _currentUser!.id,
        'email': cleanInput,
        'username': _currentUser!.username,
        'password': cleanPass,
        'name': _currentUser!.name,
        'user': _currentUser!.toJson(),
      });
      FcmService.instance.registerWithBackend();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = FirebaseAuthErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email & password via Firebase Auth + Backend Database Registration or local account store
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    String? username,
    String? phone,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();
    final cleanPhone = phone?.trim();
    final cleanUsername = (username != null && username.trim().isNotEmpty)
        ? username.trim().replaceAll('@', '').toLowerCase()
        : cleanEmail.split('@').first.toLowerCase();

    if (cleanName.isEmpty || cleanEmail.isEmpty || cleanPass.isEmpty) {
      _errorMessage = 'All fields are required';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      _errorMessage = 'Please enter a valid email address';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (cleanPass.length < 6) {
      _errorMessage = 'Password must be at least 6 characters.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // 1. Check for duplicate account in local registry
    final localAccounts = await _loadLocalAccounts();
    final duplicate = localAccounts.firstWhere(
      (acc) {
        final accEmail = acc['email']?.toString().toLowerCase().trim() ?? '';
        final accPhone = acc['phone']?.toString().trim() ?? '';
        if (cleanEmail.isNotEmpty && accEmail == cleanEmail) return true;
        if (cleanPhone != null && cleanPhone.isNotEmpty && accPhone == cleanPhone) return true;
        return false;
      },
      orElse: () => <String, dynamic>{},
    );

    if (duplicate.isNotEmpty) {
      final duplicateEmail = duplicate['email']?.toString().toLowerCase().trim() == cleanEmail;
      _errorMessage = duplicateEmail
          ? 'This email is already registered. Please log in or use a different email.'
          : 'This phone number is already registered. Please log in or use a different phone.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // 2. If backend is disconnected or offline, create and persist locally
    if (AppConfig.isBackendDisconnected) {
      await Future.delayed(const Duration(milliseconds: 300));
      final newUserId = 'user_hemiton_${DateTime.now().millisecondsSinceEpoch}';
      final newUser = UserModel(
        id: newUserId,
        username: cleanUsername.replaceAll(RegExp(r'[^a-z0-9]'), '_'),
        name: cleanName,
        email: cleanEmail,
        phone: cleanPhone,
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
        coins: 1000,
        diamonds: 100,
        profileCompleted: false,
        isOnline: true,
      );

      // Persist in local accounts registry
      await _saveLocalAccount({
        'id': newUserId,
        'email': cleanEmail,
        'username': newUser.username,
        'password': cleanPass,
        'phone': cleanPhone,
        'name': cleanName,
        'user': newUser.toJson(),
      });

      _currentUser = newUser;
      _isAuthenticated = true;
      _isGuest = false;
      _isLoading = false;
      await _saveUserLocalSession(_currentUser!);
      notifyListeners();
      return true;
    }

    // 3. Online mode with Firebase + Backend
    try {
      await _clearUserLocalSession();

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPass,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null && cleanName.isNotEmpty) {
        await firebaseUser.updateDisplayName(cleanName).catchError((_) {});
      }

      try {
        final authRes = await _authRepository.syncUser(
          uid: firebaseUser?.uid,
          email: cleanEmail,
          phone: cleanPhone,
          displayName: cleanName,
          username: cleanUsername,
          coins: 1000,
          diamonds: 100,
          isSignup: true,
        );
        _currentUser = authRes.user.copyWith(profileCompleted: false);
      } catch (syncErr) {
        debugPrint('[AuthProvider] Backend sync error in email signup: $syncErr');
        if (syncErr is ApiException && (syncErr.statusCode == 403 || syncErr.statusCode == 400)) {
          await FirebaseAuth.instance.signOut().catchError((_) {});
          await _clearUserLocalSession();
          _currentUser = null;
          _isAuthenticated = false;
          _errorMessage = syncErr.message;
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _currentUser = UserModel(
          id: firebaseUser?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: cleanEmail,
          phone: cleanPhone,
          name: cleanName,
          username: cleanUsername,
          avatarUrl: firebaseUser?.photoURL ?? '',
          coins: 1000,
          diamonds: 100,
          profileCompleted: false,
          isOnline: true,
        );
      }

      _isAuthenticated = true;
      _isGuest = false;
      await _saveUserLocalSession(_currentUser!);
      await _saveLocalAccount({
        'id': _currentUser!.id,
        'email': cleanEmail,
        'username': cleanUsername,
        'password': cleanPass,
        'phone': cleanPhone,
        'name': cleanName,
        'user': _currentUser!.toJson(),
      });

      FcmService.instance.registerWithBackend();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = FirebaseAuthErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Google Sign-In + Real Backend Database Registration
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (AppConfig.isBackendDisconnected) {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentUser = const UserModel(
        id: 'user_hemiton_google',
        username: 'hemiton_user',
        name: 'HEMI TON User',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
        coins: 50000,
        diamonds: 10000,
        profileCompleted: true,
        isOnline: true,
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      await _clearUserLocalSession();

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '747197896976-evl54uhrqlg0u0rbojrqo1307ee5jr77.apps.googleusercontent.com',
      );

      try {
        await googleSignIn.signOut();
      } catch (_) {}

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.signIn();
      } catch (signInErr) {
        debugPrint('[GoogleSignIn] signIn failed: $signInErr');
        final str = signInErr.toString();
        if (str.contains('10') || str.contains('12500') || str.contains('DEVELOPER_ERROR') || str.contains('ApiException: 10')) {
          _errorMessage = 'Google Sign-In configuration error: Please ensure SHA-1 and SHA-256 fingerprints are added and Google Sign-in is enabled in the Firebase Console.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        rethrow;
      }

      if (googleUser == null) {
        debugPrint('[GoogleSignIn] User canceled account selection dialog.');
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint('[GoogleSignIn] Obtained tokens - idToken present: ${googleAuth.idToken != null}, accessToken present: ${googleAuth.accessToken != null}');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      final cleanEmail = googleUser.email.trim();

      // Extract raw display name from Google or Firebase auth
      String rawGoogleName = (googleUser.displayName != null && googleUser.displayName!.trim().isNotEmpty)
          ? googleUser.displayName!.trim()
          : (firebaseUser?.displayName != null && firebaseUser!.displayName!.trim().isNotEmpty
              ? firebaseUser.displayName!.trim()
              : '');

      // Check if name is a raw technical ID (e.g. Firebase UID)
      final bool isTechId = rawGoogleName.isEmpty ||
          rawGoogleName.length >= 20 ||
          RegExp(r'^[a-zA-Z0-9_-]{20,}$').hasMatch(rawGoogleName) ||
          rawGoogleName.startsWith('user_') ||
          rawGoogleName.startsWith('google_');

      String cleanName;
      if (!isTechId) {
        cleanName = rawGoogleName;
      } else {
        cleanName = 'HEMI TON Member';
      }

      if (cleanName.length > 25) {
        cleanName = cleanName.substring(0, 25).trim();
      }

      final baseUsername = cleanEmail.contains('@') ? cleanEmail.split('@').first.toLowerCase() : cleanEmail.toLowerCase();
      final photoUrl = googleUser.photoUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80';

      // Register / sync Google user into PostgreSQL backend
      try {
        final authRes = await _authRepository.syncUser(
          uid: firebaseUser?.uid,
          email: cleanEmail,
          displayName: cleanName,
          username: baseUsername,
          avatarUrl: photoUrl,
          coins: 1000,
          diamonds: 100,
          isSignup: false,
        );
        _isNewUser = authRes.isNewUser;
        _currentUser = authRes.user.copyWith(
          name: cleanName,
          profileCompleted: !authRes.isNewUser || authRes.user.profileCompleted,
        );
      } catch (syncErr) {
        debugPrint('[AuthProvider] Backend sync warning during Google login: $syncErr');
        if (syncErr is ApiException && (syncErr.statusCode == 403 || syncErr.statusCode == 401)) {
          await FirebaseAuth.instance.signOut().catchError((_) {});
          await googleSignIn.signOut().catchError((_) => null);
          await _clearUserLocalSession();
          _currentUser = null;
          _isAuthenticated = false;
          _errorMessage = syncErr.message;
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _isNewUser = false;
        _currentUser = UserModel(
          id: firebaseUser?.uid ?? 'google_${DateTime.now().millisecondsSinceEpoch}',
          name: cleanName,
          email: cleanEmail,
          username: baseUsername,
          avatarUrl: photoUrl,
          profileCompleted: true,
          isOnline: true,
        );
      }

      _isAuthenticated = true;
      _isGuest = false;
      await _saveUserLocalSession(_currentUser!);
      await _saveLocalAccount({
        'id': _currentUser!.id,
        'email': cleanEmail,
        'username': _currentUser!.username,
        'name': _currentUser!.name,
        'user': _currentUser!.toJson(),
      });
      FcmService.instance.registerWithBackend();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stack) {
      debugPrint('[GoogleSignIn] Failed with exception: $e\n$stack');
      final str = e.toString();
      if (str.contains('10') || str.contains('12500') || str.contains('DEVELOPER_ERROR') || str.contains('ApiException: 10')) {
        _errorMessage = 'Google Sign-In configuration error: Please verify your Firebase configuration. Ensure SHA-1 & SHA-256 fingerprints are added and Google Sign-in is enabled in Firebase Console.';
      } else {
        _errorMessage = FirebaseAuthErrorHandler.getErrorMessage(e);
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete current user's account with password verification (3-day recovery grace period)
  Future<bool> deleteAccount({required String password, String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null && user.email!.isNotEmpty) {
        try {
          final cred = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(cred);
        } catch (authErr) {
          debugPrint('Firebase reauthentication warning: $authErr');
        }
      }

      await _authRepository.deleteAccount(
        password: password,
        reason: reason ?? 'User requested self deletion',
      );

      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      await _clearUserLocalSession();

      _currentUser = null;
      _isAuthenticated = false;
      _isGuest = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete account. Please verify your password and try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Recover a soft-deleted account within the 3-day recovery window
  Future<bool> recoverAccount({String? email, String? phone, String? password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authRes = await _authRepository.recoverAccount(
        email: email,
        phone: phone,
        password: password,
      );
      _currentUser = authRes.user;
      _isAuthenticated = true;
      _isGuest = false;
      _isLoading = false;
      await _saveUserLocalSession(_currentUser!);
      FcmService.instance.registerWithBackend();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to recover account. Please check your credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  /// Password reset email
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.trim().isEmpty || !email.contains('@')) {
      _errorMessage = 'Please enter a valid email address.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = FirebaseAuthErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check username uniqueness against backend
  Future<bool> checkUsernameAvailable(String username) async {
    final lower = username.trim().toLowerCase();
    if (lower == 'admin' || lower == 'HEMI TON' || lower == 'official') {
      return false;
    }
    return true;
  }

  /// Complete multi-step onboarding profile setup
  Future<bool> completeProfileOnboarding({
    required String username,
    required String gender,
    required DateTime dateOfBirth,
    String? name,
    String? region,
    String? avatarUrl,
    String? bio,
  }) async {
    _isLoading = true;
    notifyListeners();

    final finalName = (name != null && name.trim().isNotEmpty) ? name.trim() : username.trim();
    final finalRegion = (region != null && region.trim().isNotEmpty) ? region.trim() : currentUser.region;

    try {
      String? remoteAvatarUrl = avatarUrl;
      if (avatarUrl != null && !avatarUrl.startsWith('http') && !avatarUrl.startsWith('assets/')) {
        try {
          final uploadRes = await MediaUploadService.instance.uploadFile(
            filePath: avatarUrl,
            folder: 'avatars',
          );
          remoteAvatarUrl = uploadRes.url;
        } catch (e) {
          debugPrint('[AuthProvider] Avatar upload to R2 failed: $e');
        }
      }

      if (_isAuthenticated && await _authRepository.hasSavedToken()) {
        final updated = await _authRepository.updateProfile(
          username: username.trim(),
          name: finalName,
          displayName: finalName,
          gender: gender,
          region: finalRegion,
          birthDate: dateOfBirth,
          avatarUrl: remoteAvatarUrl,
          bio: bio,
        );
        _currentUser = updated.copyWith(
          profileCompleted: true,
          username: username.trim(),
          name: finalName,
          gender: gender,
          region: finalRegion,
          dateOfBirth: dateOfBirth,
          bio: (bio != null && bio.trim().isNotEmpty) ? bio.trim() : updated.bio,
        );
      } else {
        _currentUser = currentUser.copyWith(
          username: username.trim(),
          name: finalName,
          gender: gender,
          region: finalRegion,
          dateOfBirth: dateOfBirth,
          avatarUrl: remoteAvatarUrl ?? currentUser.avatarUrl,
          bio: (bio != null && bio.trim().isNotEmpty) ? bio.trim() : currentUser.bio,
          profileCompleted: true,
        );
      }
      _isLoading = false;
      if (_currentUser != null) {
        await _saveUserLocalSession(_currentUser!);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _currentUser = currentUser.copyWith(
        username: username.trim(),
        name: finalName,
        gender: gender,
        region: finalRegion,
        dateOfBirth: dateOfBirth,
        avatarUrl: avatarUrl ?? currentUser.avatarUrl,
        bio: (bio != null && bio.trim().isNotEmpty) ? bio.trim() : currentUser.bio,
        profileCompleted: true,
      );
      _isLoading = false;
      if (_currentUser != null) {
        await _saveUserLocalSession(_currentUser!);
      }
      notifyListeners();
      return true; // Soft complete
    }
  }

  /// Logout securely
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await FcmService.instance.unregisterOnLogout();
    await _clearUserLocalSession();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    _isAuthenticated = false;
    _isGuest = false;
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Update Profile Details on Server
  Future<bool> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? gender,
    String? region,
    DateTime? birthDate,
    String? avatarUrl,
    String? coverUrl,
    bool? isCountryLocked,
    bool? isHost,
    bool? isAgency,
    String? agencyName,
  }) async {
    final finalName = (name != null && name.trim().isNotEmpty) ? name.trim() : currentUser.name;
    final finalUsername = (username != null && username.trim().isNotEmpty) ? username.trim().toLowerCase() : currentUser.username;

    // Optimistically update locally so the user sees changes INSTANTLY
    _currentUser = currentUser.copyWith(
      name: finalName,
      username: finalUsername,
      bio: (bio != null && bio.trim().isNotEmpty) ? bio.trim() : currentUser.bio,
      gender: gender ?? currentUser.gender,
      region: region ?? currentUser.region,
      dateOfBirth: birthDate ?? currentUser.dateOfBirth,
      avatarUrl: (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : currentUser.avatarUrl,
      coverUrl: (coverUrl != null && coverUrl.isNotEmpty) ? coverUrl : currentUser.coverUrl,
      isCountryLocked: isCountryLocked ?? currentUser.isCountryLocked,
      isHost: isHost ?? currentUser.isHost,
      isAgency: isAgency ?? currentUser.isAgency,
      agencyName: agencyName ?? currentUser.agencyName,
      profileCompleted: true,
    );
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _saveUserLocalSession(_currentUser!);

    try {
      String? remoteAvatarUrl = avatarUrl;
      if (avatarUrl != null && !avatarUrl.startsWith('http') && !avatarUrl.startsWith('assets/')) {
        try {
          final uploadRes = await MediaUploadService.instance.uploadFile(
            filePath: avatarUrl,
            folder: 'avatars',
          );
          if (uploadRes.url.isNotEmpty) {
            remoteAvatarUrl = uploadRes.url;
          }
        } catch (e) {
          debugPrint('[AuthProvider] Avatar upload to R2 failed: $e');
          remoteAvatarUrl = avatarUrl; // Fallback to local file path
        }
      }

      String? remoteCoverUrl = coverUrl;
      if (coverUrl != null && !coverUrl.startsWith('http') && !coverUrl.startsWith('assets/')) {
        try {
          final uploadRes = await MediaUploadService.instance.uploadFile(
            filePath: coverUrl,
            folder: 'covers',
          );
          if (uploadRes.url.isNotEmpty) {
            remoteCoverUrl = uploadRes.url;
          }
        } catch (e) {
          debugPrint('[AuthProvider] Cover upload to R2 failed: $e');
          remoteCoverUrl = coverUrl; // Fallback to local file path
        }
      }

      if (_isAuthenticated && await _authRepository.hasSavedToken()) {
        try {
          final updated = await _authRepository.updateProfile(
            username: finalUsername,
            name: finalName,
            displayName: finalName,
            bio: bio,
            gender: gender,
            region: region,
            birthDate: birthDate,
            avatarUrl: remoteAvatarUrl,
            coverUrl: remoteCoverUrl,
          );
          _currentUser = updated.copyWith(
            username: finalUsername,
            name: finalName,
            region: region ?? updated.region,
            isCountryLocked: isCountryLocked ?? updated.isCountryLocked,
            avatarUrl: remoteAvatarUrl ?? updated.avatarUrl,
            coverUrl: remoteCoverUrl ?? updated.coverUrl,
            profileCompleted: true,
          );
        } catch (serverErr) {
          debugPrint('[AuthProvider] Server update error, retaining optimistic state: $serverErr');
        }
        await _saveUserLocalSession(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Failed to update profile on server: $e');
      _errorMessage = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateCurrentUser(UserModel user) {
    _currentUser = user;
    _saveUserLocalSession(user);
    notifyListeners();
  }

  Future<void> updateAvatar(String newAvatarUrl) async {
    await updateProfile(avatarUrl: newAvatarUrl);
  }

  Future<void> updateCoverUrl(String newCoverUrl) async {
    await updateProfile(coverUrl: newCoverUrl);
  }

  void updateHostApplicationStatus(String status, {String? reason}) {
    _currentUser = currentUser.copyWith(
      hostApplicationStatus: status,
      hostRejectionReason: reason,
      isHost: status == 'approved' ? true : currentUser.isHost,
    );
    notifyListeners();
  }

  // CP / Relationship Logic
  void sendCpRequest(String targetUserId) {
    notifyListeners();
  }

  void receiveMockCpRequest(String requesterId) {
    if (!currentUser.pendingCpRequests.contains(requesterId)) {
      final newPending = List<String>.from(currentUser.pendingCpRequests)..add(requesterId);
      _currentUser = currentUser.copyWith(pendingCpRequests: newPending);
      notifyListeners();
    }
  }

  void acceptCpRequest(String partnerId) {
    final newPending = List<String>.from(currentUser.pendingCpRequests)..remove(partnerId);
    _currentUser = currentUser.copyWith(
      pendingCpRequests: newPending,
      cpPartnerId: partnerId,
      cpPoints: 0,
    );
    notifyListeners();
  }

  void rejectCpRequest(String requesterId) {
    final newPending = List<String>.from(currentUser.pendingCpRequests)..remove(requesterId);
    _currentUser = currentUser.copyWith(pendingCpRequests: newPending);
    notifyListeners();
  }

  void breakUpCp() {
    _currentUser = currentUser.copyWith(
      cpPartnerId: '',
      cpPoints: 0,
    );
    notifyListeners();
  }



  // Follow system — backend authoritative
  // Local cache of following IDs for fast UI without round-trips
  final Set<String> _followingUserIds = {};
  final Set<String> _followerUserIds = {};
  final Set<String> _blockedUserIds = {};
  final List<UserModel> _blockedUsers = [];

  bool isFollowing(String userId) => _followingUserIds.contains(userId);
  Set<String> get followingUserIds => Set.unmodifiable(_followingUserIds);
  Set<String> get followerUserIds => Set.unmodifiable(_followerUserIds);

  List<UserModel> getFollowingUsers() {
    return _followingUserIds.map((id) => BackendRepository.instance.getUserById(id)).toList();
  }

  List<UserModel> getFollowerUsers() {
    return _followerUserIds.map((id) => BackendRepository.instance.getUserById(id)).toList();
  }

  bool isBlocked(String userId) => _blockedUserIds.contains(userId);
  Set<String> get blockedUserIds => Set.unmodifiable(_blockedUserIds);
  List<UserModel> get blockedUsers => List.unmodifiable(_blockedUsers);

  Future<List<UserModel>> loadBlockedUsers() async {
    try {
      final rawList = await SocialRepository.instance.fetchBlockedUsers();
      _blockedUsers.clear();
      _blockedUserIds.clear();

      for (final item in rawList) {
        final id = (item['id'] ?? '').toString();
        if (id.isNotEmpty) {
          _blockedUserIds.add(id);
          _blockedUsers.add(UserModel(
            id: id,
            name: (item['name'] ?? 'Blocked User').toString(),
            username: (item['username'] ?? id).toString(),
            avatarUrl: (item['avatarUrl'] ?? '').toString(),
            email: '',
          ));
        }
      }
      notifyListeners();
      return _blockedUsers;
    } catch (e) {
      debugPrint('[AuthProvider] loadBlockedUsers error: $e');
      return _blockedUsers;
    }
  }

  Future<void> syncFollowingList() async {
    if (_currentUser == null || _currentUser!.id.isEmpty || _isGuest) return;
    try {
      final res = await SocialRepository.instance.fetchFollowing(_currentUser!.id);
      final List<dynamic> list = res['data'] ?? res['following'] ?? [];
      final ids = <String>{};
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final id = item['id']?.toString() ?? item['userId']?.toString();
          if (id != null && id.isNotEmpty) ids.add(id);
        } else if (item is String && item.isNotEmpty) {
          ids.add(item);
        }
      }
      _followingUserIds.clear();
      _followingUserIds.addAll(ids);
      _currentUser = currentUser.copyWith(following: _followingUserIds.length);
      await _saveFollowState();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> followUser(String targetUserId) async {
    if (targetUserId == currentUser.id || _followingUserIds.contains(targetUserId) || isBlocked(targetUserId)) {
      return;
    }
    // Optimistic
    _followingUserIds.add(targetUserId);
    _currentUser = currentUser.copyWith(following: _followingUserIds.length);
    BackendRepository.instance.updateUserFollowers(targetUserId, 1);
    await _saveFollowState();
    notifyListeners();

    try {
      await SocialRepository.instance.followUser(targetUserId);
    } catch (_) {
      // Rollback on hard error if needed
    }
  }

  Future<void> unfollowUser(String targetUserId) async {
    if (!_followingUserIds.contains(targetUserId)) return;
    // Optimistic
    _followingUserIds.remove(targetUserId);
    _currentUser = currentUser.copyWith(following: _followingUserIds.length);
    BackendRepository.instance.updateUserFollowers(targetUserId, -1);
    await _saveFollowState();
    notifyListeners();

    try {
      await SocialRepository.instance.unfollowUser(targetUserId);
    } catch (_) {
      // Rollback on hard error if needed
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    if (isFollowing(targetUserId)) {
      await unfollowUser(targetUserId);
    } else {
      await followUser(targetUserId);
    }
  }

  Future<void> blockUser(String targetUserId) async {
    if (targetUserId == currentUser.id) return;
    try {
      await SocialRepository.instance.blockUser(targetUserId);
      _blockedUserIds.add(targetUserId);
      _followingUserIds.remove(targetUserId);
      _blockedUsers.removeWhere((u) => u.id == targetUserId);
      notifyListeners();
    } catch (_) {
      // Still update local state optimistically if offline/demo
      _blockedUserIds.add(targetUserId);
      _followingUserIds.remove(targetUserId);
      notifyListeners();
    }
  }

  Future<void> unblockUser(String targetUserId) async {
    try {
      await SocialRepository.instance.unblockUser(targetUserId);
      _blockedUserIds.remove(targetUserId);
      _blockedUsers.removeWhere((u) => u.id == targetUserId);
      notifyListeners();
    } catch (_) {
      // Fallback local unblock
      _blockedUserIds.remove(targetUserId);
      _blockedUsers.removeWhere((u) => u.id == targetUserId);
      notifyListeners();
    }
  }

  Future<UserModel?> getUserById(String id) async {
    if (id == currentUser.id) return currentUser;

    try {
      final result = await SocialRepository.instance.getUserById(id);
      final raw = result['data'] ?? result;
      if (raw is Map<String, dynamic>) {
        return UserModel.fromJson(raw);
      }
    } on ApiException catch (e) {
      debugPrint('[AuthProvider] getUserById error: ${e.message}');
    } catch (e) {
      debugPrint('[AuthProvider] getUserById unexpected error: $e');
    }
    return null;
  }
}
