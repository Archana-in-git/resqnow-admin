import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Admin Authentication Controller
/// Manages login, signup, and admin verification for the admin dashboard
class AdminAuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String usersCollection = 'users';

  // State variables
  User? _currentUser;
  String? _currentUserRole;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  String? get userRole => _currentUserRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _currentUserRole == 'admin';

  // Constructor - check auth state on initialization
  AdminAuthController() {
    _checkAuthState();
    _auth.authStateChanges().listen((_) {
      _checkAuthState();
    });
  }

  /// Check current authentication state
  Future<void> _checkAuthState() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      await _fetchUserRole();
      _isAuthenticated = true;
    } else {
      _currentUserRole = null;
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  /// Fetch user role from Firestore
  Future<void> _fetchUserRole() async {
    if (_currentUser == null) return;

    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists) {
        _currentUserRole = doc.get('role') as String?;
      }
    } catch (e) {
      _error = 'Failed to fetch user role: $e';
    }
    notifyListeners();
  }

  /// Login with email and password
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = credential.user;

      // Fetch user role
      await _fetchUserRole();

      // Check if admin
      if (!isAdmin) {
        // Not an admin - sign out immediately
        await _auth.signOut();
        _currentUser = null;
        _currentUserRole = null;
        _isAuthenticated = false;
        _error = 'Access denied. Admin role required.';
        notifyListeners();
        return false;
      }

      _isAuthenticated = true;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getUserFriendlyErrorMessage(e.code);
      _currentUser = null;
      _currentUserRole = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = 'Login failed: $e';
      _currentUser = null;
      _currentUserRole = null;
      _isAuthenticated = false;
    }

    notifyListeners();
    return false;
  }

  /// Signup with email and password (Optional - typically admins are created server-side)
  Future<bool> signupWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Create user document in Firestore
        await _firestore.collection(usersCollection).doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': 'user', // Default role - admin must be set server-side
          'accountStatus': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
        }, SetOptions(merge: true));

        _currentUser = user;
        _currentUserRole = 'user';
        _isAuthenticated = true;

        // Note: User is not admin after signup - admin role must be set server-side
        _error =
            'Account created. Admin access must be granted by system administrator.';
      }

      notifyListeners();
      return false; // Not logged in as admin
    } on FirebaseAuthException catch (e) {
      _error = _getUserFriendlyErrorMessage(e.code);
      _currentUser = null;
      _currentUserRole = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = 'Signup failed: $e';
      _currentUser = null;
      _currentUserRole = null;
      _isAuthenticated = false;
    }

    notifyListeners();
    return false;
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getUserFriendlyErrorMessage(e.code);
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
      _currentUser = null;
      _currentUserRole = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = 'Sign out failed: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getUserFriendlyErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No admin account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'user-disabled':
        return 'This admin account has been disabled.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address. Please try again.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: $code';
    }
  }
}
