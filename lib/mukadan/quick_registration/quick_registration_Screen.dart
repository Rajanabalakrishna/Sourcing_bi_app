import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mukadam_bi/mukadan/quick_registration/quick_registration_service.dart';

class QuickMukkadamRegistrationScreen extends StatefulWidget {

  const QuickMukkadamRegistrationScreen({super.key});

  @override
  State<QuickMukkadamRegistrationScreen> createState() => _QuickMukkadamRegistrationScreenState();
}

class _QuickMukkadamRegistrationScreenState extends State<QuickMukkadamRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers from your original logic
  final TextEditingController _mukkadamNameController = TextEditingController();
  final TextEditingController _mobileNumbersController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _crewSizeController = TextEditingController();

  bool _isPermanent = false;

  // Auto-filled defaults as per your API specification
  final String _hasSmartphone = 'no';
  final String _transportMode = 'no_vehicle';
  final String _workMode = 'daily_up_down';

  @override
  void dispose() {
    _mukkadamNameController.dispose();
    _mobileNumbersController.dispose();
    _villageController.dispose();
    _crewSizeController.dispose();
    super.dispose();
  }

  void _submitQuickForm() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting Registration...')),
      );

      final Map<String, dynamic> mukkadamData = {
        "mukkadam_name": _mukkadamNameController.text,
        "village": _villageController.text,
        "mobile_numbers": _mobileNumbersController.text,
        "crew_size": _crewSizeController.text,
        "is_permanent": _isPermanent,
        "has_smartphone": _hasSmartphone,
        "transport_mode": _transportMode,
        "work_mode": _workMode,
      };

      final response = await quickRegistrationService().quickRegisterMukkadam(
        mukkadamData: mukkadamData,
      );

      if (mounted) {
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful! ID: ${response['data']['id']}')),
          );
          _mukkadamNameController.clear();
          _mobileNumbersController.clear();
          _villageController.clear();
          _crewSizeController.clear();
          setState(() => _isPermanent = false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response['message']}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      appBar: _buildAppBar(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Profile',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in the details below to register a new Mukkadam quickly.',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildLabel("Mukkadam Name", required: true),
                  _buildTextField(
                    controller: _mukkadamNameController,
                    hint: "John Doe",
                    icon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter name' : null,
                  ),

                  const SizedBox(height: 24),

                  _buildLabel("Mobile Numbers", required: true),
                  _buildTextField(
                    controller: _mobileNumbersController,
                    hint: "9876543210",
                    icon: Icons.phone_iphone_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter mobile number';
                      if (v.length != 10) return 'Enter 10 digits';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  _buildLabel("Village", required: true),
                  _buildTextField(
                    controller: _villageController,
                    hint: "Enter village name",
                    icon: Icons.location_on_outlined,
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter village' : null,
                  ),

                  const SizedBox(height: 24),

                  _buildLabel("Crew Size"),
                  _buildTextField(
                    controller: _crewSizeController,
                    hint: "e.g. 10",
                    icon: Icons.groups_outlined,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),

                  // Modern Checkbox Section
                  _buildCheckboxTile(isDark),

                  const SizedBox(height: 40),

                  // Styled Submit Button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Registration',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: GoogleFonts.inter(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          children: [
            if (required)
              const TextSpan(text: ' *', style: TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
        filled: true,
        fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6A5ACD), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(bool isDark) {
    return InkWell(
      onTap: () => setState(() => _isPermanent = !_isPermanent),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _isPermanent,
                activeColor: const Color(0xFF6A5ACD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                onChanged: (val) => setState(() => _isPermanent = val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Is Permanent", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    "Check if this position is permanent.",
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A5ACD).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitQuickForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A5ACD),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 22),
            SizedBox(width: 10),
            Text(
              'Quick Register Mukkadam',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}