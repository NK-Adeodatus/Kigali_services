import 'dart:math';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailOtpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _safeEnv(String key) {
    try {
      return dotenv.env[key];
    } catch (_) {
      // dotenv not initialized (common on web when no asset is bundled)
      return null;
    }
  }

  String _generateOtp() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Future<void> sendOtpToEmail(String email) async {
    final otp = _generateOtp();
    
    // Store OTP in Firestore with expiry
    await _firestore.collection('email_otps').doc(email).set({
      'otp': otp,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
      'verified': false,
    });

    // Send email using Firebase Functions or third-party service
    // For now, we'll simulate by storing in a collection the user can check
    await _firestore.collection('otp_emails').add({
      'to': email,
      'subject': 'Kigali City Services - Verification Code',
      'html': '''
        <h2>Your Verification Code</h2>
        <p>Your verification code is: <strong style="font-size: 24px; color: #1976d2;">$otp</strong></p>
        <p>This code will expire in 10 minutes.</p>
      ''',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Send real email via EmailJS (optional)
    final serviceId = _safeEnv('EMAILJS_SERVICE_ID');
    final templateId = _safeEnv('EMAILJS_TEMPLATE_ID');
    final publicKey = _safeEnv('EMAILJS_PUBLIC_KEY');
    if (serviceId == null ||
        serviceId.isEmpty ||
        templateId == null ||
        templateId.isEmpty ||
        publicKey == null ||
        publicKey.isEmpty) {
      developer.log(
        'EmailJS not configured; OTP stored in Firestore only.',
        name: 'EmailOtpService',
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'email': email,
          'otp_code': otp,
        },
      }),
    );
    developer.log('EmailJS Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP email: ${response.body}');
    }
  }

  Future<bool> verifyOtp(String email, String enteredOtp) async {
    try {
      final doc = await _firestore.collection('email_otps').doc(email).get();
      
      if (!doc.exists) return false;
      
      final data = doc.data()!;
      final storedOtp = data['otp'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final verified = data['verified'] as bool;
      
      if (verified) return false; // Already used
      if (DateTime.now().isAfter(expiresAt)) return false; // Expired
      if (storedOtp != enteredOtp) return false; // Wrong code
      
      // Mark as verified
      await _firestore.collection('email_otps').doc(email).update({
        'verified': true,
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> markUserAsVerified(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'emailVerified': true,
      'verifiedAt': FieldValue.serverTimestamp(),
    });
  }
}