import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/email_otp_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final EmailOtpService _otpService = EmailOtpService();
  bool _isLoading = false;
  String? _error;
  bool _otpSent = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get otpSent => _otpSent;
  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<void> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _authService.signUp(email, password);
      if (credential.user != null) {
        await _firestoreService.createUserProfile(UserModel(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        ));
        // Send OTP instead of email verification
        await _otpService.sendOtpToEmail(email);
        _otpSent = true;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final isValid = await _otpService.verifyOtp(email, otp);
      if (isValid && currentUser != null) {
        await _otpService.markUserAsVerified(currentUser!.uid);
        return true;
      }
      _error = 'Invalid or expired code';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _otpService.sendOtpToEmail(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signIn(email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _otpSent = false;
    notifyListeners();
  }

  Future<bool> isUserVerified() async {
    if (currentUser == null) return false;
    try {
      final doc = await _firestoreService.getUserProfile(currentUser!.uid);
      return doc?['emailVerified'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    return await _firestoreService.getUserProfile(currentUser!.uid);
  }
}
