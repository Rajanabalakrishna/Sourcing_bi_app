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
  static const Color primaryColor = Color(0xFF13EC13);
  static const Color textMuted = Color(0xFF618961);
  static const Color bgColor = Color(0xFFF6F8F6);

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
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: Colors.black87),
        title: const _LogoBrand(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const _HeroIllustration(),
              const SizedBox(height: 32),
              const Text(
                "Welcome, Farmer.",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please enter your mobile number to access your government services securely.",
                style: TextStyle(color: textMuted, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _PhoneInputForm(controller: _phoneController),
              const SizedBox(height: 24),
              const _SecurityInfoBox(),
              const SizedBox(height: 40),
              _SubmitButton(phoneController: _phoneController),
              const SizedBox(height: 24),
              const _SecureFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoBrand extends StatelessWidget {
  const _LogoBrand();
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.agriculture, color: Color(0xFF13EC13)),
        SizedBox(width: 8),
        Text("AGRISERVICES", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF618961))),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/company.jpeg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _PhoneInputForm extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneInputForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: DropdownButtonFormField(
            value: "+91",
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            items: const [DropdownMenuItem(value: "+91", child: Text("+91"))],
            onChanged: (_) {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              hintText: "0000000000",
              counterText: "",
              suffixIcon: const Icon(Icons.smartphone, color: Color(0xFF13EC13)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityInfoBox extends StatelessWidget {
  const _SecurityInfoBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF13EC13).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: const Row(
        children: [
          Icon(Icons.verified_user, color: Color(0xFF13EC13)),
          SizedBox(width: 8),
          Expanded(child: Text("We will send a 4-digit OTP to this number", style: TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final TextEditingController phoneController;
  const _SubmitButton({required this.phoneController});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF13EC13),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () async {
          final phone = phoneController.text.trim();

          if (phone.length != 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Enter valid 10-digit number")),
            );
            return;
          }

          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Verifying number..."), duration: Duration(seconds: 1)),
            );

            // 1. Check if number exists and store token globally
            await OtpApiService.mobileLogin(phoneNumber: phone);

            // 2. Send OTP
            await OtpApiService.sendOtp(phoneNumber: phone);

            if (context.mounted) {
              // 3. Navigate to verify page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VerifyOtpScreen(phoneNumber: phone),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
              );
            }
          }
        },
        child: const SizedBox(
          height: 56,
          width: double.infinity,
          child: Center(
            child: Text(
              "Send OTP",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecureFooter extends StatelessWidget {
  const _SecureFooter();
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock, size: 12, color: Color(0xFF618961)),
        SizedBox(width: 4),
        Text("Secure & Encrypted Connection", style: TextStyle(fontSize: 11, color: Color(0xFF618961))),
      ],
    );
  }
}
