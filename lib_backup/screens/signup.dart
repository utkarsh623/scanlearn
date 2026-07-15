import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final Color brandDarkBlue = const Color(0xFF192B44);
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verifyController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Regular expression to validate 10-digit Indian mobile number
  final RegExp indianMobileRegex = RegExp(r'^[6-9]\d{9}$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450, minWidth: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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

                  // Name Field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      prefixIcon: Icon(Icons.person, color: brandDarkBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: brandDarkBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone Field: E.164 compliant with +91 prefix UI
                  Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        isDense: true,
                      ),
                    ),
                    child: TextField(
                      key: const ValueKey('phoneField'),
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "Enter your phone number",
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                          child: Text(
                            '+91',
                            style: TextStyle(fontSize: 16, color: brandDarkBlue),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: brandDarkBlue, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field with visibility toggle
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      prefixIcon: Icon(Icons.lock, color: brandDarkBlue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: brandDarkBlue,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: brandDarkBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field with visibility toggle
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: verifyController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: "Confirm your password",
                      prefixIcon: Icon(Icons.lock, color: brandDarkBlue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: brandDarkBlue,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: brandDarkBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sign Up button → Trigger OTP verification flow
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final raw = phoneController.text.trim();
                        if (!indianMobileRegex.hasMatch(raw)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter a valid 10-digit Indian mobile number')),
                          );
                          return;
                        }
                        final phoneE164 = '+91$raw'; // E.164 format
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: phoneE164,
                          verificationCompleted: (PhoneAuthCredential credential) {
                            // Optional auto sign-in on Android
                            // FirebaseAuth.instance.signInWithCredential(credential);
                          },
                          verificationFailed: (FirebaseAuthException ex) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(ex.message ?? 'Verification failed')),
                            );
                          },
                          codeSent: (String verificationId, int? resendToken) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Otp(verificationId: verificationId),
                              ),
                            );
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandDarkBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Sign In"),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Redirect to Login screen for existing users
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text("Already a user?"),
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
