import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mukadam_bi/mukadan/quick_registration/quick_registration_service.dart';
import 'package:provider/provider.dart';

import '../../notes/data.dart';
import '../authentication/userProvider.dart';

class QuickMukkadamRegistrationScreen extends StatefulWidget {
  const QuickMukkadamRegistrationScreen({super.key});

  @override
  State<QuickMukkadamRegistrationScreen> createState() => _QuickMukkadamRegistrationScreenState();
}

class _QuickMukkadamRegistrationScreenState extends State<QuickMukkadamRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final DataEntryService _dataEntryService = DataEntryService();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _mukkadamNameController = TextEditingController();
  final TextEditingController _mobileNumbersController = TextEditingController();
  final TextEditingController _crewSizeController = TextEditingController();
  final TextEditingController _maxCrewCapacityController = TextEditingController();

  // Alternative Contact Controllers
  final TextEditingController _altContact1NameController = TextEditingController();
  final TextEditingController _altPhone1Controller = TextEditingController();
  final TextEditingController _altContact2NameController = TextEditingController();
  final TextEditingController _altPhone2Controller = TextEditingController();

  // Availability Controllers
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Location Controllers
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  // ID Number Controllers
  final TextEditingController _aadharNumberController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _voterIdNumberController = TextEditingController();

  // Rate Card Controllers
  final TextEditingController aprilPruningController = TextEditingController();
  final TextEditingController bagalBaliFutRemovalController = TextEditingController();
  final TextEditingController berryThinningController = TextEditingController();
  final TextEditingController bunchSelectionController = TextEditingController();
  final TextEditingController bunchThinningController = TextEditingController();
  final TextEditingController bunchTyingController = TextEditingController();
  final TextEditingController bunchVariationController = TextEditingController();
  final TextEditingController defaultRateController = TextEditingController();
  final TextEditingController failFutRemovalController = TextEditingController();
  final TextEditingController fingerThinningController = TextEditingController();
  final TextEditingController firstDippingController = TextEditingController();
  final TextEditingController firstFailFutRemovalController = TextEditingController();
  final TextEditingController harvestingController = TextEditingController();
  final TextEditingController newPlantationController = TextEditingController();
  final TextEditingController otherRateController = TextEditingController();
  final TextEditingController paperRemovalController = TextEditingController();
  final TextEditingController paperWrappingController = TextEditingController();
  final TextEditingController pastingController = TextEditingController();
  final TextEditingController pruningController = TextEditingController();
  final TextEditingController secondDippingController = TextEditingController();
  final TextEditingController secondFailFutRemovalController = TextEditingController();
  final TextEditingController shendaToppingController = TextEditingController();
  final TextEditingController shootTyingController = TextEditingController();
  final TextEditingController shootTyingClipsController = TextEditingController();
  final TextEditingController shootTyingStringsController = TextEditingController();
  final TextEditingController thirdDippingController = TextEditingController();

  File? _selectedImage; // Location capture photo
  File? _profilePhoto;
  File? _aadharCardPhoto;
  File? _panCardPhoto;
  File? _bankProofPhoto;

  bool _isPermanent = false;
  bool _isLoadingLocations = false;
  String _smartphoneAvailability = 'yes';
  String _transportMode = 'own_bike';

  // Notification preferences
  bool _whatsappNotification = false;
  bool _smsNotification = false;
  bool _callNotification = false;

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

  // --- Location Permission & Service Check ---
  Future<bool> _checkLocationPermissionsAndService() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          await _showLocationServiceDialog();
        }
        return false;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showSnackBar('Location permissions are denied. Please enable location permissions.');
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          await _showPermissionSettingsDialog();
        }
        return false;
      }

      return true;
    } catch (e) {
      _showSnackBar('Error checking location permissions: $e');
      return false;
    }
  }

  // --- Location Logic ---
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocations = true);
    try {
      Position position = await _determinePosition();
      setState(() {
        _latController.text = position.latitude.toString();
        _longController.text = position.longitude.toString();
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      _showSnackBar(e.toString());
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        await _showLocationServiceDialog();
      }
      return Future.error('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showSnackBar('Location permissions are denied. Please enable location permissions.');
        }
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        await _showPermissionSettingsDialog();
      }
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _showLocationServiceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Service Required'),
          content: const Text('Location services are required to capture GPS coordinates with photos. Please enable location services to continue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5ACD),
                foregroundColor: Colors.white,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionSettingsDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'Location permission is required to capture GPS coordinates with photos. Please enable it from app settings to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5ACD),
                foregroundColor: Colors.white,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // --- Image Picker Logic with Location Check ---
  Future<void> _showImagePickerOptionsWithLocationCheck() async {
    // First check location permissions and service
    bool hasLocationAccess = await _checkLocationPermissionsAndService();

    if (!hasLocationAccess) {
      _showSnackBar('Location access is required to capture photos with GPS coordinates');
      return;
    }

    // If location is available, show image picker options
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      // Automatically get location after capturing/selecting image
      await _getCurrentLocation();
    }
  }

  // --- Document Image Picker (No location check needed) ---
  Future<void> _pickDocumentImage(ImageSource source, String documentType) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        switch (documentType) {
          case 'profile':
            _profilePhoto = File(image.path);
            break;
          case 'aadhar':
            _aadharCardPhoto = File(image.path);
            break;
          case 'pan':
            _panCardPhoto = File(image.path);
            break;
          case 'bank':
            _bankProofPhoto = File(image.path);
            break;
        }
      });
    }
  }

  void _showDocumentPickerOptions(String documentType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickDocumentImage(ImageSource.camera, documentType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickDocumentImage(ImageSource.gallery, documentType);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Date Picker Logic
  Future<void> _selectStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _endDateController.text = picked.toIso8601String().split('T')[0];
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _submitQuickForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedState == null || _selectedDistrict == null || _selectedTaluka == null || _selectedVillage == null) {
        _showSnackBar("Please select State, District, Taluka, and Village");
        return;
      }

      // Validate profile photo (mandatory)
      if (_profilePhoto == null) {
        _showSnackBar("Profile photo is mandatory");
        return;
      }

      setState(() => _isLoadingLocations = true);

      final Map<String, dynamic> mukkadamData = {
        "mukkadam_name": _mukkadamNameController.text,
        "mobile_numbers": _mobileNumbersController.text,
        "crew_size": _crewSizeController.text,
        "max_crew_capacity": _maxCrewCapacityController.text,

        // Alternative contacts with names
        "alternative_contact_1_name": _altContact1NameController.text,
        "alternative_mobile_1": _altPhone1Controller.text,
        "alternative_contact_2_name": _altContact2NameController.text,
        "alternative_mobile_2": _altPhone2Controller.text,

        "start_date": _startDateController.text,
        "end_date": _endDateController.text,
        "current_latitude": _latController.text,
        "current_longitude": _longController.text,
        "has_smartphone": _smartphoneAvailability,
        "is_permanent": _isPermanent,
        "transport_mode": _transportMode,

        // Notification preferences object
        "notification_preferences": {
          "whatsapp": _whatsappNotification,
          "sms": _smsNotification,
          "call": _callNotification,
        },

        "aadhar_number": _aadharNumberController.text,
        "pan_number": _panNumberController.text,
        "voter_id_number": _voterIdNumberController.text,
        "state": _selectedState!['state_name_english'],
        "state_code": _selectedState!['state_code'],
        "district": _selectedDistrict!['districtnameenglish'],
        "district_code": _selectedDistrict!['districtcode'].toString(),
        "taluka": _selectedTaluka!['subdistrictnameenglish'],
        "taluka_code": _selectedTaluka!['subdistrictcode'].toString(),
        "village": _selectedVillage!['villagenameenglish'],
        "village_code": _selectedVillage!['villagecode'].toString(),

        // Rate card as nested object matching backend structure
        "rate_card": {
          "pruning_activities": {
            "pruning": pruningController.text,
            "april_pruning": aprilPruningController.text,
            "pasting": pastingController.text,
            "fail_fut_removal": failFutRemovalController.text,
            "first_fail_fut_removal": firstFailFutRemovalController.text,
            "second_fail_fut_removal": secondFailFutRemovalController.text,
            "bagal_bali_fut_removal": bagalBaliFutRemovalController.text,
          },
          "dipping_activities": {
            "first_dipping": firstDippingController.text,
            "second_dipping": secondDippingController.text,
            "third_dipping": thirdDippingController.text,
          },
          "shoot_tying": {
            "shoot_tying_strings": shootTyingStringsController.text,
            "shoot_tying_clips": shootTyingClipsController.text,
          },
          "thinning_activities": {
            "bunch_thinning": bunchThinningController.text,
            "finger_thinning": fingerThinningController.text,
            "berry_thinning": berryThinningController.text,
          },
          "bunch_management": {
            "bunch_selection": bunchSelectionController.text,
            "bunch_tying": bunchTyingController.text,
            "bunch_variation": bunchVariationController.text,
          },
          "other_activities": {
            "shenda_topping": shendaToppingController.text,
            "paper_wrapping": paperWrappingController.text,
            "paper_removal": paperRemovalController.text,
            "harvesting": harvestingController.text,
            "new_plantation": newPlantationController.text,
          },
        },
      };

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? authToken = userProvider.token;

      if (authToken == null) {
        setState(() => _isLoadingLocations = false);
        _showSnackBar("Session expired. Please login again.");
        return;
      }


      // Call the service with file paths
      final response = await quickRegistrationService().quickRegisterMukkadam(
        mukkadamData: mukkadamData,
        profilePhotoPath: _profilePhoto?.path,
        aadharCardPath: _aadharCardPhoto?.path,
        panCardPath: _panCardPhoto?.path,
        bankProofPath: _bankProofPhoto?.path,
        locationCapturePath: _selectedImage?.path,
        authToken: authToken,
      );

      setState(() => _isLoadingLocations = false);

      if (mounted) {
        if (response['success']) {
          _showSnackBar("Registration successful!");
          Navigator.pop(context);
        } else {
          final message = response['message'] ?? 'Registration failed';
          _showSnackBar("Failed: $message");

          // Handle logout if token expired
          if (response['logout_required'] == true) {
            // Add your logout logic here
            // Navigator.pushReplacementNamed(context, '/login');
          }
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
                  _buildSectionHeader("1. Basic Details / मूलभूत माहिती"),
                  const SizedBox(height: 15),
                  _buildLabel("Name of Mukkadam", required: true),
                  _buildTextField(
                    controller: _mukkadamNameController,
                    hint: "Enter Name",
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Mobile Number(s)", required: true),
                  _buildTextField(
                    controller: _mobileNumbersController,
                    hint: "10 Digit Mobile",
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.length != 10) ? 'Invalid Mobile' : null,
                  ),
                  const SizedBox(height: 30),

                  _buildSectionHeader("2. Location Details / स्थान माहिती"),
                  const SizedBox(height: 15),
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
                  _buildLabel("Village / Residence", required: true),
                  _buildSearchableDropdown(
                    value: _selectedVillage,
                    items: _villages,
                    displayKey: 'villagenameenglish',
                    hint: "Select Village",
                    icon: Icons.location_on,
                    onChanged: (val) => setState(() => _selectedVillage = val),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionHeader("3. Smartphone Availability *"),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'yes',
                        groupValue: _smartphoneAvailability,
                        activeColor: const Color(0xFF6A5ACD),
                        onChanged: (val) => setState(() => _smartphoneAvailability = val!),
                      ),
                      const Text("Yes"),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: 'no',
                        groupValue: _smartphoneAvailability,
                        activeColor: const Color(0xFF6A5ACD),
                        onChanged: (val) => setState(() => _smartphoneAvailability = val!),
                      ),
                      const Text("No"),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildSectionHeader("4. Crew Details / टोळी माहिती"),
                  const SizedBox(height: 15),
                  _buildLabel("Current Crew Size", required: true),
                  _buildTextField(
                    controller: _crewSizeController,
                    hint: "e.g. 15",
                    icon: Icons.groups,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Maximum Crew Capacity"),
                  _buildTextField(
                    controller: _maxCrewCapacityController,
                    hint: "Enter capacity",
                    icon: Icons.group_add,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Updated Alternative Contact Section
                  _buildLabel("Alternate Contact 1"),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _altContact1NameController,
                          hint: "Contact Name",
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _altPhone1Controller,
                          hint: "Phone Number",
                          icon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildLabel("Alternate Contact 2"),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _altContact2NameController,
                          hint: "Contact Name",
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _altPhone2Controller,
                          hint: "Phone Number",
                          icon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildSectionHeader("5. Availability / उपलब्धता"),
                  const SizedBox(height: 15),
                  _buildLabel("Availability Period (Start to End)"),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectStartDate,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: _startDateController,
                              hint: "Start Date",
                              icon: Icons.calendar_today,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectEndDate,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: _endDateController,
                              hint: "End Date",
                              icon: Icons.calendar_today,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text("Is Permanent", style: TextStyle(fontWeight: FontWeight.w600)),
                    value: _isPermanent,
                    activeColor: const Color(0xFF6A5ACD),
                    onChanged: (val) => setState(() => _isPermanent = val!),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 30),

                  _buildSectionHeader("6. Location & Photo Capture / स्थान आणि फोटो"),
                  const SizedBox(height: 15),
                  _buildLabel("Current Coordinates (Auto-captured with photo)"),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _latController,
                          hint: "Latitude",
                          icon: Icons.location_searching,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _longController,
                          hint: "Longitude",
                          icon: Icons.location_searching,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Capture Photo (GPS location will be auto-captured)"),
                  GestureDetector(
                    onTap: _showImagePickerOptionsWithLocationCheck,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: _selectedImage == null
                          ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Click to select image", style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 4),
                          Text("(Location permission required)", style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionHeader("7. Transport Mode / वाहतूक साधन *"),
                  const SizedBox(height: 15),
                  _buildTransportModeSection(),
                  const SizedBox(height: 30),

                  _buildSectionHeader("8. Notifications / सूचना"),
                  const SizedBox(height: 15),
                  _buildNotificationsSection(),
                  const SizedBox(height: 30),

                  _buildSectionHeader("9. Documents & ID (Optional) / कागदपत्रे आणि ओळखपत्र"),
                  const SizedBox(height: 15),
                  _buildDocumentsSection(),
                  const SizedBox(height: 30),

                  _buildSectionHeader("10. Rate Card / दर कार्ड"),
                  const SizedBox(height: 15),
                  _buildRateCardStepperSection(),
                  const SizedBox(height: 30),

                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6A5ACD),
        ),
      ),
    );
  }

  Widget _buildTransportModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String>(
          title: const Text('Own Bike'),
          value: 'own_bike',
          groupValue: _transportMode,
          activeColor: const Color(0xFF6A5ACD),
          onChanged: (val) => setState(() => _transportMode = val!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: const Text('Own Pickup'),
          value: 'own_pickup',
          groupValue: _transportMode,
          activeColor: const Color(0xFF6A5ACD),
          onChanged: (val) => setState(() => _transportMode = val!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: const Text('No Vehicle'),
          value: 'no_vehicle',
          groupValue: _transportMode,
          activeColor: const Color(0xFF6A5ACD),
          onChanged: (val) => setState(() => _transportMode = val!),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('WhatsApp'),
          value: _whatsappNotification,
          activeColor: const Color(0xFF6A5ACD),
          onChanged: (val) => setState(() => _whatsappNotification = val!),
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('SMS'),
          value: _smsNotification,
          activeColor: const Color(0xFF6A5ACD),
          onChanged: (val) => setState(() => _smsNotification = val!),
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Call'),
          value: _callNotification,
          activeColor: const Color(0xFF6A5ACD),
          onChanged: (val) => setState(() => _callNotification = val!),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Photo (Mandatory)
        _buildLabel("Profile Photo *", required: true),
        const SizedBox(height: 8),
        _buildDocumentUploadRow('Profile Photo', 'profile', _profilePhoto),
        const SizedBox(height: 20),

        // Voter Details
        Text(
          'Voter Details',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _voterIdNumberController,
          hint: "Voter ID Number",
          icon: Icons.how_to_vote,
        ),
        const SizedBox(height: 20),

        // Aadhar Details
        Text(
          'Aadhar Details',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _aadharNumberController,
          hint: "Aadhar Number",
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '- OR -',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildDocumentUploadRow('Aadhar Card', 'aadhar', _aadharCardPhoto),
        const SizedBox(height: 20),

        // PAN Details
        Text(
          'PAN Details',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _panNumberController,
          hint: "PAN Number",
          icon: Icons.credit_card,
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '- OR -',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildDocumentUploadRow('PAN Card', 'pan', _panCardPhoto),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDocumentUploadRow(String label, String documentType, File? file) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showDocumentPickerOptions(documentType),
            icon: const Icon(Icons.upload_file),
            label: Text(file == null ? 'Upload $label' : '$label Uploaded ✓'),
            style: ElevatedButton.styleFrom(
              backgroundColor: file == null ? const Color(0xFF6A5ACD) : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: () => _pickDocumentImage(ImageSource.camera, documentType),
          icon: const Icon(Icons.camera_alt),
          tooltip: 'Capture $label',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF6A5ACD).withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildRateCardStepperSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          'Rate Card Details',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6A5ACD),
          ),
        ),
        subtitle: const Text('दर कार्ड तपशील - Click to expand'),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTwoFieldRow(defaultRateController, 'Default Rate', pruningController, 'Pruning'),
                _buildTwoFieldRow(aprilPruningController, 'April Pruning', pastingController, 'Pasting'),
                _buildTwoFieldRow(failFutRemovalController, 'Fail Fut Removal', firstFailFutRemovalController, '1st Fail Fut Rem'),
                _buildTwoFieldRow(secondFailFutRemovalController, '2nd Fail Fut Rem', bagalBaliFutRemovalController, 'Bagal Bali Fut'),
                _buildTwoFieldRow(firstDippingController, '1st Dipping', secondDippingController, '2nd Dipping'),
                _buildTwoFieldRow(thirdDippingController, '3rd Dipping', shootTyingController, 'Shoot Tying'),
                _buildTwoFieldRow(shootTyingStringsController, 'Shoot Tying (Strings)', shootTyingClipsController, 'Shoot Tying (Clips)'),
                _buildTwoFieldRow(bunchThinningController, 'Bunch Thinning', fingerThinningController, 'Finger Thinning'),
                _buildTwoFieldRow(berryThinningController, 'Berry Thinning', bunchSelectionController, 'Bunch Selection'),
                _buildTwoFieldRow(bunchTyingController, 'Bunch Tying', bunchVariationController, 'Bunch Variation'),
                _buildTwoFieldRow(shendaToppingController, 'Shenda Topping', paperWrappingController, 'Paper Wrapping'),
                _buildTwoFieldRow(paperRemovalController, 'Paper Removal', harvestingController, 'Harvesting'),
                _buildTwoFieldRow(newPlantationController, 'New Plantation', otherRateController, 'Other'),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildTwoFieldRow(TextEditingController c1, String l1, TextEditingController c2, String l2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildRateField(c1, l1)),
          const SizedBox(width: 12),
          Expanded(child: _buildRateField(c2, l2)),
        ],
      ),
    );
  }

  Widget _buildRateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
      keyboardType: TextInputType.number,
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
}