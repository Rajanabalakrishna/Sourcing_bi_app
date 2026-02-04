import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mukadam_bi/seeplan/plan_Service_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mukadam_bi/seeplan/plan_service_model.dart';

class VillageExecutionScreen extends StatefulWidget {
  final VillageVisit village;

  const VillageExecutionScreen({super.key, required this.village});

  @override
  State<VillageExecutionScreen> createState() => _VillageExecutionScreenState();
}

class _VillageExecutionScreenState extends State<VillageExecutionScreen> {
  bool _isStarted = false;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final PlanService _planService = PlanService();

  // To store execution data from API
  VillageExecution? _executionData;

  // Dynamic officials list
  late List<String> _activeOfficials;

  // Maps to store data for each official
  final Map<String, TextEditingController> _feedbackControllers = {};
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _phoneControllers = {};
  final Map<String, TextEditingController> _designationControllers = {};
  final Map<String, TextEditingController> _reasonNotMetControllers = {};

  final Map<String, bool> _personMetStatus = {};
  final Map<String, bool> _isSubmitting = {};
  final Map<String, File?> _selectedImages = {};
  final Map<String, Position?> _capturedPositions = {};
  final Map<String, String> _locations = {};

  // Track submitted meetings
  final Map<String, String?> _submittedMeetingIds = {};
  final Map<String, bool> _isOfficialSubmitted = {};

  // Track next available numbers for dynamic additions
  int _nextShopownerNumber = 3;
  int _nextMukkadamNumber = 1;
  int _nextInfluentialPersonNumber = 1;

  @override
  void initState() {
    super.initState();
    _initializeOfficials();
    _checkExecutionStatus();
  }

  Future<void> _checkExecutionStatus() async {
    if (widget.village.status.toLowerCase() == 'in_progress') {
      setState(() => _isStarted = true);
      await _loadExecutionData();
    } else if (widget.village.status.toLowerCase() == 'completed') {
      setState(() => _isStarted = true);
      await _loadExecutionData();
    } else if (widget.village.status.toLowerCase() == 'planned') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showStartDialog());
    }
  }

  Future<void> _loadExecutionData() async {
    setState(() => _isLoading = true);
    try {
      final executionData = await _planService.fetchVillageExecution(widget.village.id);
      if (executionData != null) {
        setState(() {
          _executionData = executionData;
          _populateExistingData();
        });
      }
    } catch (e) {
      debugPrint("Error loading execution data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateExistingData() {
    if (_executionData == null || _executionData!.meetings.isEmpty) return;

    for (var meeting in _executionData!.meetings) {
      String personType = meeting.personType;

      // Mark as submitted
      _isOfficialSubmitted[personType] = true;
      _submittedMeetingIds[personType] = meeting.id;

      // Populate form fields with existing data
      _personMetStatus[personType] = meeting.personMet;

      if (meeting.personMet) {
        _nameControllers[personType]?.text = meeting.personName ?? '';
        _phoneControllers[personType]?.text = meeting.personPhone ?? '';
        _designationControllers[personType]?.text = meeting.personDesignation ?? '';
        _feedbackControllers[personType]?.text = meeting.meetingNotes ?? '';

        if (meeting.meetingLatitude != null && meeting.meetingLongitude != null) {
          _locations[personType] = "Lat: ${meeting.meetingLatitude}, Long: ${meeting.meetingLongitude}";
          _capturedPositions[personType] = Position(
            latitude: meeting.meetingLatitude!,
            longitude: meeting.meetingLongitude!,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      } else {
        _reasonNotMetControllers[personType]?.text = meeting.reasonNotMet ?? '';
        _designationControllers[personType]?.text = meeting.personDesignation ?? '';
      }
    }
  }

  void _initializeOfficials() {
    _activeOfficials = [];

    // Always add mandatory officials first
    const mandatoryOfficials = [
      'shopowner_1_mandatory',
      'shopowner_2_mandatory',
      'hotspot_pickup_dropoff',
      'hotspot_banner_spot',
      'hotspot_wall_painting',
      'village_poc',
    ];

    _activeOfficials.addAll(mandatoryOfficials);

    // Add conditional officials if they're in the API response
    const conditionalOfficials = [
      'sarpanch',
      'secretary',
      'talathi',
      'postman',
    ];

    for (var official in conditionalOfficials) {
      if (widget.village.officialsToMeet.contains(official)) {
        _activeOfficials.add(official);
      }
    }

    // For optional shopowners
    bool hasShopowner3Plus = widget.village.officialsToMeet.any((o) {
      if (!o.startsWith('shopowner_')) return false;
      final numStr = o.replaceAll(RegExp(r'[^0-9]'), '');
      if (numStr.isEmpty) return false;
      return int.parse(numStr) >= 3;
    });

    if (hasShopowner3Plus) {
      _activeOfficials.add('shopowner_3_optional');
      _nextShopownerNumber = 4;
    } else {
      _nextShopownerNumber = 3;
    }

    // Influential Person
    int influentialCount = widget.village.officialsToMeet
        .where((o) => o.contains('influential_person'))
        .length;

    for (int i = 1; i <= influentialCount && i <= 10; i++) {
      _activeOfficials.add('influential_person_$i');
    }
    _nextInfluentialPersonNumber = influentialCount + 1;

    // Mukkadam
    int mukkadamCount = widget.village.officialsToMeet
        .where((o) => o.startsWith('mukkadam_'))
        .length;

    for (int i = 1; i <= mukkadamCount && i <= 10; i++) {
      _activeOfficials.add('mukkadam_$i');
    }
    _nextMukkadamNumber = mukkadamCount + 1;

    // Initialize controllers for all active officials
    for (var official in _activeOfficials) {
      _initializeOfficialControllers(official);
    }
  }

  void _initializeOfficialControllers(String official) {
    _feedbackControllers[official] = TextEditingController();
    _nameControllers[official] = TextEditingController();
    _phoneControllers[official] = TextEditingController();
    _designationControllers[official] = TextEditingController();
    _reasonNotMetControllers[official] = TextEditingController();

    _personMetStatus[official] = true;
    _isSubmitting[official] = false;
    _selectedImages[official] = null;
    _capturedPositions[official] = null;
    _locations[official] = "Not captured";
    _isOfficialSubmitted[official] = false;
    _submittedMeetingIds[official] = null;
  }

  void _addOptionalOfficial(String type) {
    setState(() {
      String newOfficial;
      if (type == 'shopowner') {
        newOfficial = 'shopowner_${_nextShopownerNumber}_optional';
        _nextShopownerNumber++;
      } else if (type == 'mukkadam') {
        newOfficial = 'mukkadam_$_nextMukkadamNumber';
        _nextMukkadamNumber++;
      } else if (type == 'influential_person') {
        newOfficial = 'influential_person_$_nextInfluentialPersonNumber';
        _nextInfluentialPersonNumber++;
      } else {
        return;
      }

      _activeOfficials.add(newOfficial);
      _initializeOfficialControllers(newOfficial);
    });
  }

  void _removeOptionalOfficial(String official) {
    setState(() {
      _activeOfficials.remove(official);
      _feedbackControllers[official]?.dispose();
      _nameControllers[official]?.dispose();
      _phoneControllers[official]?.dispose();
      _designationControllers[official]?.dispose();
      _reasonNotMetControllers[official]?.dispose();

      _feedbackControllers.remove(official);
      _nameControllers.remove(official);
      _phoneControllers.remove(official);
      _designationControllers.remove(official);
      _reasonNotMetControllers.remove(official);
      _personMetStatus.remove(official);
      _isSubmitting.remove(official);
      _selectedImages.remove(official);
      _capturedPositions.remove(official);
      _locations.remove(official);
      _isOfficialSubmitted.remove(official);
      _submittedMeetingIds.remove(official);
    });
  }

  bool _isOfficialMandatory(String official) {
    const mandatory = [
      'shopowner_1_mandatory',
      'shopowner_2_mandatory',
      'hotspot_pickup_dropoff',
      'hotspot_banner_spot',
      'hotspot_wall_painting',
      'village_poc',
    ];
    return mandatory.contains(official);
  }

  bool _isOfficialOptional(String official) {
    if (official.startsWith('influential_person')) return true;
    if (official.contains('optional')) return true;
    if (official.startsWith('shopowner_')) {
      final match = RegExp(r'shopowner_(\d+)').firstMatch(official);
      if (match != null) {
        int num = int.tryParse(match.group(1) ?? '0') ?? 0;
        return num >= 3;
      }
    }
    if (official.startsWith('mukkadam_')) return true;
    return false;
  }

  @override
  void dispose() {
    for (var controller in _feedbackControllers.values) {
      controller.dispose();
    }
    for (var controller in _nameControllers.values) {
      controller.dispose();
    }
    for (var controller in _phoneControllers.values) {
      controller.dispose();
    }
    for (var controller in _designationControllers.values) {
      controller.dispose();
    }
    for (var controller in _reasonNotMetControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showImageSourceActionSheet(String official) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(official, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(official, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(String official, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImages[official] = File(image.path);
      });
    }
  }

  Future<void> _getCurrentLocation(String official) async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _capturedPositions[official] = position;
        _locations[official] =
        "Lat: ${position.latitude.toStringAsFixed(6)}, Long: ${position.longitude.toStringAsFixed(6)}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location captured successfully"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Location Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitOfficialData(String official) async {
    // Validation
    if (_personMetStatus[official]! && _capturedPositions[official] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please capture GPS location first"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting[official] = true);

    try {
      bool met = _personMetStatus[official]!;

      // Prepare meeting data
      Map<String, dynamic> meetingData = {
        "execution_id": _executionData?.id ?? widget.village.id,
        "person_type": official.toLowerCase()
            .replaceAll('_mandatory', '')
            .replaceAll('_optional', ''),
        "person_met": met,
        "person_designation": _designationControllers[official]!.text.trim(),
      };

      if (met) {
        meetingData.addAll({
          "person_name": _nameControllers[official]!.text.trim(),
          "person_phone": _phoneControllers[official]!.text.trim(),
          "meeting_notes": _feedbackControllers[official]!.text.trim(),
          "meeting_latitude": _capturedPositions[official]?.latitude,
          "meeting_longitude": _capturedPositions[official]?.longitude,
        });
      } else {
        meetingData["reason_not_met"] =
            _reasonNotMetControllers[official]!.text.trim();
      }

      // Submit meeting record
      final meetingResult = await _planService.submitMeetingRecord(meetingData);

      if (meetingResult == null) {
        throw Exception("Failed to submit meeting record");
      }

      String meetingId = meetingResult['id'];
      _submittedMeetingIds[official] = meetingId;

      // Upload image if available
      if (_selectedImages[official] != null) {
        String s3ObjectName =
            'meeting_${official}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        String? s3Key = await _planService.uploadFileToS3(
          filePath: _selectedImages[official]!.path,
          s3ObjectName: s3ObjectName,
        );

        if (s3Key != null) {
          // Submit proof image metadata
          await _planService.uploadProofImage({
            "execution_id": _executionData?.id ?? widget.village.id,
            "meeting_id": meetingId,
            "person_type": official.toLowerCase()
                .replaceAll('_mandatory', '')
                .replaceAll('_optional', ''),
            "image_type": "meeting",
            "s3_key": s3Key,
            "latitude": _capturedPositions[official]?.latitude,
            "longitude": _capturedPositions[official]?.longitude,
            "caption": met
                ? "Meeting with ${_nameControllers[official]!.text}"
                : "Location photo for $official"
          });
        }
      }

      setState(() {
        _isOfficialSubmitted[official] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Record submitted successfully"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting[official] = false);
    }
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Start Execution"),
        content: Text(
            "Are you ready to start the visit for ${widget.village.village}? Your current GPS location will be captured automatically."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleStartExecution();
            },
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _handleStartExecution() async {
    setState(() => _isLoading = true);
    try {
      Position pos = await _determinePosition();
      final res = await _planService.startVillageExecution(
          widget.village.id, pos.latitude, pos.longitude);
      if (res != null) {
        setState(() {
          _isStarted = true;
          _executionData = VillageExecution.fromJson(res);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Execution started successfully"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error starting execution: $e"),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadNotesPdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        build: (pw.Context context) =>
            pw.Header(level: 0, text: "Notes: ${widget.village.village}")));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  String _formatOfficialTitle(String official) {
    return official
        .replaceAll('_mandatory', '')
        .replaceAll('_optional', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.village.village),
        actions: [
          if (_isStarted)
            IconButton(
                icon: const Icon(Icons.download),
                onPressed: _downloadNotesPdf)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isStarted
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Click Start to begin execution"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showStartDialog,
              child: const Text("Start"),
            )
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            const Text("Officials Meeting Details",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Render all active officials
            ..._activeOfficials.map((official) =>
                _buildOfficialContainer(official)),

            const SizedBox(height: 20),

            // Add buttons for optional officials
            _buildAddOptionsSection(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: _isStarted
          ? FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.done_all, color: Colors.white),
        label: const Text("Mark Village as Executed",
            style: TextStyle(color: Colors.white)),
      )
          : null,
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.blue.shade100)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.group_add, color: Colors.blue),
              title: const Text("Expected Registrations"),
              subtitle: Text("${widget.village.expectedRegistrations}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            if (_executionData != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text("Total Registrations"),
                subtitle: Text("${_executionData!.totalRegistrations}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddOptionsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.green.shade100)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Optional Officials",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _nextShopownerNumber <= 10
                      ? () => _addOptionalOfficial('shopowner')
                      : null,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text("Add Shopowner $_nextShopownerNumber"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _nextMukkadamNumber <= 10
                      ? () => _addOptionalOfficial('mukkadam')
                      : null,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text("Add Mukkadam $_nextMukkadamNumber"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    foregroundColor: Colors.orange,
                    elevation: 0,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _nextInfluentialPersonNumber <= 10
                      ? () => _addOptionalOfficial('influential_person')
                      : null,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text("Add Influential Person $_nextInfluentialPersonNumber"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade50,
                    foregroundColor: Colors.purple,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialContainer(String official) {
    String officialTitle = _formatOfficialTitle(official);
    bool isMet = _personMetStatus[official] ?? true;
    bool isMandatory = _isOfficialMandatory(official);
    bool isOptional = _isOfficialOptional(official);
    bool isSubmitted = _isOfficialSubmitted[official] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isSubmitted
                ? Colors.green.shade300
                : isMandatory
                ? Colors.red.shade200
                : isOptional
                ? Colors.orange.shade200
                : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text("Official: $officialTitle",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSubmitted
                                      ? Colors.green
                                      : isMandatory
                                      ? Colors.red
                                      : isOptional
                                      ? Colors.orange
                                      : Colors.blue),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 4),
                        if (isSubmitted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, size: 10, color: Colors.green),
                                SizedBox(width: 2),
                                Text("SUBMITTED",
                                    style: TextStyle(fontSize: 8, color: Colors.green)),
                              ],
                            ),
                          ),
                        if (!isSubmitted && isMandatory)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text("MANDATORY",
                                style: TextStyle(fontSize: 8, color: Colors.red)),
                          ),
                        if (!isSubmitted && isOptional)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text("OPTIONAL",
                                style: TextStyle(fontSize: 8, color: Colors.orange)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOptional && !isSubmitted)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                      onPressed: () => _removeOptionalOfficial(official),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 4),
                  const Text("Met?", style: TextStyle(fontSize: 12)),
                  Switch(
                    value: isMet,
                    onChanged: isSubmitted
                        ? null
                        : (val) => setState(() => _personMetStatus[official] = val),
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          if (isMet) ...[
            _buildTextField(
                _nameControllers[official]!, "Person Name", Icons.person,
                enabled: !isSubmitted),
            const SizedBox(height: 10),
            _buildTextField(_phoneControllers[official]!, "Phone Number",
                Icons.phone,
                keyboardType: TextInputType.phone, enabled: !isSubmitted),
          ],
          const SizedBox(height: 10),
          _buildTextField(_designationControllers[official]!, "Designation",
              Icons.badge,
              enabled: !isSubmitted),
          if (!isMet) ...[
            const SizedBox(height: 10),
            _buildTextField(_reasonNotMetControllers[official]!,
                "Reason for not meeting", Icons.warning,
                maxLines: 2, enabled: !isSubmitted),
          ],
          if (isMet) ...[
            const SizedBox(height: 10),
            _buildTextField(_feedbackControllers[official]!, "Meeting Notes",
                Icons.notes,
                maxLines: 2, enabled: !isSubmitted),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: isSubmitted
                      ? null
                      : () => _showImageSourceActionSheet(official),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _selectedImages[official] == null
                        ? Icon(Icons.add_a_photo,
                        color: isSubmitted ? Colors.grey.shade400 : Colors.grey)
                        : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImages[official]!,
                            fit: BoxFit.cover)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isSubmitted
                            ? null
                            : () => _getCurrentLocation(official),
                        icon: const Icon(Icons.location_on, size: 16),
                        label: const Text("Capture GPS",
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      Text(_locations[official] ?? "Not captured",
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (!isSubmitted) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting[official]!
                    ? null
                    : () => _submitOfficialData(official),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSubmitting[official]!
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Text("Done"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1, bool enabled = true}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey.shade100 : null,
      ),
    );
  }
}