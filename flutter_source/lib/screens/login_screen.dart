import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/approvals_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApprovalsProvider>(context);

    return Scaffold(
      backgroundColor: JLWColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // Enterprise logo branding mark
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: JLWColors.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: JLWColors.mintAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: JLWColors.mintAccent.withOpacity(0.15),
                        blurRadius: 16,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fingerprint,
                      color: JLWColors.mintAccent,
                      size: 48,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title Display Pairs
              const Text(
                "JLW",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  fontSize: 42,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                "EXECUTIVE APPROVALS PORTAL",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JLWColors.mintAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "TRUST SECURED SINCE 1875",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JLWColors.slateText,
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 48),

              // Error banner if any
              if (provider.loginError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: JLWColors.buttonReject.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: JLWColors.buttonReject.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: JLWColors.buttonReject, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider.loginError!,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Username input
              const Text(
                "ENTERPRISE USER IDENTIFIER",
                style: TextStyle(
                  color: JLWColors.slateText,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                onChanged: provider.setUsername,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: JLWColors.inputBg,
                  hintText: "e.g., EXECUTIVE_ADMIN",
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: JLWColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: JLWColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: JLWColors.mintAccent),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Password input
              const Text(
                "SECURITY ACCESS PIN / KEY",
                style: TextStyle(
                  color: JLWColors.slateText,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                onChanged: provider.setPassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: JLWColors.inputBg,
                  hintText: "••••••••",
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: JLWColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: JLWColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: JLWColors.mintAccent),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sign in button
              ElevatedButton(
                onPressed: () {
                  provider.login();
                  if (provider.isAuthenticated) {
                    widget.onLoginSuccess();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: JLWColors.mintAccent,
                  foregroundColor: JLWColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedCornerShape(6),
                  elevation: 4,
                ),
                child: const Text(
                  "SIGN IN SECURELY",
                  style: TextStyle(
                    fontWeight: FontWeight.extrabold,
                    letterSpacing: 1.0,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Biometric simulated pass section
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Text(
                      "OR QUICK SIGN IN FOR DEVELOPMENT",
                      style: TextStyle(
                        color: JLWColors.slateText,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        _usernameController.text = "EXECUTIVE_DEMO";
                        _passwordController.text = "SECURE123";
                        provider.setUsername("EXECUTIVE_DEMO");
                        provider.setPassword("SECURE123");
                        provider.login();
                        if (provider.isAuthenticated) {
                          widget.onLoginSuccess();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: JLWColors.cardBg,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: JLWColors.mintAccent.withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.face, color: JLWColors.mintAccent, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Simulate Face ID Gate",
                              style: TextStyle(
                                color: JLWColors.mintAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  RoundedRectangleBorder RoundedCornerShape(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}
