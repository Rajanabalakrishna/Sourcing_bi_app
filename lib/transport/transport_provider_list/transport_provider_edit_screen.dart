


// File: lib/screens/transport_provider_edit_screen.dart

import 'package:flutter/material.dart';
import '../../mukadam_Screen.dart';
import '../Transport_provider/Transport_Service.dart';
import '../Transport_provider/transport_model.dart';
import 'Transport_provider_edit_service.dart'; // Adjust this import path if necessary
//import '../Transport_provider/transport_provider_service.dart'; // Adjust this import path if necessary

class TransportProviderEditScreen extends StatefulWidget {
  final TransportProvider provider;

  const TransportProviderEditScreen({super.key, required this.provider});

  @override
  State<TransportProviderEditScreen> createState() => _TransportProviderEditScreenState();
}

class _TransportProviderEditScreenState extends State<TransportProviderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactNumberController;
  late TextEditingController _baseLocationController;
  late TextEditingController _maxDistanceController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _notesController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider.name);
    _contactNumberController = TextEditingController(text: widget.provider.contactNumber);
    _baseLocationController = TextEditingController(text: widget.provider.baseLocation);
    _maxDistanceController = TextEditingController(text: widget.provider.maxDistance.toString());
    _vehicleTypeController = TextEditingController(text: widget.provider.vehicleType);
    _notesController = TextEditingController(text: widget.provider.notes);
    _isActive = widget.provider.isActive;
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

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedData = {
        'name': _nameController.text,
        'contact_number': _contactNumberController.text,
        'base_location': _baseLocationController.text,
        'max_distance': int.parse(_maxDistanceController.text),
        'vehicle_type': _vehicleTypeController.text,
        'is_active': _isActive,
        'notes': _notesController.text,
      };

      try {
        await TransportProviderServicee().updateTransportProvider(
          widget.provider.id!, // Assuming id is not null for updates
          updatedData,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transport Provider updated successfully!')),
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MukadamDashboard(),
            ),
          );// Pop with true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update Transport Provider: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transport Provider'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Name', isRequired: true),
              _buildTextField(_contactNumberController, 'Contact Number'),
              _buildTextField(_baseLocationController, 'Base Location', isRequired: true),
              _buildTextField(_maxDistanceController, 'Max Distance (km)', keyboardType: TextInputType.number, isRequired: true),
              _buildTextField(_vehicleTypeController, 'Vehicle Type', isRequired: true),
              _buildTextField(_notesController, 'Notes', maxLines: 3),
              SwitchListTile(
                title: const Text('Is Active'),
                value: _isActive,
                onChanged: (bool value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          if (keyboardType == TextInputType.number) {
            if (value != null && int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
          }
          return null;
        },
      ),
    );
  }
}
