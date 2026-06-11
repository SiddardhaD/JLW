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

  static const _serif = TextStyle(fontFamily: 'serif');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin(ApprovalsProvider provider) {
    provider.login();
    if (provider.isAuthenticated) {
      widget.onLoginSuccess();
    }
  }

  void _quickDemoLogin(ApprovalsProvider provider) {
    _usernameController.text = 'EXECUTIVE_DEMO';
    _passwordController.text = 'SECURE123';
    provider.setUsername('EXECUTIVE_DEMO');
    provider.setPassword('SECURE123');
    _attemptLogin(provider);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApprovalsProvider>(context);

    return Scaffold(
      backgroundColor: JLWColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 28),
              _buildLoginCard(provider),
              const SizedBox(height: 48),
              _buildFooter(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'assets/images/logo.png',
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 48,
          height: 3,
          decoration: BoxDecoration(
            color: JLWColors.brandGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(ApprovalsProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: JLWColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: JLWColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign In',
            style: _serif.copyWith(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'SECURE ENTERPRISE ACCESS',
            style: TextStyle(
              color: JLWColors.slateText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          if (provider.loginError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: JLWColors.buttonReject.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: JLWColors.buttonReject.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: JLWColors.buttonReject,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.loginError!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          _buildFieldLabel('USER NAME'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _usernameController,
            hint: 'Enter identity ID',
            icon: Icons.person_outline,
            onChanged: provider.setUsername,
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('PASSWORD'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: true,
            onChanged: provider.setPassword,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => _attemptLogin(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: JLWColors.brandGreen,
                foregroundColor: JLWColors.textDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'LOGIN',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildBiometricDivider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBiometricButton(
                  icon: Icons.face_outlined,
                  label: 'Face ID',
                  onTap: () => _quickDemoLogin(provider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBiometricButton(
                  icon: Icons.fingerprint,
                  label: 'Fingerprint',
                  onTap: () => _quickDemoLogin(provider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: JLWColors.slateText,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      style: _serif.copyWith(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: JLWColors.inputBg,
        hintText: hint,
        hintStyle: _serif.copyWith(
          color: JLWColors.slateText.withOpacity(0.7),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: JLWColors.slateText, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: JLWColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: JLWColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: JLWColors.brandGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBiometricDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: JLWColors.borderColor, height: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'BIOMETRIC AUTH',
            style: TextStyle(
              color: JLWColors.slateText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const Expanded(child: Divider(color: JLWColors.borderColor, height: 1)),
      ],
    );
  }

  Widget _buildBiometricButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: JLWColors.inputBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JLWColors.borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: JLWColors.brandGreen, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: JLWColors.brandGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Internal Executive Tool • v4.2.0',
          textAlign: TextAlign.center,
          style: _serif.copyWith(
            color: JLWColors.slateText,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterLink('Privacy Policy'),
            const SizedBox(width: 24),
            _buildFooterLink('System Status'),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(String label) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        label,
        style: _serif.copyWith(
          color: JLWColors.slateText,
          fontSize: 11,
          decoration: TextDecoration.underline,
          decorationColor: JLWColors.slateText.withOpacity(0.5),
        ),
      ),
    );
  }
}
