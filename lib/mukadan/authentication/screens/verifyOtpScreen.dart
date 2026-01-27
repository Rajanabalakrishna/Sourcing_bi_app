

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
  final String phoneNumber; // This will now be +91XXXXXXXXXX
  final AuthResponse authData;

  const VerifyOtpScreen({super.key, required this.phoneNumber,required this.authData});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());

  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Removed _sendOtp() from here because it was already called in PhoneEntryScreen
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var node in _focusNodes) node.dispose();
    for (var controller in _controllers) controller.dispose();
    super.dispose();
  }


  Future<void> _verifyOtp() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter the complete OTP")));
      return;
    }

    try {
      bool verified = await OtpApiService.verifyOtp(
        phoneNumber: widget.phoneNumber,
        otp: otp,
      );

      if (verified && mounted) {
        // Store login status locally

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

        await prefs.setBool('isLoggedIn', true);



        //
        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(builder: (_) => const MukadamDashboard(),);
        // );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MukadamDashboard()),
              (route) => false, // This removes all previous screens (PhoneEntry and VerifyOtp)
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP resent successfully")));
      _startResendTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

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



  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = const Color(0xFF13EC13);
    final Color textColor = isDark ? Colors.white : const Color(0xFF111811);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            color: isDark ? const Color(0xFF171717) : Colors.white,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text("Verify Phone", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                          children: [
                            const TextSpan(text: "Please enter the 4-digit code sent to\n"),
                            TextSpan(text: widget.phoneNumber, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, height: 1.5)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) => _buildDigitInput(index, primaryColor, textColor)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Didn't receive the code?", style: TextStyle(color: Colors.grey)),
                          TextButton(
                            onPressed: _canResend ? _resendOtp : null,
                            child: Text(_canResend ? "Resend" : "Resend ($_resendSeconds)", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: const Color(0xFF111811),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("Verify & Proceed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildKeypad(textColor),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitInput(int index, Color primary, Color text) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        readOnly: true,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: text),
        decoration: InputDecoration(
          counterText: "",
          hintText: "-",
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 2.5)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary, width: 2.5)),
        ),
      ),
    );
  }

  Widget _buildKeypad(Color textColor) {
    final keys = ['1','2','3','4','5','6','7','8','9','','0'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2),
      itemCount: 12,
      itemBuilder: (context, index) {
        if (index == 11) return IconButton(onPressed: _onBackspace, icon: Icon(Icons.backspace_outlined, color: textColor));
        String val = keys[index];
        return InkWell(
          onTap: val.isEmpty ? null : () => _onKeypadTap(val),
          child: Center(child: Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: textColor))),
        );
      },
    );
  }
}
