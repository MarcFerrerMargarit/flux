import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late StreamSubscription<AuthState> _authSubscription;

  bool _isResending = false;
  bool _resendSuccess = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();

    // Listen for auth state changes — when user clicks email link,
    // Supabase fires a signedIn event
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.userUpdated) {
        final user = data.session?.user;
        if (user != null && user.emailConfirmedAt != null) {
          // Email confirmed! Navigate to dashboard
          if (mounted) {
            context.go('/dashboard');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _animationController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    if (_isResending || _resendCooldown > 0) return;

    setState(() {
      _isResending = true;
      _resendSuccess = false;
    });

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      setState(() {
        _resendSuccess = true;
        _resendCooldown = 60;
      });
      _startCooldownTimer();
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) {
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A237E),
                    const Color(0xFF0D47A1),
                    const Color(0xFF01579B),
                  ]
                : [
                    const Color(0xFF2196F3),
                    const Color(0xFF00BCD4),
                    const Color(0xFF00ACC1),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Email icon with animation
                        _buildEmailIcon(isDark),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Verifica tu Email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'Hemos enviado un enlace de verificación a:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2196F3)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            widget.email,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1565C0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Instructions
                        Text(
                          'Revisa tu bandeja de entrada y haz clic en el enlace para activar tu cuenta.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.grey[500],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Resend button
                        _buildResendButton(isDark),

                        if (_resendSuccess) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF00C853),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '¡Email reenviado!',
                                style: TextStyle(
                                  color: const Color(0xFF00C853),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey[300],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'o',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey[400],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Back to login
                        TextButton.icon(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (mounted) context.go('/login');
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF2196F3),
                          ),
                          label: Text(
                            'Volver al inicio de sesión',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF2196F3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailIcon(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.mark_email_unread_rounded,
          size: 48, color: Colors.white),
    );
  }

  Widget _buildResendButton(bool isDark) {
    final canResend = !_isResending && _resendCooldown <= 0;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: canResend ? _resendEmail : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: canResend
                ? (isDark ? Colors.white54 : const Color(0xFF2196F3))
                : Colors.grey.withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isResending
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Text(
                _resendCooldown > 0
                    ? 'Reenviar en ${_resendCooldown}s'
                    : 'Reenviar email de verificación',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: canResend
                      ? (isDark ? Colors.white : const Color(0xFF2196F3))
                      : Colors.grey,
                ),
              ),
      ),
    );
  }
}
