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
  final TextEditingController _expectedRegistrations = TextEditingController();

  // Theme colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color backgroundGrey = Color(0xFFF5F7FA);
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

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

  void _handleStateSelection(List<Map<String, dynamic>> selectedItems) async {
    final newCodes = selectedItems
        .map((e) => e['state_code'].toString())
        .toSet();
    final oldCodes = _selectedStates.keys.toSet();

    for (var item in selectedItems) {
      final code = item['state_code'].toString();
      if (!oldCodes.contains(code)) {
        await _onStateToggled(code, item['state_name_english'], true);
      }
    }

    for (var code in oldCodes) {
      if (!newCodes.contains(code)) {
        await _onStateToggled(code, '', false);
      }
    }
  }

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

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('bg_user_id') ?? 0;

    final payload = {
      "user_id": userId,
      "locations": _selectedVillages.entries.map((entry) {
        final vCode = entry.key;
        final vName = entry.value;

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
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("Visit Plan Saved Successfully"),
              ],
            ),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            if (_isLoading)
              LinearProgressIndicator(
                backgroundColor: lightGreen.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
              ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 24),
                      _buildLocationCard(),
                      const SizedBox(height: 20),
                      _buildDetailsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Plan Visit",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "New",
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryGreen, lightGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Create Visit Plan",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Select locations and schedule your visit",
                    style: TextStyle(
                      fontSize: 14,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.pin_drop_outlined, color: primaryGreen, size: 22),
                const SizedBox(width: 12),
                const Text(
                  "Location Selection",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const Spacer(),
                _buildSelectionBadge(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDropdownItem(
                  icon: Icons.public,
                  label: "State",
                  child: _buildSearchableCheckboxDropdown(
                    label: "State",
                    items: _states,
                    codeKey: 'state_code',
                    nameKey: 'state_name_english',
                    selectionMap: _selectedStates,
                    onChanged: _handleStateSelection,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDropdownItem(
                  icon: Icons.location_city,
                  label: "District",
                  child: _buildSearchableCheckboxDropdown(
                    label: "District",
                    items: _districts,
                    codeKey: 'districtcode',
                    nameKey: 'districtnameenglish',
                    selectionMap: _selectedDistricts,
                    onChanged: _handleDistrictSelection,
                    enabled: _selectedStates.isNotEmpty && !_isLoading,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDropdownItem(
                  icon: Icons.apartment,
                  label: "Taluka",
                  child: _buildSearchableCheckboxDropdown(
                    label: "Taluka",
                    items: _talukas,
                    codeKey: 'subdistrictcode',
                    nameKey: 'subdistrictnameenglish',
                    selectionMap: _selectedTalukas,
                    onChanged: _handleTalukaSelection,
                    enabled: _selectedDistricts.isNotEmpty && !_isLoading,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDropdownItem(
                  icon: Icons.home_work,
                  label: "Village",
                  child: _buildSearchableCheckboxDropdown(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBadge() {
    final count = _selectedVillages.length;
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "$count selected",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: primaryGreen),
            ),
            const SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.assignment_outlined, color: primaryGreen, size: 22),
                SizedBox(width: 12),
                Text(
                  "Visit Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDatePickerField(),
                const SizedBox(height: 20),
                _buildNotesField(),
                const SizedBox(height: 20),
                _buildExpectedField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchableCheckboxDropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    required String codeKey,
    required String nameKey,
    required Map<String, String> selectionMap,
    required Function(List<Map<String, dynamic>>) onChanged,
    bool enabled = true,
  }) {
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
          hintText: enabled ? "Select $label" : "Select ${label.toLowerCase()} first",
          hintStyle: TextStyle(
            color: enabled ? textMuted : textMuted.withOpacity(0.5),
            fontSize: 14,
          ),
          filled: true,
          fillColor: enabled ? backgroundGrey : backgroundGrey.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled ? textMuted : textMuted.withOpacity(0.5),
          ),
        ),
      ),
      popupProps: PopupPropsMultiSelection.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search $label...",
            hintStyle: const TextStyle(color: textMuted),
            prefixIcon: const Icon(Icons.search, color: textMuted),
            filled: true,
            fillColor: backgroundGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        menuProps: MenuProps(
          backgroundColor: cardWhite,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        itemBuilder: (context, item, isSelected, isHighlighted) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? primaryGreen.withOpacity(0.05)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(color: borderColor.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? primaryGreen : borderColor,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item[nameKey]?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? primaryGreen : textDark,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today, size: 16, color: primaryGreen),
            ),
            const SizedBox(width: 10),
            const Text(
              "PLANNED DATE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: primaryGreen,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: textDark,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) setState(() => selectedDate = date);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(selectedDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM, yyyy').format(selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_calendar,
                    color: primaryGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notes, size: 16, color: primaryGreen),
            ),
            const SizedBox(width: 10),
            const Text(
              "PURPOSE OF VISIT",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(
            fontSize: 14,
            color: textDark,
          ),
          decoration: InputDecoration(
            hintText: "Describe the purpose of your visit...",
            hintStyle: const TextStyle(color: textMuted),
            filled: true,
            fillColor: backgroundGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildExpectedField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.people_outline, size: 16, color: primaryGreen),
            ),
            const SizedBox(width: 10),
            const Text(
              "EXPECTED REGISTRATIONS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _expectedRegistrations,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 14,
            color: textDark,
          ),
          decoration: InputDecoration(
            hintText: "Enter expected number of registrations",
            hintStyle: const TextStyle(color: textMuted),
            filled: true,
            fillColor: backgroundGrey,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(Icons.tag, color: textMuted.withOpacity(0.7), size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: const Size(double.infinity, 54),
          ),
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.save_outlined, size: 20),
              SizedBox(width: 10),
              Text(
                "Save Visit Plan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
