import 'package:flutter/material.dart';
import 'package:mukadam_bi/transport/Transport_provider/transport_model.dart';
import 'Transport_Service.dart'; // Assuming this file contains TransportProviderService

class TransportProviderScreen extends StatefulWidget {
  const TransportProviderScreen({super.key});

  @override
  State<TransportProviderScreen> createState() => _TransportProviderScreenState();
}

class _TransportProviderScreenState extends State<TransportProviderScreen> {
  // Logic & State
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _baseLocationController = TextEditingController();
  final TextEditingController _maxDistanceController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isActive = true;

  String? _message;
  String? _error;
  final TransportProviderService _service = TransportProviderService();
  final List<String> _vehicles = ['Truck', 'Van', 'Bike', 'Car'];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _message = null;
        _error = null;
      });

      final newProvider = TransportProvider(
        name: _nameController.text,
        contactNumber: _contactNumberController.text,
        baseLocation: _baseLocationController.text,
        maxDistance: int.parse(_maxDistanceController.text),
        vehicleType: _vehicleTypeController.text,
        isActive: _isActive,
        notes: _notesController.text,
      );

      try {
        final createdProvider = await _service.createTransportProvider(newProvider);
        setState(() {
          _message = 'Provider "${createdProvider.name}" created successfully!';
          _nameController.clear();
          _contactNumberController.clear();
          _baseLocationController.clear();
          _maxDistanceController.clear();
          _vehicleTypeController.clear();
          _notesController.clear();
          _isActive = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_message!), backgroundColor: Colors.green),
        );
      } catch (e) {
        setState(() {
          _error = 'Error: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNumberController.dispose();
    _baseLocationController.dispose();
    _maxDistanceController.dispose();
    _vehicleTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create New Provider',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
              height: 1,
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow Decoration
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withOpacity(0.05),
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'PROVIDER NAME',
                    hint: 'Enter full name',
                    icon: Icons.badge_outlined,
                    validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _contactNumberController,
                    label: 'CONTACT NUMBER',
                    hint: 'e.g. +1 234 567 890',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.isEmpty) ? 'Contact required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _baseLocationController,
                    label: 'BASE LOCATION',
                    hint: 'City, State',
                    icon: Icons.place_outlined,
                    validator: (v) => (v == null || v.isEmpty) ? 'Location required' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _maxDistanceController,
                          label: 'MAX DIST (KM)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (int.tryParse(v) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildStatusToggle(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _notesController,
                    label: 'ADDITIONAL NOTES',
                    hint: 'Enter any specific requirements...',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  // --- UI Component Builders ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: TextStyle(color: const Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2),
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey.withOpacity(0.5)) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonFormField<String>(
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: 'VEHICLE TYPE',
          labelStyle: const TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
        ),
        hint: const Text("Type", style: TextStyle(fontSize: 14)),
        value: _vehicleTypeController.text.isEmpty ? null : _vehicleTypeController.text,
        items: _vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (val) => setState(() => _vehicleTypeController.text = val!),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isActive = !_isActive),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user_rounded, color: Color(0xFF7C3AED), size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Provider is ready for orders', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Switch.adaptive(
              value: _isActive,
              activeColor: const Color(0xFF7C3AED),
              onChanged: (val) => setState(() => _isActive = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 8,
              shadowColor: const Color(0xFF7C3AED).withOpacity(0.4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded),
                SizedBox(width: 8),
                Text('Create Provider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
