import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scan_learn/screens/homescreen.dart';
import 'package:scan_learn/screens/permessions.dart';
import 'package:scan_learn/screens/tutorial.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Otp extends StatefulWidget {
  final String verificationId;
  final int? resendToken; // optional resend token from SignUp flow

  const Otp({
    super.key,
    required this.verificationId,
    this.resendToken,
  });

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final Color brandDarkBlue = const Color(0xFF192B44);
  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    final code = otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter 6-digit code')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Invalid code')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification failed')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _resendCode() async {
    // You should pass the resendToken received during codeSent callback from SignUp.
    if (widget.resendToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot resend code now. Please try again later.')),
      );
      return;
    }
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
      forceResendingToken: widget.resendToken,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Optional: auto sign-in if verification completes automatically
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Resend failed')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent')),
        );
        // Optionally update resend token
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCodeValid = otpController.text.trim().length == 6;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450, minWidth: 100),
              child: Column(
                children: [
                  Text(
                    "Scan & Learn",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: brandDarkBlue,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      hintText: "Enter 6 digit OTP",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn’t receive code?"),
                      TextButton(
                        onPressed: isLoading ? null : _resendCode,
                        child: const Text("Resend"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isCodeValid && !isLoading ? _verifyOtp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandDarkBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : const Text("Verify"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
