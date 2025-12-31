import 'package:flutter/material.dart';
import 'package:mukadam_bi/transport/Transport_provider/transport_model.dart';
import '../../notes/data.dart';
import 'Transport_Service.dart';
// Import your data entry service for locations
// import 'package:mukadam_bi/services/data_entry_service.dart';

class TransportProviderScreen extends StatefulWidget {
  const TransportProviderScreen({super.key});

  @override
  State<TransportProviderScreen> createState() => _TransportProviderScreenState();
}

class _TransportProviderScreenState extends State<TransportProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransportProviderService _service = TransportProviderService();
  final DataEntryService _dataEntryService = DataEntryService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _maxDistanceController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isActive = true;
  bool _isLoadingLocations = false;

  // Location State
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  List<Map<String, dynamic>> _villages = [];

  Map<String, dynamic>? _selectedDistrict;
  Map<String, dynamic>? _selectedTaluka;
  Map<String, dynamic>? _selectedVillage;

  final List<String> _vehicles = ['Truck', 'Van', 'Bike', 'Car'];

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    setState(() => _isLoadingLocations = true);
    try {
      final districts = await _dataEntryService.getDistricts();
      setState(() {
        _districts = districts;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      _showSnackBar("Error loading districts: $e", isError: true);
    }
  }

  Future<void> _loadTalukas(String districtCode) async {
    setState(() {
      _talukas = [];
      _villages = [];
      _selectedTaluka = null;
      _selectedVillage = null;
      _isLoadingLocations = true;
    });
    try {
      final talukas = await _dataEntryService.getTalukas(districtCode);
      setState(() {
        _talukas = talukas;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      _showSnackBar("Error loading talukas: $e", isError: true);
    }
  }

  Future<void> _loadVillages(String talukaCode) async {
    setState(() {
      _villages = [];
      _selectedVillage = null;
      _isLoadingLocations = true;
    });
    try {
      final villages = await _dataEntryService.getVillages(talukaCode);
      setState(() {
        _villages = villages;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      _showSnackBar("Error loading villages: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDistrict == null || _selectedTaluka == null || _selectedVillage == null) {
        _showSnackBar("Please select District, Taluka, and Village", isError: true);
        return;
      }

      final newProvider = TransportProvider(
        name: _nameController.text,
        contactNumber: _contactNumberController.text,
        district: _selectedDistrict!['districtnameenglish'],
        districtCode: _selectedDistrict!['districtcode'].toString(),
        taluka: _selectedTaluka!['subdistrictnameenglish'],
        talukaCode: _selectedTaluka!['subdistrictcode'].toString(),
        village: _selectedVillage!['villagenameenglish'],
        villageCode: _selectedVillage!['villagecode'].toString(),
        maxDistance: int.parse(_maxDistanceController.text),
        vehicleType: _vehicleTypeController.text,
        isActive: _isActive,
        notes: _notesController.text,
      );

      try {
        final createdProvider = await _service.createTransportProvider(newProvider);
        _showSnackBar('Provider "${createdProvider.name}" created successfully!');

        setState(() {
          _nameController.clear();
          _contactNumberController.clear();
          _maxDistanceController.clear();
          _vehicleTypeController.clear();
          _notesController.clear();
          _selectedDistrict = null;
          _selectedTaluka = null;
          _selectedVillage = null;
          _isActive = true;
        });
      } catch (e) {
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNumberController.dispose();
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
        title: const Text('Create New Provider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
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
                    hint: 'e.g. 9999999999',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.isEmpty) ? 'Contact required' : null,
                  ),
                  const SizedBox(height: 20),

                  // Location Dropdowns
                  _buildLocationDropdown(
                    label: 'DISTRICT',
                    value: _selectedDistrict,
                    items: _districts,
                    displayKey: 'districtnameenglish',
                    onChanged: (val) {
                      setState(() => _selectedDistrict = val);
                      if (val != null) _loadTalukas(val['districtcode'].toString());
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLocationDropdown(
                    label: 'TALUKA',
                    value: _selectedTaluka,
                    items: _talukas,
                    displayKey: 'subdistrictnameenglish',
                    onChanged: (val) {
                      setState(() => _selectedTaluka = val);
                      if (val != null) _loadVillages(val['subdistrictcode'].toString());
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLocationDropdown(
                    label: 'VILLAGE',
                    value: _selectedVillage,
                    items: _villages,
                    displayKey: 'villagenameenglish',
                    onChanged: (val) => setState(() => _selectedVillage = val),
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
                      Expanded(child: _buildVehicleDropdown()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildStatusToggle(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _notesController,
                    label: 'ADDITIONAL NOTES',
                    hint: 'Enter any specific requirements...',
                    maxLines: 3,
                  ),
                  if (_isLoadingLocations)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
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
          labelStyle: const TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2),
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey.withOpacity(0.5)) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
        ),
      ),
    );
  }

  Widget _buildLocationDropdown({
    required String label,
    required Map<String, dynamic>? value,
    required List<Map<String, dynamic>> items,
    required String displayKey,
    required void Function(Map<String, dynamic>?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: item,
            child: Text(item[displayKey]?.toString() ?? 'Unknown', style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
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
        value: _vehicleTypeController.text.isEmpty ? null : _vehicleTypeController.text,
        items: _vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (val) => setState(() => _vehicleTypeController.text = val!),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
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
            ),
            child: const Text('Create Provider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
