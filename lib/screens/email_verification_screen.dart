import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to OTP verification since we use OTP instead of email links
    return const OtpVerificationScreen();
  }
}