import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../dashboard/dashboard_screen.dart';

enum OtpMode { signup, login }

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final OtpMode mode;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.mode,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() async {
    while (_resendCooldown > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _resendCooldown--);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _onVerify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Call POST /api/auth/verify-otp
    // final response = await ApiService.verifyOtp(
    //   email: widget.email,
    //   otp: _otp,
    //   mode: widget.mode == OtpMode.signup ? 'signup' : 'login',
    // );

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (_) => false,
    );
  }

  Future<void> _onResend() async {
    if (_resendCooldown > 0) return;
    setState(() {
      _isResending = true;
      _resendCooldown = 60;
    });

    // TODO: Call POST /api/auth/resend-otp
    // await ApiService.resendOtp(email: widget.email);

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isResending = false);
    _startCooldown();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code resent!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSignup = widget.mode == OtpMode.signup;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3), width: 1.5),
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                isSignup ? 'Verify Your Email' : 'Confirm Login',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                isSignup
                    ? 'We\'ve sent a 6-digit verification code to confirm your account.'
                    : 'A login confirmation code has been sent to your email for security.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),
              OtpInputRow(controllers: _controllers, focusNodes: _focusNodes),
              const SizedBox(height: 36),
              PrimaryButton(
                label: isSignup ? 'Verify Account' : 'Confirm Login',
                onPressed: _onVerify,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                        color: AppColors.textSecondary, fontFamily: 'Outfit'),
                  ),
                  _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary))
                      : GestureDetector(
                          onTap: _resendCooldown == 0 ? _onResend : null,
                          child: Text(
                            _resendCooldown > 0
                                ? 'Resend in ${_resendCooldown}s'
                                : 'Resend',
                            style: TextStyle(
                              color: _resendCooldown == 0
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 32),
              // Security info
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.security_rounded,
                        color: AppColors.accent, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This two-step verification protects your account from unauthorized access.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Outfit',
                          height: 1.5,
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
}
