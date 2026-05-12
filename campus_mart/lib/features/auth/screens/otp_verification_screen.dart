import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? email;
  final bool isPasswordReset;
  final Map<String, String>? registrationData;
  const OTPVerificationScreen({
    super.key,
    this.phoneNumber,
    this.email,
    this.isPasswordReset = false,
    this.registrationData,
  }) : assert(phoneNumber != null || email != null);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (i) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (i) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    
    bool success;
    if (widget.isPasswordReset) {
      success = await auth.verifyPasswordResetOtp(widget.email!, otp);
    } else if (widget.email != null) {
      success = await auth.verifyEmailOtp(widget.email!, otp);
    } else {
      success = await auth.verifyPhoneOtp(widget.phoneNumber!, otp);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      if (widget.isPasswordReset) {
        context.push('/reset-password', extra: widget.email);
      } else if (widget.registrationData != null) {
        // Finalize registration by sending the Email OTP / Creating the account
        final email = widget.registrationData!['email']!;
        final name = widget.registrationData!['name']!;
        final phone = widget.registrationData!['phone']!;
        
        final regSuccess = await auth.signInWithEmailOtp(
          email,
          data: {'name': name, 'phone': phone},
        );
        
        if (!mounted) return;
        if (regSuccess) {
          // Now they just need to verify the email OTP to finish
          context.pushReplacement('/verify-otp', extra: {'email': email});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(auth.errorMessage ?? 'Registration failed')),
          );
        }
      } else {
        context.go('/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Invalid OTP'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002F34)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Hero(
                tag: 'app_logo',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF002F34),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront, color: Color(0xFFC8F064), size: 40),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Enter verification code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF002F34),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We have sent a 6-digit code to ${widget.email ?? widget.phoneNumber}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF406367)),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                return SizedBox(
                  width: 48,
                  height: 56,
                  child: TextFormField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    autofocus: i == 0,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF002F34)),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF2F4F5),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFEBEEEF))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF002F34), width: 2)),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      } else if (v.isEmpty && i > 0) {
                        _focusNodes[i - 1].requestFocus();
                      }
                      if (otp.length == 6) _verify();
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoading ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002F34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Verify and Login'),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : () async {
                  final auth = context.read<AuthProvider>();
                  bool success;
                  if (widget.email != null) {
                    success = await auth.signInWithEmailOtp(widget.email!);
                  } else {
                    success = await auth.signInWithPhone(widget.phoneNumber!);
                  }
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP Resent!')),
                    );
                  }
                },
                child: const Text(
                  'Resend Code',
                  style: TextStyle(color: Color(0xFF002F34), fontWeight: FontWeight.w900, decoration: TextDecoration.underline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get otp => _controllers.map((c) => c.text).join();
}
