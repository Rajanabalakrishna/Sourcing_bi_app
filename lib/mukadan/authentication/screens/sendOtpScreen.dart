import "package:flutter/material.dart";
import "../auth_service/auth_service.dart";
import "verifyOtpScreen.dart";

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  late final TextEditingController _phoneController;
  bool _isLoading = false;

  // ── Professional Color Palette (matching VillagePlansDashboard) ──
  static const Color _primaryColor = Color(0xFF1E3A5F);
  static const Color _accentColor = Color(0xFF3B82F6);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _dividerColor = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

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
        title: const _LogoBrand(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // ── Hero Illustration Card ──
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: _buildHeroIllustration(),
              // ),

              const SizedBox(height: 20),

              // ── Welcome Section ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildWelcomeSection(),
              ),

              const SizedBox(height: 20),

              // ── Phone Input Section ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPhoneInputSection(),
              ),

              const SizedBox(height: 16),

              // ── Security Info Box ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSecurityInfoBox(),
              ),

              const SizedBox(height: 32),

              // ── Submit Button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSubmitButton(),
              ),

              const SizedBox(height: 20),

              // ── Secure Footer ──
              const _SecureFooter(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── HERO ILLUSTRATION ─────────────────────────────────────────


  // ── WELCOME SECTION ───────────────────────────────────────────
  Widget _buildWelcomeSection() {
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
          _buildSectionLabel('Bharat intelligence'),
          const SizedBox(height: 14),
          const Text(
            "Please enter your mobile number to access your government services securely.",
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── PHONE INPUT SECTION ───────────────────────────────────────
  Widget _buildPhoneInputSection() {
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
          _buildSectionLabel('Mobile Number'),
          const SizedBox(height: 14),
          Row(
            children: [
              // ── Country Code ──
              Container(
                width: 90,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderColor, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: "+91",
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: _textSecondary, size: 18),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(value: "+91", child: Text("+91")),
                    ],
                    onChanged: (_) {},
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ── Phone Input ──
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: "0000000000",
                    hintStyle: TextStyle(
                      color: _textSecondary.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                    counterText: "",
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.smartphone_rounded,
                          color: _accentColor, size: 18),
                    ),
                    filled: true,
                    fillColor: _backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: _borderColor, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: _borderColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: _primaryColor, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
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
              "We will send a 4-digit OTP to this number for verification.",
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

  // ── SUBMIT BUTTON ─────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSubmit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isLoading ? _primaryColor.withOpacity(0.7) : _primaryColor,
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
          child: _isLoading
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
              Icon(Icons.send_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                "Send OTP",
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

  // ── SUBMIT HANDLER ────────────────────────────────────────────
  Future<void> _handleSubmit() async {
    final phone = _phoneController.text.trim();

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text("Enter valid 10-digit number",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: _errorColor,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ========== STEP 0: Check if mobile number exists ==========
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text("Checking number...",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: _primaryColor,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );

      final bool exists =
      await OtpApiService.checkMobileExists(phoneNumber: phone);

      if (!exists) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.person_off_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "This mobile number is not registered. Please contact admin.",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: _errorColor,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // ========== STEP 1: Mobile login (number exists) ==========
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text("Verifying number...",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: _primaryColor,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );

      final authResponse =
      await OtpApiService.mobileLogin(phoneNumber: phone);

      // ========== STEP 2: Send OTP ==========
      await OtpApiService.sendOtp(phoneNumber: phone);

      // ========== STEP 3: Navigate to OTP verification screen ==========
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyOtpScreen(
                phoneNumber: phone, authData: authResponse),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.toString().replaceAll("Exception: ", ""),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: _errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── SECTION LABEL HELPER (matching VillagePlansDashboard) ─────
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
}

// ── LOGO BRAND (restyled) ─────────────────────────────────────
class _LogoBrand extends StatelessWidget {
  const _LogoBrand();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
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
    );
  }
}

// ── SECURE FOOTER (restyled) ──────────────────────────────────
class _SecureFooter extends StatelessWidget {
  const _SecureFooter();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [



      ],
    );
  }
}
