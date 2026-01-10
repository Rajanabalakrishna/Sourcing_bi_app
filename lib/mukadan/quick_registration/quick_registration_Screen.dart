import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:mukadam_bi/mukadan/quick_registration/quick_registration_service.dart';

import '../../notes/data.dart';

// Assuming DataEntryService is imported correctly based on your project structure
// import 'package:mukadam_bi/services/data_entry_service.dart';

class QuickMukkadamRegistrationScreen extends StatefulWidget {
  const QuickMukkadamRegistrationScreen({super.key});

  @override
  State<QuickMukkadamRegistrationScreen> createState() => _QuickMukkadamRegistrationScreenState();
}

class _QuickMukkadamRegistrationScreenState extends State<QuickMukkadamRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final DataEntryService _dataEntryService = DataEntryService();

  final TextEditingController _mukkadamNameController = TextEditingController();
  final TextEditingController _mobileNumbersController = TextEditingController();
  final TextEditingController _crewSizeController = TextEditingController();

  bool _isPermanent = false;
  bool _isLoadingLocations = false;

  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  List<Map<String, dynamic>> _villages = [];

  Map<String, dynamic>? _selectedState;
  Map<String, dynamic>? _selectedDistrict;
  Map<String, dynamic>? _selectedTaluka;
  Map<String, dynamic>? _selectedVillage;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    setState(() => _isLoadingLocations = true);
    try {
      final states = await _dataEntryService.getStates();
      setState(() {
        _states = states;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      _showSnackBar("Error loading states: $e");
    }
  }

  Future<void> _loadDistricts(String stateCode) async {
    setState(() {
      _districts = [];
      _talukas = [];
      _villages = [];
      _selectedDistrict = null;
      _selectedTaluka = null;
      _selectedVillage = null;
      _isLoadingLocations = true;
    });
    try {
      final districts = await _dataEntryService.getDistricts(stateCode);
      setState(() {
        _districts = districts;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      _showSnackBar("Error loading districts: $e");
    }
  }

  Future<void> _loadTalukas(String stateCode, String districtCode) async {
    setState(() {
      _talukas = [];
      _villages = [];
      _selectedTaluka = null;
      _selectedVillage = null;
      _isLoadingLocations = true;
    });
    try {
      final talukas = await _dataEntryService.getTalukas(stateCode, districtCode);
      setState(() {
        _talukas = talukas;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      _showSnackBar("Error loading talukas: $e");
    }
  }

  Future<void> _loadVillages(String stateCode, String talukaCode) async {
    setState(() {
      _villages = [];
      _selectedVillage = null;
      _isLoadingLocations = true;
    });
    try {
      final villages = await _dataEntryService.getVillages(stateCode, talukaCode);
      setState(() {
        _villages = villages;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      _showSnackBar("Error loading villages: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _submitQuickForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedState == null || _selectedDistrict == null || _selectedTaluka == null || _selectedVillage == null) {
        _showSnackBar("Please select State, District, Taluka, and Village");
        return;
      }

      setState(() => _isLoadingLocations = true); // Using the same loader for submission

      final Map<String, dynamic> mukkadamData = {
        "mukkadam_name": _mukkadamNameController.text,
        "mobile_numbers": _mobileNumbersController.text,
        "crew_size": _crewSizeController.text,
        "is_permanent": _isPermanent,
        "state": _selectedState!['state_name_english'],
        "state_code": _selectedState!['state_code'],
        "district": _selectedDistrict!['districtnameenglish'],
        "district_code": _selectedDistrict!['districtcode'].toString(),
        "taluka": _selectedTaluka!['subdistrictnameenglish'],
        "taluka_code": _selectedTaluka!['subdistrictcode'].toString(),
        "village": _selectedVillage!['villagenameenglish'],
        "village_code": _selectedVillage!['villagecode'].toString(),
      };

      final response = await quickRegistrationService().quickRegisterMukkadam(
        mukkadamData: mukkadamData,
      );

      setState(() => _isLoadingLocations = false);

      if (mounted) {
        if (response['success']) {
          _showSnackBar("Registration successful!");
          Navigator.pop(context);
        } else {
          _showSnackBar("Failed: ${response['message']}");
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Mukkadam Name", required: true),
                  _buildTextField(
                    controller: _mukkadamNameController,
                    hint: "Enter Name",
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Mobile Number", required: true),
                  _buildTextField(
                    controller: _mobileNumbersController,
                    hint: "10 Digit Mobile",
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.length != 10) ? 'Invalid Mobile' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("State", required: true),
                  _buildSearchableDropdown(
                    value: _selectedState,
                    items: _states,
                    displayKey: 'state_name_english',
                    hint: "Select State",
                    icon: Icons.public,
                    onChanged: (val) {
                      setState(() => _selectedState = val);
                      if (val != null) _loadDistricts(val['state_code']);
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("District", required: true),
                  _buildSearchableDropdown(
                    value: _selectedDistrict,
                    items: _districts,
                    displayKey: 'districtnameenglish',
                    hint: "Select District",
                    icon: Icons.map,
                    onChanged: (val) {
                      setState(() => _selectedDistrict = val);
                      if (val != null) _loadTalukas(_selectedState!['state_code'], val['districtcode'].toString());
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Taluka", required: true),
                  _buildSearchableDropdown(
                    value: _selectedTaluka,
                    items: _talukas,
                    displayKey: 'subdistrictnameenglish',
                    hint: "Select Taluka",
                    icon: Icons.location_city,
                    onChanged: (val) {
                      setState(() => _selectedTaluka = val);
                      if (val != null) _loadVillages(_selectedState!['state_code'], val['subdistrictcode'].toString());
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Village", required: true),
                  _buildSearchableDropdown(
                    value: _selectedVillage,
                    items: _villages,
                    displayKey: 'villagenameenglish',
                    hint: "Select Village",
                    icon: Icons.location_on,
                    onChanged: (val) => setState(() => _selectedVillage = val),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Crew Size", required: true),
                  _buildTextField(
                    controller: _crewSizeController,
                    hint: "e.g. 15",
                    icon: Icons.groups,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Crew size is required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildCheckboxTile(isDark),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          // Loading Indicator Overlay
          if (_isLoadingLocations)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6A5ACD),
                  strokeWidth: 5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      title: const Text('Quick Registration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      centerTitle: true,
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      elevation: 0,
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: GoogleFonts.inter(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w600),
          children: [if (required) const TextSpan(text: ' *', style: TextStyle(color: Colors.redAccent))],
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required Map<String, dynamic>? value,
    required List<Map<String, dynamic>> items,
    required String displayKey,
    required String hint,
    required IconData icon,
    required void Function(Map<String, dynamic>?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownSearch<Map<String, dynamic>>(
      items: (filter, loadProps) => items,
      selectedItem: value,
      itemAsString: (item) => item[displayKey]?.toString() ?? '',
      onChanged: onChanged,
      compareFn: (item1, item2) => item1[displayKey] == item2[displayKey],
      filterFn: (item, filter) => item[displayKey].toString().toLowerCase().contains(filter.toLowerCase()),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          hintText: hint,
          filled: true,
          fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        menuProps: MenuProps(
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        ),
      ),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildCheckboxTile(bool isDark) {
    return CheckboxListTile(
      title: const Text("Is Permanent", style: TextStyle(fontWeight: FontWeight.w600)),
      value: _isPermanent,
      activeColor: const Color(0xFF6A5ACD),
      onChanged: (val) => setState(() => _isPermanent = val!),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoadingLocations ? null : _submitQuickForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A5ACD),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.grey,
        ),
        child: const Text('Register Mukkadam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
