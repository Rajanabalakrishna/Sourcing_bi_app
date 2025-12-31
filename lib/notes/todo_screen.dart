import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';



class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final DataEntryService _apiService = DataEntryService();

  final Map<String, String> _selectedDistricts = {};
  final Map<String, String> _selectedTalukas = {};
  final Map<String, String> _selectedVillages = {};

  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  List<Map<String, dynamic>> _villages = [];

  bool _isLoading = false;
  DateTime selectedDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialDistricts();
  }

  Future<void> _loadInitialDistricts() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getDistricts();
      setState(() => _districts = data);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onDistrictToggled(String code, String name, bool? checked) async {
    if (checked == true) {
      setState(() {
        _selectedDistricts[code] = name;
        _isLoading = true;
      });
      try {
        final newTalukas = await _apiService.getTalukas(code);
        setState(() {
          for (var t in newTalukas) {
            if (!_talukas.any((ex) => ex['subdistrictcode'].toString() == t['subdistrictcode'].toString())) {
              t['parent_district_code'] = code;
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
        _selectedTalukas.removeWhere((k, v) => !_talukas.any((t) => t['subdistrictcode'].toString() == k));
        _villages.removeWhere((v) => !_selectedTalukas.containsKey(v['parent_taluka_code']));
        _selectedVillages.removeWhere((k, v) => !_villages.any((vi) => vi['villagecode'].toString() == k));
      });
    }
  }

  void _onTalukToggled(String code, String name, bool? checked) async {
    if (checked == true) {
      setState(() {
        _selectedTalukas[code] = name;
        _isLoading = true;
      });
      try {
        final newVillages = await _apiService.getVillages(code);
        setState(() {
          for (var v in newVillages) {
            if (!_villages.any((ex) => ex['villagecode'].toString() == v['villagecode'].toString())) {
              v['parent_taluka_code'] = code;
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
        _selectedVillages.removeWhere((k, v) => !_villages.any((vi) => vi['villagecode'].toString() == k));
      });
    }
  }

  Future<void> _handleSave() async {
    if (_selectedVillages.isEmpty) {
      _showError("Please select at least one village");
      return;
    }

    setState(() => _isLoading = true);

    // FIX: Include both the lists and the single-value fallback fields
    final payload = {
      // Multiple selections (New Structure)
      "districts": _selectedDistricts.entries.map((e) => {"name": e.value, "code": e.key}).toList(),
      "talukas": _selectedTalukas.entries.map((e) => {"name": e.value, "code": e.key}).toList(),
      "villages": _selectedVillages.entries.map((e) => {"name": e.value, "code": e.key}).toList(),

      // Single values (Legacy/DB Fallback - prevents NULL in DB)
      "district": _selectedDistricts.values.first,
      "district_code": _selectedDistricts.keys.first,
      "taluka": _selectedTalukas.values.first,
      "taluka_code": _selectedTalukas.keys.first,
      "village": _selectedVillages.values.first,
      "village_code": _selectedVillages.keys.first,

      "planned_date": DateFormat('yyyy-MM-dd').format(selectedDate),
      "purpose": _notesController.text.isEmpty ? "Multi-village visit" : _notesController.text,
      "expected_registrations": 50
    };

    try {
      await _apiService.createVisitPlan(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Visit Plan Saved Successfully"), backgroundColor: Colors.green));
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Plan Visit", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                _buildLabel("Districts"),
                _buildCheckboxGroup(_districts, 'districtcode', 'districtnameenglish', _selectedDistricts, _onDistrictToggled),
                const SizedBox(height: 20),
                _buildLabel("Talukas"),
                _talukas.isEmpty
                    ? const Text("Select district first", style: TextStyle(color: Colors.grey))
                    : _buildCheckboxGroup(_talukas, 'subdistrictcode', 'subdistrictnameenglish', _selectedTalukas, _onTalukToggled),
                const SizedBox(height: 20),
                _buildLabel("Villages"),
                _villages.isEmpty
                    ? const Text("Select talukas first", style: TextStyle(color: Colors.grey))
                    : _buildCheckboxGroup(_villages, 'villagecode', 'villagenameenglish', _selectedVillages, (code, name, val) {
                  setState(() => val == true ? _selectedVillages[code] = name : _selectedVillages.remove(code));
                }),
                const Divider(height: 40),
                _buildDatePicker(),
                const SizedBox(height: 16),
                _buildNotesField(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
          ),
          onPressed: _isLoading ? null : _handleSave,
          child: const Text("Save Visit Plan", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
  );

  Widget _buildCheckboxGroup(List<Map<String, dynamic>> items, String codeKey, String nameKey, Map<String, String> selectionMap, Function(String, String, bool?) onChanged) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
      constraints: const BoxConstraints(maxHeight: 180),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final code = item[codeKey].toString();
          final name = item[nameKey].toString();
          return CheckboxListTile(
            title: Text(name, style: const TextStyle(fontSize: 13)),
            value: selectionMap.containsKey(code),
            onChanged: (val) => onChanged(code, name, val),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          );
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey[300]!)),
      title: const Text("Planned Date"),
      subtitle: Text(DateFormat('dd MMMM, yyyy').format(selectedDate)),
      trailing: const Icon(Icons.calendar_month, color: Colors.green),
      onTap: () async {
        final date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
      maxLines: 2,
    );
  }
}
