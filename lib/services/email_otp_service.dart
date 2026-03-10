import 'dart:math';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailOtpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    // Queue an email document; a Cloud Function is responsible for delivery.
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
    developer.log(
      'OTP email queued in Firestore (otp_emails).',
      name: 'EmailOtpService',
    );
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