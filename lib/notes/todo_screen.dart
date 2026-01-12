import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mukadam_bi/mukadam_Screen.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'data.dart';

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final DataEntryService _apiService = DataEntryService();

  final Map<String, String> _selectedStates = {};
  final Map<String, String> _selectedDistricts = {};
  final Map<String, String> _selectedTalukas = {};
  final Map<String, String> _selectedVillages = {};

  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  List<Map<String, dynamic>> _villages = [];

  bool _isLoading = false;
  DateTime selectedDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _expectedRegistrations=TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getStates();
      setState(() => _states = data);
    } catch (e) {
      _showError("Error loading states: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Helper to handle State changes from Multi-Select Dropdown
  void _handleStateSelection(List<Map<String, dynamic>> selectedItems) async {
    final newCodes = selectedItems
        .map((e) => e['state_code'].toString())
        .toSet();
    final oldCodes = _selectedStates.keys.toSet();

    // Added states
    for (var item in selectedItems) {
      final code = item['state_code'].toString();
      if (!oldCodes.contains(code)) {
        await _onStateToggled(code, item['state_name_english'], true);
      }
    }

    // Removed states
    for (var code in oldCodes) {
      if (!newCodes.contains(code)) {
        await _onStateToggled(code, '', false);
      }
    }
  }

  // Helper to handle District changes
  void _handleDistrictSelection(
    List<Map<String, dynamic>> selectedItems,
  ) async {
    final newCodes = selectedItems
        .map((e) => e['districtcode'].toString())
        .toSet();
    final oldCodes = _selectedDistricts.keys.toSet();

    for (var item in selectedItems) {
      final code = item['districtcode'].toString();
      if (!oldCodes.contains(code)) {
        await _onDistrictToggled(code, item['districtnameenglish'], true);
      }
    }

    for (var code in oldCodes) {
      if (!newCodes.contains(code)) {
        await _onDistrictToggled(code, '', false);
      }
    }
  }

  // Helper to handle Taluka changes
  void _handleTalukaSelection(List<Map<String, dynamic>> selectedItems) async {
    final newCodes = selectedItems
        .map((e) => e['subdistrictcode'].toString())
        .toSet();
    final oldCodes = _selectedTalukas.keys.toSet();

    for (var item in selectedItems) {
      final code = item['subdistrictcode'].toString();
      if (!oldCodes.contains(code)) {
        await _onTalukaToggled(code, item['subdistrictnameenglish'], true);
      }
    }

    for (var code in oldCodes) {
      if (!newCodes.contains(code)) {
        await _onTalukaToggled(code, '', false);
      }
    }
  }

  Future<void> _onStateToggled(String code, String name, bool? checked) async {
    if (checked == true) {
      setState(() {
        _selectedStates[code] = name;
        _isLoading = true;
      });
      try {
        final newDistricts = await _apiService.getDistricts(code);
        setState(() {
          for (var d in newDistricts) {
            d['parent_state_code'] = code;
            if (!_districts.any(
              (ex) =>
                  ex['districtcode'].toString() == d['districtcode'].toString(),
            )) {
              _districts.add(d);
            }
          }
        });
      } catch (e) {
        _showError(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() {
        _selectedStates.remove(code);
        _districts.removeWhere((d) => d['parent_state_code'] == code);
        _selectedDistricts.removeWhere(
          (k, v) => !_districts.any((d) => d['districtcode'].toString() == k),
        );
        _talukas.removeWhere((t) => t['parent_state_code'] == code);
        _selectedTalukas.removeWhere(
          (k, v) => !_talukas.any((t) => t['subdistrictcode'].toString() == k),
        );
        _villages.removeWhere((v) => v['parent_state_code'] == code);
        _selectedVillages.removeWhere(
          (k, v) => !_villages.any((vi) => vi['villagecode'].toString() == k),
        );
      });
    }
  }

  Future<void> _onDistrictToggled(
    String code,
    String name,
    bool? checked,
  ) async {
    if (checked == true) {
      final district = _districts.firstWhere(
        (d) => d['districtcode'].toString() == code,
      );
      final stateCode = district['parent_state_code'];
      setState(() {
        _selectedDistricts[code] = name;
        _isLoading = true;
      });
      try {
        final newTalukas = await _apiService.getTalukas(stateCode, code);
        setState(() {
          for (var t in newTalukas) {
            t['parent_state_code'] = stateCode;
            t['parent_district_code'] = code;
            if (!_talukas.any(
              (ex) =>
                  ex['subdistrictcode'].toString() ==
                  t['subdistrictcode'].toString(),
            )) {
              _talukas.add(t);
            }
          }
        });
      } catch (e) {
        _showError(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() {
        _selectedDistricts.remove(code);
        _talukas.removeWhere((t) => t['parent_district_code'] == code);
        _selectedTalukas.removeWhere(
          (k, v) => !_talukas.any((t) => t['subdistrictcode'].toString() == k),
        );
        _villages.removeWhere((v) => v['parent_district_code'] == code);
        _selectedVillages.removeWhere(
          (k, v) => !_villages.any((vi) => vi['villagecode'].toString() == k),
        );
      });
    }
  }

  Future<void> _onTalukaToggled(String code, String name, bool? checked) async {
    if (checked == true) {
      final taluka = _talukas.firstWhere(
        (t) => t['subdistrictcode'].toString() == code,
      );
      final stateCode = taluka['parent_state_code'];
      setState(() {
        _selectedTalukas[code] = name;
        _isLoading = true;
      });
      try {
        final newVillages = await _apiService.getVillages(stateCode, code);
        setState(() {
          for (var v in newVillages) {
            v['parent_state_code'] = stateCode;
            v['parent_taluka_code'] = code;
            if (!_villages.any(
              (ex) =>
                  ex['villagecode'].toString() == v['villagecode'].toString(),
            )) {
              _villages.add(v);
            }
          }
        });
      } catch (e) {
        _showError(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() {
        _selectedTalukas.remove(code);
        _villages.removeWhere((v) => v['parent_taluka_code'] == code);
        _selectedVillages.removeWhere(
          (k, v) => !_villages.any((vi) => vi['villagecode'].toString() == k),
        );
      });
    }
  }

  Future<void> _handleSave() async {
    if (_selectedVillages.isEmpty) {
      _showError("Please select at least one village");
      return;
    }

    setState(() => _isLoading = true);

    // final payload = {
    //   "user_id":5,
    //   "states": _selectedStates.entries
    //       .map((e) => {"name": e.value, "code": e.key})
    //       .toList(),
    //   "districts": _selectedDistricts.entries
    //       .map((e) => {"name": e.value, "code": e.key})
    //       .toList(),
    //   "talukas": _selectedTalukas.entries
    //       .map((e) => {"name": e.value, "code": e.key})
    //       .toList(),
    //   "villages": _selectedVillages.entries
    //       .map((e) => {"name": e.value, "code": e.key})
    //       .toList(),
    //   "planned_date": DateFormat('yyyy-MM-dd').format(selectedDate),
    //   "purpose": _notesController.text.isEmpty
    //       ? "Multi-village visit"
    //       : _notesController.text,
    //   "expected_registrations": 15,
    //   "officials_to_meet": [1, 2],
    //   "status": "planned",
    // };
    
    final prefs=await SharedPreferences.getInstance();
    final userId=prefs.getInt('bg_user_id')??0;




    final payload = {
      "user_id": userId,
      "locations": _selectedVillages.entries.map((entry) {
        final vCode = entry.key;
        final vName = entry.value;

        // Find the village object to retrieve parent hierarchy codes
        final vData = _villages.firstWhere(
              (v) => v['villagecode'].toString() == vCode,
        );

        final tCode = vData['parent_taluka_code'].toString();
        final dCode = vData['parent_district_code'].toString();
        final sCode = vData['parent_state_code'].toString();

        return {
          "state_code": sCode,
          "state_name": _selectedStates[sCode],
          "district_code": dCode,
          "district_name": _selectedDistricts[dCode],
          "taluka_code": tCode,
          "taluka_name": _selectedTalukas[tCode],
          "village_code": vCode,
          "village_name": vName,
        };
      }).toList(),
      "planned_date": DateFormat('yyyy-MM-dd').format(selectedDate),
      "purpose": _notesController.text.isEmpty
          ? "Multi-village visit"
          : _notesController.text,
      "expected_registrations": _expectedRegistrations.text,
    };


    try {
      await _apiService.createVisitPlan(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Visit Plan Saved Successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MukadamDashboard()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Plan Visit",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,

      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(color: Colors.green),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLabel("States"),
                _buildSearchableCheckboxDropdown(
                  label: "State",
                  items: _states,
                  codeKey: 'state_code',
                  nameKey: 'state_name_english',
                  selectionMap: _selectedStates,
                  onChanged: _handleStateSelection,
                ),
                const SizedBox(height: 20),
                _buildLabel("Districts"),
                _buildSearchableCheckboxDropdown(
                  label: "District",
                  items: _districts,
                  codeKey: 'districtcode',
                  nameKey: 'districtnameenglish',
                  selectionMap: _selectedDistricts,
                  onChanged: _handleDistrictSelection,
                  enabled: _selectedStates.isNotEmpty && !_isLoading,
                ),
                const SizedBox(height: 20),
                _buildLabel("Talukas"),
                _buildSearchableCheckboxDropdown(
                  label: "Taluka",
                  items: _talukas,
                  codeKey: 'subdistrictcode',
                  nameKey: 'subdistrictnameenglish',
                  selectionMap: _selectedTalukas,
                  onChanged: _handleTalukaSelection,
                  enabled: _selectedDistricts.isNotEmpty && !_isLoading,
                ),
                const SizedBox(height: 20),
                _buildLabel("Villages"),
                _buildSearchableCheckboxDropdown(
                  label: "Village",
                  items: _villages,
                  codeKey: 'villagecode',
                  nameKey: 'villagenameenglish',
                  selectionMap: _selectedVillages,
                  onChanged: (newList) {
                    setState(() {
                      _selectedVillages.clear();
                      for (var item in newList) {
                        _selectedVillages[item['villagecode'].toString()] =
                            item['villagenameenglish'].toString();
                      }
                    });
                  },
                  enabled: _selectedTalukas.isNotEmpty && !_isLoading,
                ),
                const Divider(height: 40),
                _buildDatePicker(),
                const SizedBox(height: 16),
                _buildNotesField(),
                const SizedBox(height: 16),
                _buildExpectedField(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: _isLoading ? null : _handleSave,
          child: const Text(
            "Save Visit Plan",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    ),
  );

  Widget _buildSearchableCheckboxDropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    required String codeKey,
    required String nameKey,
    required Map<String, String> selectionMap,
    required Function(List<Map<String, dynamic>>) onChanged,
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<Map<String, dynamic>> selectedItems = items
        .where((item) => selectionMap.containsKey(item[codeKey].toString()))
        .toList();

    return DropdownSearch<Map<String, dynamic>>.multiSelection(
      enabled: enabled,
      items: (filter, loadProps) => items,
      selectedItems: selectedItems,
      itemAsString: (item) => item[nameKey]?.toString() ?? '',
      onChanged: onChanged,
      compareFn: (item1, item2) =>
          item1[codeKey].toString() == item2[codeKey].toString(),
      filterFn: (item, filter) =>
          item[nameKey].toString().toLowerCase().contains(filter.toLowerCase()),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: "Select $label",
          filled: true,
          fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          isDense: true,
        ),
      ),
      popupProps: PopupPropsMultiSelection.menu(
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
        // Updated signature: context, item, isSelected, isHighlighted
        itemBuilder: (context, item, isSelected, isHighlighted) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? (isDark ? Colors.white10 : Colors.grey[200])
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: null, // Logic handled by dropdown_search
                  activeColor: Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item[nameKey]?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      title: const Text("Planned Date"),
      subtitle: Text(DateFormat('dd MMMM, yyyy').format(selectedDate)),
      trailing: const Icon(Icons.calendar_month, color: Colors.green),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (date != null) setState(() => selectedDate = date);
      },
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      decoration: InputDecoration(
        hintText: "Purpose of visit...",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      maxLines: 2,
    );
  }

  Widget _buildExpectedField() {
    return TextField(
      controller: _expectedRegistrations,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "Expected Registrations",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
