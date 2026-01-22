import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:mukadam_bi/transport/Transport_provider/transport_model.dart';
import '../../notes/data.dart';
import 'Transport_Service.dart';

class TransportProviderScreen extends StatefulWidget {
  const TransportProviderScreen({super.key});

  @override
  State<TransportProviderScreen> createState() => _TransportProviderScreenState();
}

class _TransportProviderScreenState extends State<TransportProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransportProviderService _service = TransportProviderService();
  final DataEntryService _dataEntryService = DataEntryService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _maxDistanceController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _dlNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _voterIdController = TextEditingController();

  // File Paths
  String? _profilePhotoPath;
  String? _aadharCardPath;
  String? _panCardPath;
  String? _voterIdPath;
  String? _dlPath;
  String? _rcPath;

  DateTime? _selectedDob;
  bool _isActive = true;
  bool _isLoadingLocations = false;

  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  List<Map<String, dynamic>> _villages = [];

  Map<String, dynamic>? _selectedState;
  Map<String, dynamic>? _selectedDistrict;
  Map<String, dynamic>? _selectedTaluka;
  Map<String, dynamic>? _selectedVillage;

  final List<String> _vehicles = ['Truck', 'Van', 'Bike', 'Car'];

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNumberController.dispose();
    _maxDistanceController.dispose();
    _vehicleTypeController.dispose();
    _notesController.dispose();
    _capacityController.dispose();
    _vehicleController.dispose();
    _dlNumberController.dispose();
    _dobController.dispose();
    _aadharNumberController.dispose();
    _panNumberController.dispose();
    _voterIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 'profile') _profilePhotoPath = pickedFile.path;
        if (type == 'aadhar') _aadharCardPath = pickedFile.path;
        if (type == 'pan') _panCardPath = pickedFile.path;
        if (type == 'voter') _voterIdPath = pickedFile.path;
        if (type == 'dl') _dlPath = pickedFile.path;
        if (type == 'rc') _rcPath = pickedFile.path;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
      _showSnackBar("Error loading states: $e", isError: true);
    }
  }

  Future<void> _loadDistricts(String stateCode) async {
    setState(() {
      _districts = []; _talukas = []; _villages = [];
      _selectedDistrict = null; _selectedTaluka = null; _selectedVillage = null;
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
      _showSnackBar("Error loading districts: $e", isError: true);
    }
  }

  Future<void> _loadTalukas(String stateCode, String districtCode) async {
    setState(() {
      _talukas = []; _villages = [];
      _selectedTaluka = null; _selectedVillage = null;
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
      _showSnackBar("Error loading talukas: $e", isError: true);
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
      _showSnackBar("Error loading villages: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedState == null || _selectedDistrict == null || _selectedTaluka == null || _selectedVillage == null) {
        _showSnackBar("Please select all location fields", isError: true);
        return;
      }

      setState(() => _isLoadingLocations = true);

      final baseProvider = TransportProvider(
        name: _nameController.text,
        contactNumber: _contactNumberController.text,
        state: _selectedState!['state_name_english'],
        stateCode: _selectedState!['state_code'],
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
        capacity: int.tryParse(_capacityController.text),
        vehicleNumber: _vehicleController.text,
        dlNumber: _dlNumberController.text,
        driverDob: _selectedDob,
        aadharNumber: _aadharNumberController.text,
        panNumber: _panNumberController.text,
        voterId: _voterIdController.text,
      );

      try {
        await _service.createTransportProvider(
          provider: baseProvider,
          profilePath: _profilePhotoPath,
          aadharPath: _aadharCardPath,
          panPath: _panCardPath,
          voterPath: _voterIdPath,
          dlPath: _dlPath,
          rcPath: _rcPath,
        );
        _showSnackBar('Provider created successfully!');
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Error: $e', isError: true);
      } finally {
        setState(() => _isLoadingLocations = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  _buildSectionHeader('BASIC INFORMATION'),
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

                  _buildSectionHeader('LOCATION DETAILS'),
                  _buildSearchableLocationDropdown(
                    label: 'STATE',
                    value: _selectedState,
                    items: _states,
                    displayKey: 'state_name_english',
                    onChanged: (val) {
                      setState(() => _selectedState = val);
                      if (val != null) _loadDistricts(val['state_code']);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildSearchableLocationDropdown(
                    label: 'DISTRICT',
                    value: _selectedDistrict,
                    items: _districts,
                    displayKey: 'districtnameenglish',
                    onChanged: (val) {
                      setState(() => _selectedDistrict = val);
                      if (val != null) _loadTalukas(_selectedState!['state_code'], val['districtcode'].toString());
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildSearchableLocationDropdown(
                    label: 'TALUKA',
                    value: _selectedTaluka,
                    items: _talukas,
                    displayKey: 'subdistrictnameenglish',
                    onChanged: (val) {
                      setState(() => _selectedTaluka = val);
                      if (val != null) _loadVillages(_selectedState!['state_code'], val['subdistrictcode'].toString());
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildSearchableLocationDropdown(
                    label: 'VILLAGE',
                    value: _selectedVillage,
                    items: _villages,
                    displayKey: 'villagenameenglish',
                    onChanged: (val) => setState(() => _selectedVillage = val),
                  ),

                  const SizedBox(height: 20),
                  _buildSectionHeader('VEHICLE & DRIVER DETAILS'),
                  _buildTextField(
                    controller: _capacityController,
                    label: 'CAPACITY',
                    hint: 'Enter capacity',
                    icon: Icons.fitness_center,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Capacity required';
                      if (int.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _vehicleController,
                    label: 'VEHICLE NUMBER',
                    hint: 'e.g. MH 12 AB 1234',
                    icon: Icons.directions_car_filled_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _dlNumberController,
                    label: 'DL NUMBER',
                    hint: 'Enter driving license number',
                    icon: Icons.assignment_ind_outlined,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _dobController,
                        label: 'DRIVER DOB',
                        hint: 'yyyy-MM-dd',
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _maxDistanceController,
                          label: 'MAX DIST (KM)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildVehicleDropdown()),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildSectionHeader('DOCUMENT NUMBERS'),
                  _buildTextField(controller: _aadharNumberController, label: 'AADHAR NUMBER', hint: '12-digit number', icon: Icons.fingerprint),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _panNumberController, label: 'PAN NUMBER', hint: 'Enter PAN', icon: Icons.credit_card),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _voterIdController, label: 'VOTER ID', hint: 'Enter Voter ID', icon: Icons.how_to_vote),

                  const SizedBox(height: 20),
                  _buildSectionHeader('UPLOAD DOCUMENTS'),
                  _buildFilePicker('Profile Photo', _profilePhotoPath, () => _pickImage('profile')),
                  _buildFilePicker('Aadhar Card', _aadharCardPath, () => _pickImage('aadhar')),
                  _buildFilePicker('PAN Card', _panCardPath, () => _pickImage('pan')),
                  _buildFilePicker('Voter ID Card', _voterIdPath, () => _pickImage('voter')),
                  _buildFilePicker('Driving License', _dlPath, () => _pickImage('dl')),
                  _buildFilePicker('RC Book', _rcPath, () => _pickImage('rc')),

                  const SizedBox(height: 20),
                  _buildStatusToggle(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _notesController,
                    label: 'ADDITIONAL NOTES',
                    hint: 'Enter any specific requirements...',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          if (_isLoadingLocations)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED), strokeWidth: 5)),
            ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildFilePicker(String label, String? path, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(path != null ? p.basename(path) : 'No file selected', style: const TextStyle(fontSize: 11)),
        trailing: Icon(path != null ? Icons.check_circle : Icons.upload_file, color: path != null ? Colors.green : const Color(0xFF7C3AED)),
        onTap: onTap,
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

  Widget _buildSearchableLocationDropdown({
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
      child: DropdownSearch<Map<String, dynamic>>(
        items: (filter, loadProps) => items,
        selectedItem: value,
        itemAsString: (item) => item[displayKey]?.toString() ?? '',
        onChanged: onChanged,
        compareFn: (item1, item2) => item1[displayKey] == item2[displayKey],
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            border: InputBorder.none,
          ),
        ),
        popupProps: const PopupProps.menu(showSearchBox: true),
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        decoration: const InputDecoration(
          labelText: 'VEHICLE TYPE',
          labelStyle: TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            onPressed: _isLoadingLocations ? null : _submitForm,
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
