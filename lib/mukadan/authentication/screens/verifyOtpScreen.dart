import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../AnalyticsDebugService.dart';
import '../../../mukadam_Screen.dart';
import '../auth_service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../userProvider.dart';
import '../user_model.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final AuthResponse authData;

  const VerifyOtpScreen({
    super.key,
    required this.phoneNumber,
    required this.authData,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());

  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResend = false;
  bool _isVerifying = false;

  // ── Professional Color Palette (matching PhoneEntryScreen) ──
  static const Color _primaryColor = Color(0xFF1E3A5F);
  static const Color _accentColor = Color(0xFF3B82F6);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 4) {
      _showSnackBar("Please enter the complete OTP", _errorColor,
          Icons.error_outline_rounded);
      return;
    }

    setState(() => _isVerifying = true);

    try {
      bool verified = await OtpApiService.verifyOtp(
        phoneNumber: widget.phoneNumber,
        otp: otp,
      );

      if (verified && mounted) {
        // ✅ STEP 1: Persist session to SharedPreferences ONLY after OTP verified
        await OtpApiService.persistSession(widget.authData);

        // ✅ STEP 2: Update UserProvider
        Provider.of<UserProvider>(context, listen: false)
            .setUserData(widget.authData);

        final prefs = await SharedPreferences.getInstance();

        final user = widget.authData.user;
        await FirebaseAnalytics.instance.setUserId(id: user.id.toString());

        await AnalyticsDebugService.logDebugEvent('login_success', params: {
          'user_id': user.id,
          'username': user.username,
          'phone_number': widget.phoneNumber,
          'login_time': DateTime.now().toString(),
        });

        // ✅ STEP 3: Mark as logged in
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MukadamDashboard()),
              (route) => false,
        );
      }
    } catch (e) {
      _showSnackBar(
        e.toString().replaceAll("Exception: ", ""),
        _errorColor,
        Icons.warning_amber_rounded,
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }


  // ── RESEND TIMER ──────────────────────────────────────────────
  void _startResendTimer() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _resendOtp() async {
    try {
      await OtpApiService.sendOtp(phoneNumber: widget.phoneNumber);
      _showSnackBar(
          "OTP resent successfully", _successColor, Icons.check_circle_rounded);
      _startResendTimer();
    } catch (e) {
      _showSnackBar(
        e.toString().replaceAll("Exception: ", ""),
        _errorColor,
        Icons.warning_amber_rounded,
      );
    }
  }

  // ── KEYPAD HANDLERS ───────────────────────────────────────────
  void _onKeypadTap(String value) {
    for (int i = 0; i < 4; i++) {
      if (_controllers[i].text.isEmpty) {
        setState(() => _controllers[i].text = value);
        if (i < 3) _focusNodes[i + 1].requestFocus();
        break;
      }
    }
  }

  void _onBackspace() {
    for (int i = 3; i >= 0; i--) {
      if (_controllers[i].text.isNotEmpty) {
        setState(() => _controllers[i].clear());
        _focusNodes[i].requestFocus();
        break;
      }
    }
  }

  // ── SNACKBAR HELPER ───────────────────────────────────────────
  void _showSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
              const Icon(Icons.agriculture, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              "AGRISERVICES",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable top section ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // ── Verify Phone Section ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildVerifyPhoneSection(),
                    ),

                    const SizedBox(height: 20),

                    // ── OTP Input Section ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildOtpInputSection(),
                    ),

                    const SizedBox(height: 16),

                    // ── Resend Section ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildResendSection(),
                    ),

                    const SizedBox(height: 16),

                    // ── Security Info Box ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSecurityInfoBox(),
                    ),

                    const SizedBox(height: 24),

                    // ── Verify Button ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildVerifyButton(),
                    ),

                    const SizedBox(height: 20),

                    // ── Secure Footer ──
                    _buildSecureFooter(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Keypad pinned at bottom ──
            Container(
              color: _cardColor,
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: _buildKeypad(),
            ),
          ],
        ),
      ),
    );
  }

  // ── VERIFY PHONE SECTION ──────────────────────────────────────
  Widget _buildVerifyPhoneSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel("Verify Phone"),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                    text: "Please enter the 4-digit code sent to "),
                TextSpan(
                  text: widget.phoneNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── OTP INPUT SECTION ─────────────────────────────────────────
  Widget _buildOtpInputSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel("Enter OTP"),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
            List.generate(4, (index) => _buildDigitInput(index)),
          ),
        ],
      ),
    );
  }

  // ── SINGLE DIGIT INPUT BOX ────────────────────────────────────
  Widget _buildDigitInput(int index) {
    final bool hasValue = _controllers[index].text.isNotEmpty;
    return Container(
      width: 56,
      height: 60,
      decoration: BoxDecoration(
        color: hasValue
            ? _accentColor.withOpacity(0.06)
            : _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue ? _primaryColor : _borderColor,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        readOnly: true,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: _textPrimary,
          letterSpacing: 1,
        ),
        decoration: InputDecoration(
          counterText: "",
          hintText: "–",
          hintStyle: TextStyle(
            color: _textSecondary.withOpacity(0.35),
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // ── RESEND SECTION ────────────────────────────────────────────
  Widget _buildResendSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.schedule_rounded,
              size: 16, color: _textSecondary),
          const SizedBox(width: 8),
          const Text(
            "Didn't receive the code?",
            style: TextStyle(
              color: _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _canResend ? _resendOtp : null,
            child: Text(
              _canResend ? "Resend OTP" : "Resend in ${_resendSeconds}s",
              style: TextStyle(
                color: _canResend ? _accentColor : _textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECURITY INFO BOX ─────────────────────────────────────────
  Widget _buildSecurityInfoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _successColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _successColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _successColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_user_rounded,
                color: _successColor, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Your verification is secure and encrypted. Do not share your OTP with anyone.",
              style: TextStyle(
                fontSize: 12,
                color: _textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── VERIFY BUTTON ─────────────────────────────────────────────
  Widget _buildVerifyButton() {
    return GestureDetector(
      onTap: _isVerifying ? null : _verifyOtp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color:
          _isVerifying ? _primaryColor.withOpacity(0.7) : _primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isVerifying
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                "Verify & Proceed",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── KEYPAD ────────────────────────────────────────────────────
  Widget _buildKeypad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0'];
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          // ── Backspace key ──
          if (index == 11) {
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _onBackspace,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _errorColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.backspace_outlined,
                      color: _errorColor, size: 20),
                ),
              ),
            );
          }

          String val = keys[index];

          // ── Empty slot ──
          if (val.isEmpty) return const SizedBox.shrink();

          // ── Number key ──
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _onKeypadTap(val),
            child: Center(
              child: Text(
                val,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── SECTION LABEL HELPER (matching PhoneEntryScreen) ──────────
  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: _textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // ── SECURE FOOTER ─────────────────────────────────────────────
  Widget _buildSecureFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF6B7280).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.lock_rounded,
              size: 10, color: Color(0xFF6B7280)),
        ),
        const SizedBox(width: 6),
        const Text(
          "Secure & Encrypted Connection",
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
