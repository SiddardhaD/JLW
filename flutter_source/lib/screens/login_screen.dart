import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/approvals_provider.dart';
import '../services/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _secureStorage = SecureStorageService();

  static const _serif = TextStyle(fontFamily: 'serif');

  bool _checkingSession = true;
  bool _hasSavedSession = false;
  String _savedUsername = '';
  bool _biometricAttempting = false;
  String? _biometricError;
  bool _showNormalLogin = false;

  @override
  void initState() {
    super.initState();
    _checkSavedSession();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkSavedSession() async {
    final provider = context.read<ApprovalsProvider>();
    await provider.loadBiometricPreference();
    final credentials = await _secureStorage.loadCredentials();
    if (!mounted) return;

    if (provider.isBiometricEnabled && credentials != null) {
      setState(() {
        _hasSavedSession = true;
        _savedUsername = credentials.username;
        _checkingSession = false;
      });
      _triggerBiometric();
    } else {
      setState(() => _checkingSession = false);
    }
  }

  Future<void> _triggerBiometric() async {
    if (!mounted) return;
    setState(() {
      _biometricAttempting = true;
      _biometricError = null;
    });

    try {
      final bool isSupported = await _localAuth.isDeviceSupported();
      if (!mounted) return;

      if (!isSupported) {
        setState(() {
          _biometricAttempting = false;
          _hasSavedSession = false;
          _showNormalLogin = false;
          _biometricError = null;
        });
        return;
      }

      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to access JLW Approvals',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (!mounted) return;
      if (authenticated) {
        await _loginWithBiometricsAndNavigate();
      } else {
        setState(() {
          _biometricAttempting = false;
          _biometricError = 'Authentication cancelled. Try again or sign in with password.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _biometricAttempting = false;
        _biometricError = 'Biometric authentication failed. Please sign in with password.';
      });
    }
  }

  /// Uses the securely stored credentials to call the login API again,
  /// so biometric sign-in always obtains a fresh token rather than reusing a stale one.
  Future<void> _loginWithBiometricsAndNavigate() async {
    if (!mounted) return;
    final provider = context.read<ApprovalsProvider>();
    final success = await provider.loginWithStoredCredentials();
    if (!mounted) return;
    if (success) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _biometricAttempting = false;
        _biometricError = provider.loginError ??
            'Unable to sign in. Please use your password.';
      });
    }
  }

  Future<void> _attemptLogin(ApprovalsProvider provider) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final isSuccess = await provider.login();
    if (!mounted || !isSuccess) return;

    if (!provider.isBiometricEnabled) {
      await _maybeOfferBiometricEnrollment(provider, username, password);
    }
    if (mounted) widget.onLoginSuccess();
  }

  Future<void> _maybeOfferBiometricEnrollment(
    ApprovalsProvider provider,
    String username,
    String password,
  ) async {
    try {
      final canUseBiometrics = await _localAuth.isDeviceSupported() &&
          await _localAuth.canCheckBiometrics;
      if (!canUseBiometrics || !mounted) return;

      final wantsBiometric = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: JLWColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: JLWColors.borderColor),
          ),
          title: const Text(
            'Enable biometric sign-in?',
            style: TextStyle(color: JLWColors.textDark, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Use Face ID, Touch ID, or your device biometrics to sign in faster next time.',
            style: TextStyle(color: JLWColors.slateText, fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not now', style: TextStyle(color: JLWColors.slateText)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: JLWColors.mintAccent,
                foregroundColor: JLWColors.darkBg,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Enable', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

      if (wantsBiometric != true || !mounted) return;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Confirm biometrics to enable fast sign-in',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );
      if (authenticated) {
        await provider.enableBiometricLogin(username: username, password: password);
      }
    } catch (_) {
      // Enrollment is best-effort; login has already succeeded regardless.
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApprovalsProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: JLWColors.darkBg,
        body: SafeArea(
          child: _checkingSession
              ? _buildLoadingView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      _buildHeader(),
                      const SizedBox(height: 28),
                      if (_hasSavedSession && !_showNormalLogin)
                        _buildBiometricResumeCard()
                      else
                        _buildLoginCard(provider),
                      const SizedBox(height: 48),
                      _buildFooter(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(color: JLWColors.mintAccent),
    );
  }

  Widget _buildBiometricResumeCard() {
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
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontFamily: 'serif',
              color: JLWColors.textDark,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'BIOMETRIC SECURE ACCESS',
            style: TextStyle(
              color: JLWColors.slateText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: JLWColors.inputBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: JLWColors.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, color: JLWColors.mintAccent, size: 20),
                const SizedBox(width: 12),
                Text(
                  _savedUsername,
                  style: const TextStyle(
                    color: JLWColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_biometricError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: JLWColors.buttonReject.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: JLWColors.buttonReject.withValues(alpha:0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: JLWColors.buttonReject, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _biometricError!,
                      style: const TextStyle(
                        color: JLWColors.buttonReject,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _biometricAttempting ? null : _triggerBiometric,
              style: ElevatedButton.styleFrom(
                backgroundColor: JLWColors.mintAccent,
                foregroundColor: JLWColors.darkBg,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _biometricAttempting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(JLWColors.darkBg),
                      ),
                    )
                  : const Icon(Icons.fingerprint, size: 26),
              label: Text(
                _biometricAttempting ? 'Authenticating...' : 'Authenticate',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => setState(() => _showNormalLogin = true),
            child: const Text(
              'Sign in with different account',
              style: TextStyle(
                color: JLWColors.slateText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => AlertDialog(
        backgroundColor: JLWColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: JLWColors.borderColor),
        ),
        title: const Text(
          'Exit App',
          style: TextStyle(
            color: JLWColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: JLWColors.slateText, fontSize: 14, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: JLWColors.slateText, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: JLWColors.buttonReject,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Exit', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (shouldExit == true) SystemNavigator.pop();
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
            color: JLWColors.mintAccent,
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
          if (_hasSavedSession) ...[
            TextButton.icon(
              onPressed: () => setState(() => _showNormalLogin = false),
              icon: const Icon(Icons.arrow_back, size: 16, color: JLWColors.slateText),
              label: const Text(
                'Back to biometric login',
                style: TextStyle(
                  color: JLWColors.slateText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Sign In',
            style: _serif.copyWith(
              color: JLWColors.textDark,
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
                color: JLWColors.buttonReject.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: JLWColors.buttonReject.withValues(alpha:0.4),
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
                        color: JLWColors.buttonReject,
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
              onPressed: provider.isLoginLoading
                  ? null
                  : () => _attemptLogin(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: JLWColors.brandGreen,
                foregroundColor: JLWColors.textDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: provider.isLoginLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
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
      style: _serif.copyWith(color: JLWColors.textDark, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: JLWColors.inputBg,
        hintText: hint,
        hintStyle: _serif.copyWith(
          color: JLWColors.slateText.withValues(alpha:0.8),
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
          decorationColor: JLWColors.slateText.withValues(alpha:0.5),
        ),
      ),
    );
  }
}
