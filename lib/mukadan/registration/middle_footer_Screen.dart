

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../notes/data.dart';

class LocationIssuesSection extends StatelessWidget {
  final List<Map<String, dynamic>> states;
  final List<Map<String, dynamic>> districts;
  final List<Map<String, dynamic>> talukas;
  final List<Map<String, dynamic>> villages;
  final String? selectedStateCode;
  final String? selectedDistrictCode;
  final String? selectedTalukaCode;
  final String? selectedVillageCode;
  final String? issueSeverity;
  final TextEditingController reasonController;
  final Function(Map<String, dynamic>?) onStateChanged;
  final Function(Map<String, dynamic>?) onDistrictChanged;
  final Function(Map<String, dynamic>?) onTalukaChanged;
  final Function(Map<String, dynamic>?) onVillageChanged;
  final ValueChanged<String?> onIssueSeverityChanged;
  final List<Map<String, dynamic>> currentList;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  final bool isLoading;

  const LocationIssuesSection({
    super.key,
    required this.states,
    required this.districts,
    required this.talukas,
    required this.villages,
    this.selectedStateCode,
    this.selectedDistrictCode,
    this.selectedTalukaCode,
    this.selectedVillageCode,
    this.issueSeverity,
    required this.reasonController,
    required this.onStateChanged,
    required this.onDistrictChanged,
    required this.onTalukaChanged,
    required this.onVillageChanged,
    required this.onIssueSeverityChanged,
    required this.currentList,
    required this.onAdd,
    required this.onRemove,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentList.isNotEmpty) ...[
            const Text("Reported Issues:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            ...currentList.asMap().entries.map((entry) {
              final item = entry.value;
              return Card(
                child: ListTile(
                  title: Text("${item['reason']} (${item['severity']})"),
                  subtitle: Text(
                      "${item['state']} (${item['state_code']}) > ${item['district']} (${item['district_code']}) > ${item['taluka']} (${item['taluka_code']}) > ${item['village']} (${item['village_code']})"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onRemove(entry.key),
                  ),
                ),
              );
            }),
            const Divider(height: 30),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Add New Location Issue:",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
              if (isLoading)
                const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 10),

          _buildSearchableLocationRow(context, "State", states, 'state_code', 'state_name_english', selectedStateCode, onStateChanged, enabled: !isLoading),
          const SizedBox(height: 10),

          _buildSearchableLocationRow(context, "District", districts, 'districtcode', 'districtnameenglish', selectedDistrictCode,
              onDistrictChanged, enabled: !isLoading && selectedStateCode != null),
          const SizedBox(height: 10),

          _buildSearchableLocationRow(context, "Taluka", talukas, 'subdistrictcode', 'subdistrictnameenglish', selectedTalukaCode,
              onTalukaChanged, enabled: !isLoading && selectedDistrictCode != null),
          const SizedBox(height: 10),

          _buildSearchableLocationRow(context, "Village", villages, 'villagecode', 'villagenameenglish', selectedVillageCode,
              onVillageChanged, enabled: !isLoading && selectedTalukaCode != null),

          const SizedBox(height: 10),
          TextFormField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: 'Issue Reason', border: OutlineInputBorder(), isDense: true),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: issueSeverity,
            decoration: const InputDecoration(labelText: 'Issue Severity', border: OutlineInputBorder(), isDense: true),
            items: const ['Low', 'Medium', 'High'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: onIssueSeverityChanged,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onAdd,
              icon: const Icon(Icons.add_alert),
              label: const Text("Add Issue to List"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchableLocationRow(
      BuildContext context,
      String label,
      List<Map<String, dynamic>> items,
      String codeKey,
      String nameKey,
      String? selectedValue,
      Function(Map<String, dynamic>?) onChanged, {
        bool enabled = true,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, dynamic>? selectedItem;
    try {
      selectedItem = items.firstWhere((i) => i[codeKey].toString() == selectedValue);
    } catch (_) {
      selectedItem = null;
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownSearch<Map<String, dynamic>>(
            enabled: enabled,
            items: (filter, loadProps) => items,
            selectedItem: selectedItem,
            itemAsString: (item) => item[nameKey]?.toString() ?? '',
            onChanged: onChanged,
            compareFn: (item1, item2) => item1[codeKey].toString() == item2[codeKey].toString(),
            filterFn: (item, filter) => item[nameKey].toString().toLowerCase().contains(filter.toLowerCase()),
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: "Select $label",
                filled: true,
                fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                isDense: true,
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search $label...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              menuProps: MenuProps(
                backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFormField(
            key: ValueKey(selectedValue),
            initialValue: selectedValue ?? '',
            readOnly: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: "Code",
              border: const OutlineInputBorder(),
              fillColor: Colors.grey[100],
              isDense: true,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}



class WorkAreaPreferenceSection extends StatefulWidget {
  final TextEditingController homeLocationController;
  final List<Map<String, dynamic>> preferredWorkLocations; // Array for multiple locations
  final TextEditingController maxTravelDistanceController; // Single text field
  final List<Map<String, dynamic>> workHistory;
  final List<Map<String, dynamic>> locationIssues;

  const WorkAreaPreferenceSection({
    super.key,
    required this.homeLocationController,
    required this.preferredWorkLocations,
    required this.maxTravelDistanceController,
    required this.workHistory,
    required this.locationIssues,
  });

  @override
  State<WorkAreaPreferenceSection> createState() => _WorkAreaPreferenceSectionState();
}

class _WorkAreaPreferenceSectionState extends State<WorkAreaPreferenceSection> {
  final DataEntryService _dataEntryService = DataEntryService();

  // Dropdown Data Lists
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  List<Map<String, dynamic>> _villages = [];

  // Current Selections
  Map<String, dynamic>? _selectedState;
  Map<String, dynamic>? _selectedDistrict;
  Map<String, dynamic>? _selectedTaluka;
  Map<String, dynamic>? _selectedVillage;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    try {
      final states = await _dataEntryService.getStates();
      setState(() => _states = states);
    } catch (e) {
      debugPrint("Error loading states: $e");
    }
  }

  Future<void> _loadDistricts(String stateCode) async {
    setState(() => _isLoading = true);
    try {
      final districts = await _dataEntryService.getDistricts(stateCode);
      setState(() {
        _districts = districts;
        _talukas = [];
        _villages = [];
        _selectedDistrict = null;
        _selectedTaluka = null;
        _selectedVillage = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTalukas(String stateCode, String districtCode) async {
    setState(() => _isLoading = true);
    try {
      final talukas = await _dataEntryService.getTalukas(stateCode, districtCode);
      setState(() {
        _talukas = talukas;
        _villages = [];
        _selectedTaluka = null;
        _selectedVillage = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadVillages(String stateCode, String talukaCode) async {
    setState(() => _isLoading = true);
    try {
      final villages = await _dataEntryService.getVillages(stateCode, talukaCode);
      setState(() {
        _villages = villages;
        _selectedVillage = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addPreferredLocation() {
    if (_selectedState == null || _selectedDistrict == null || _selectedTaluka == null || _selectedVillage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select State, District, Taluka, and Village")),
      );
      return;
    }

    final newItem = {
      "state": _selectedState!['state_name_english'],
      "state_code": _selectedState!['state_code'].toString(),
      "district": _selectedDistrict!['districtnameenglish'],
      "district_code": _selectedDistrict!['districtcode'].toString(),
      "taluka": _selectedTaluka!['subdistrictnameenglish'],
      "taluka_code": _selectedTaluka!['subdistrictcode'].toString(),
      "village": _selectedVillage!['villagenameenglish'],
      "village_code": _selectedVillage!['villagecode'].toString(),
    };

    setState(() {
      widget.preferredWorkLocations.add(newItem);
      // Reset dropdowns for next entry
      _selectedState = null;
      _selectedDistrict = null;
      _selectedTaluka = null;
      _selectedVillage = null;
      _districts = [];
      _talukas = [];
      _villages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Home Location
          TextFormField(
            controller: widget.homeLocationController,
            decoration: const InputDecoration(
              labelText: 'Home Location',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 15),

          // Max Travel Distance (Single Controller)
          TextFormField(
            controller: widget.maxTravelDistanceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Max Travel Distance (km)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 25),

          const Text("Add Preferred Work Locations",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
          const Divider(),

          // State Search + Code
          _buildSearchRow("State", _states, 'state_code', 'state_name_english', _selectedState, (val) {
            setState(() => _selectedState = val);
            if (val != null) _loadDistricts(val['state_code'].toString());
          }),
          const SizedBox(height: 10),

          // District Search + Code
          _buildSearchRow("District", _districts, 'districtcode', 'districtnameenglish', _selectedDistrict, (val) {
            setState(() => _selectedDistrict = val);
            if (val != null && _selectedState != null) {
              _loadTalukas(_selectedState!['state_code'].toString(), val['districtcode'].toString());
            }
          }, enabled: _selectedState != null),
          const SizedBox(height: 10),

          // Taluka Search + Code
          _buildSearchRow("Taluka", _talukas, 'subdistrictcode', 'subdistrictnameenglish', _selectedTaluka, (val) {
            setState(() => _selectedTaluka = val);
            if (val != null && _selectedState != null) {
              _loadVillages(_selectedState!['state_code'].toString(), val['subdistrictcode'].toString());
            }
          }, enabled: _selectedDistrict != null),
          const SizedBox(height: 10),

          // Village Search + Code
          _buildSearchRow("Village", _villages, 'villagecode', 'villagenameenglish', _selectedVillage, (val) {
            setState(() => _selectedVillage = val);
          }, enabled: _selectedTaluka != null),

          if (_isLoading) const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: LinearProgressIndicator()),

          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _addPreferredLocation,
              icon: const Icon(Icons.add_location_alt),
              label: const Text("Add to Preferred Locations Array"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50),
            ),
          ),

          const SizedBox(height: 20),
          _buildPreferredLocationsList(),
        ],
      ),
    );
  }

  Widget _buildSearchRow(
      String label,
      List<Map<String, dynamic>> items,
      String codeKey,
      String nameKey,
      Map<String, dynamic>? selectedItem,
      Function(Map<String, dynamic>?) onChanged, {
        bool enabled = true,
      }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownSearch<Map<String, dynamic>>(
            enabled: enabled,
            items: (filter, loadProps) => items,
            selectedItem: selectedItem,
            itemAsString: (item) => item[nameKey]?.toString() ?? '',
            onChanged: onChanged,
            compareFn: (i1, i2) => i1[codeKey].toString() == i2[codeKey].toString(),
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: "Select $label",
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
            popupProps: const PopupProps.menu(showSearchBox: true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFormField(
            key: ValueKey(selectedItem?[codeKey]),
            initialValue: selectedItem?[codeKey]?.toString() ?? '',
            readOnly: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: "Code",
              filled: true,
              fillColor: Colors.grey[100],
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferredLocationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Added Preferred Locations Array:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        if (widget.preferredWorkLocations.isEmpty)
          const Text("No locations added", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.preferredWorkLocations.length,
          itemBuilder: (context, index) {
            final item = widget.preferredWorkLocations[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                dense: true,
                title: Text("${item['village']}, ${item['taluka']}"),
                subtitle: Text("${item['district']}, ${item['state']} (Codes: ${item['state_code']}, ${item['village_code']})"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => widget.preferredWorkLocations.removeAt(index)),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class TransportDetailsSection extends StatelessWidget {
  final String? transportMode;
  final ValueChanged<String?> onTransportModeChanged;
  final TextEditingController perKmChargeController;
  final TextEditingController dailyRateChargeController;
  final TextEditingController bikeBeyondKmController;
  final TextEditingController freeFromDateController;
  final TextEditingController bikeChargePerBikeController;
  final TextEditingController pickupChargeDetailsController;
  final TextEditingController currentlyStationedAtController;
  final VoidCallback onSelectFreeDate;
  final bool includesFuel;
  final ValueChanged<bool?> onIncludesFuelChanged;

  const TransportDetailsSection({
    super.key,
    required this.transportMode,
    required this.onTransportModeChanged,
    required this.perKmChargeController,
    required this.dailyRateChargeController,
    required this.bikeBeyondKmController,
    required this.freeFromDateController,
    required this.bikeChargePerBikeController,
    required this.pickupChargeDetailsController,
    required this.currentlyStationedAtController,
    required this.onSelectFreeDate,
    required this.includesFuel,
    required this.onIncludesFuelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: transportMode,
            decoration: const InputDecoration(labelText: 'Transport Mode', border: OutlineInputBorder()),
            items: const <String>['No_vehicle', 'own_bike', 'own_pickup']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onTransportModeChanged,
          ),
          const SizedBox(height: 10),

          // Show Charges only if NOT No_vehicle
          if (transportMode != 'No_vehicle' && transportMode != null) ...[

          // Fields for own_bike
          if (transportMode == 'own_bike') ...[
            TextFormField(
              controller: bikeBeyondKmController,
              decoration: const InputDecoration(labelText: 'Bike Beyond KM', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: bikeChargePerBikeController,
              decoration: const InputDecoration(labelText: 'Bike Charge Per Bike', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
          ],

          // Fields for own_pickup
          if (transportMode == 'own_pickup') ...[
            TextFormField(
              controller: pickupChargeDetailsController,
              decoration: const InputDecoration(labelText: 'Pickup Charge Details', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
          ],

          // Common fields for both own_bike and own_pickup
          if (transportMode == 'own_bike' || transportMode == 'own_pickup') ...[
            TextFormField(
              controller: freeFromDateController,
              readOnly: true,
              onTap: onSelectFreeDate,
              decoration: const InputDecoration(labelText: 'Free From Date', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: currentlyStationedAtController,
              decoration: const InputDecoration(labelText: 'Currently Stationed At', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
          ],
        ],
    ]
      ),
    );
  }
}








class PaymentDetailsSection extends StatelessWidget {
  final Map<String, bool> paymentModes;
  final Function(String, bool) onModeChanged;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final TextEditingController ifscCodeController;
  final TextEditingController upiIdController;
  final String? paymentFrequency;
  final ValueChanged<String?> onPaymentFrequencyChanged;
  final bool advanceRequired;
  final ValueChanged<bool?> onAdvanceRequiredChanged;

  const PaymentDetailsSection({
    super.key,
    required this.paymentModes,
    required this.onModeChanged,
    required this.bankNameController,
    required this.accountNumberController,
    required this.ifscCodeController,
    required this.upiIdController,
    required this.paymentFrequency,
    required this.onPaymentFrequencyChanged,
    required this.advanceRequired,
    required this.onAdvanceRequiredChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select Payment Modes", style: TextStyle(fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: const Text("UPI"),
            value: paymentModes['upi'],
            onChanged: (val) => onModeChanged('upi', val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text("Bank Transfer"),
            value: paymentModes['bank'],
            onChanged: (val) => onModeChanged('bank', val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text("Cash"),
            value: paymentModes['cash'],
            onChanged: (val) => onModeChanged('cash', val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),

          const SizedBox(height: 10),

          // UPI Field
          if (paymentModes['upi'] == true) ...[
            TextFormField(
              controller: upiIdController,
              decoration: const InputDecoration(labelText: 'UPI ID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
          ],

          // Bank Fields
          if (paymentModes['bank'] == true) ...[
            TextFormField(
              controller: bankNameController,
              decoration: const InputDecoration(labelText: 'Bank Name / Branch', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: accountNumberController,
              decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: ifscCodeController,
              decoration: const InputDecoration(labelText: 'IFSC Code', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
          ],

          DropdownButtonFormField<String>(
            value: paymentFrequency,
            decoration: const InputDecoration(labelText: 'Payment Frequency', border: OutlineInputBorder()),
            items: const <String>['weekly', 'monthly', 'daily', 'per_project']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onPaymentFrequencyChanged,
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            title: const Text('Advance Required'),
            value: advanceRequired,
            onChanged: onAdvanceRequiredChanged,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}







class WorkModeSection extends StatelessWidget {
  final String? workMode;
  final ValueChanged<String?> onWorkModeChanged;
  final TextEditingController moveInPreferredRegionController;

  const WorkModeSection({
    super.key,
    required this.workMode,
    required this.onWorkModeChanged,
    required this.moveInPreferredRegionController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: workMode,
            decoration: const InputDecoration(labelText: 'Work Mode', border: OutlineInputBorder()),
            items: const <String>['move_in', 'daily_up_down']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onWorkModeChanged,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: moveInPreferredRegionController,
            decoration: const InputDecoration(labelText: 'Move-in Preferred Region', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}

class ReferralSection extends StatelessWidget {
  final List<dynamic> referralOptions;
  final dynamic selectedReferral;
  final ValueChanged<dynamic> onReferralChanged;
  final TextEditingController referredByController;
  final TextEditingController referralSourceTextController;

  const ReferralSection({
    super.key,
    required this.referralOptions,
    required this.selectedReferral,
    required this.onReferralChanged,
    required this.referredByController,
    required this.referralSourceTextController,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the currently selected value actually exists in the options list
    // This prevents "assertion failed" errors if the list changes
    final bool isValueInOptions = referralOptions.contains(selectedReferral);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<dynamic>(
            // Use null if the selected value isn't in the current list
            value: isValueInOptions ? selectedReferral : null,
            hint: Text(referralOptions.isEmpty
                ? "Loading referral sources..."
                : "Select Referral Source"),
            decoration: const InputDecoration(
                labelText: 'Referral Source',
                border: OutlineInputBorder()
            ),
            // Map the items, ensuring each 'item' is used as the value
            items: referralOptions.map<DropdownMenuItem<dynamic>>((dynamic item) {
              return DropdownMenuItem<dynamic>(
                value: item,
                child: Text(item['mukkadam_name']?.toString() ?? 'Unknown'),
              );
            }).toList(),
            // If the list is empty, onChanged will be null, disabling the dropdown
            // We ensure it only works when data is present
            onChanged: referralOptions.isEmpty ? null : onReferralChanged,
            isExpanded: true, // Ensures the dropdown takes full width and is easier to click
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: referredByController,
            decoration: const InputDecoration(
                labelText: 'Referred By (Mukkadam ID)',
                border: OutlineInputBorder()
            ),
            keyboardType: TextInputType.number,
            readOnly: true,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: referralSourceTextController,
            decoration: const InputDecoration(
                labelText: 'Referral Source Text',
                border: OutlineInputBorder()
            ),
          ),
        ],
      ),
    );
  }
}



class NotificationPreferencesSection extends StatelessWidget {
  final bool whatsappNotifications;
  final ValueChanged<bool?> onWhatsappNotificationsChanged;
  final bool smsNotifications;
  final ValueChanged<bool?> onSmsNotificationsChanged;
  final bool callNotifications;
  final ValueChanged<bool?> onCallNotificationsChanged;
  final TextEditingController preferredTimeController;
  final TextEditingController languageController;

  const NotificationPreferencesSection({
    super.key,
    required this.whatsappNotifications,
    required this.onWhatsappNotificationsChanged,
    required this.smsNotifications,
    required this.onSmsNotificationsChanged,
    required this.callNotifications,
    required this.onCallNotificationsChanged,
    required this.preferredTimeController,
    required this.languageController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: whatsappNotifications,
                onChanged: onWhatsappNotificationsChanged,
              ),
              const Text('WhatsApp'),
              Checkbox(
                value: smsNotifications,
                onChanged: onSmsNotificationsChanged,
              ),
              const Text('SMS'),
              Checkbox(
                value: callNotifications,
                onChanged: onCallNotificationsChanged,
              ),
              const Text('Call'),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: preferredTimeController,
            decoration: const InputDecoration(labelText: 'Preferred Time for Notifications', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: languageController,
            decoration: const InputDecoration(labelText: 'Notification Language', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}


class CaptureLocationSection extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final VoidCallback onFetchLocation;
  final VoidCallback onCapturePhoto;
  final String? capturedImagePath;

  const CaptureLocationSection({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    required this.onFetchLocation,
    required this.onCapturePhoto,
    this.capturedImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onFetchLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Fetch GPS'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: onCapturePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Photo'),
              ),
            ],
          ),
          if (capturedImagePath != null) ...[
            const SizedBox(height: 10),
            Text(
              'Photo captured: ${capturedImagePath!.split('/').last}',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}


class OtherInfoSection extends StatelessWidget {
  final TextEditingController otherCommitmentsController;

  const OtherInfoSection({
    super.key,
    required this.otherCommitmentsController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: otherCommitmentsController,
            decoration: const InputDecoration(labelText: 'Other Commitments', border: OutlineInputBorder()),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}


class IDNumbersSection extends StatelessWidget {
  final TextEditingController aadharNumberController;
  final TextEditingController panNumberController;
  final TextEditingController voterIdNumberController; // Add this

  const IDNumbersSection({
    super.key,
    required this.aadharNumberController,
    required this.panNumberController,
    required this.voterIdNumberController, // Add this
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: aadharNumberController,
            decoration: const InputDecoration(labelText: 'Aadhar Number', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: panNumberController,
            decoration: const InputDecoration(labelText: 'PAN Number', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          // Added Voter ID Field
          TextFormField(
            controller: voterIdNumberController,
            decoration: const InputDecoration(labelText: 'Voter ID Number', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}


class FileUploadsSection extends StatelessWidget {
  final VoidCallback onUploadProfilePhoto;
  final VoidCallback onCaptureProfilePhoto;
  final VoidCallback onUploadAadharCard;
  final VoidCallback onCaptureAadharCard;
  final VoidCallback onUploadPanCard;
  final VoidCallback onCapturePanCard;
  final VoidCallback onUploadBankProof;
  final VoidCallback onCaptureBankProof;

  const FileUploadsSection({
    super.key,
    required this.onUploadProfilePhoto,
    required this.onCaptureProfilePhoto,
    required this.onUploadAadharCard,
    required this.onCaptureAadharCard,
    required this.onUploadPanCard,
    required this.onCapturePanCard,
    required this.onUploadBankProof,
    required this.onCaptureBankProof,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUploadRow('Profile Photo', onUploadProfilePhoto, onCaptureProfilePhoto),
          const SizedBox(height: 10),
          _buildUploadRow('Aadhar Card', onUploadAadharCard, onCaptureAadharCard),
          const SizedBox(height: 10),
          _buildUploadRow('PAN Card', onUploadPanCard, onCapturePanCard),
          const SizedBox(height: 10),
          _buildUploadRow('Bank Proof', onUploadBankProof, onCaptureBankProof),
        ],
      ),
    );
  }

  Widget _buildUploadRow(String label, VoidCallback onUpload, VoidCallback onCapture) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file),
            label: Text('Upload $label'),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onCapture,
          icon: const Icon(Icons.camera_alt),
          tooltip: 'Capture $label',
        ),
      ],
    );
  }


}






