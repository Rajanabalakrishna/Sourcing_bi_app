import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'data.dart';
//import 'data_entry_service.dart';

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final DataEntryService _apiService = DataEntryService();

  String? selectedDistrict;
  String? selectedTaluk;
  String? selectedVillage;
  DateTime selectedDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];

  bool _isLoadingDistricts = true;
  bool _isLoadingTalukas = false;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      final data = await _apiService.getDistricts();
      setState(() {
        _districts = data;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      setState(() => _isLoadingDistricts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading districts: $e')),
        );
      }
    }
  }

  Future<void> _loadTalukas(String districtCode) async {
    setState(() {
      _isLoadingTalukas = true;
      _talukas = [];
      selectedTaluk = null; // Reset taluk selection
    });

    try {
      final data = await _apiService.getTalukas(districtCode);
      setState(() {
        _talukas = data;
        _isLoadingTalukas = false;
      });
    } catch (e) {
      setState(() => _isLoadingTalukas = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading talukas: $e')),
        );
      }
    }
  }

  Future<void> _generateAndSavePdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final String currentTime = DateFormat('hh:mm a').format(now);
    final String currentDate = DateFormat('dd-MM-yyyy').format(now);
    final String visitDate = DateFormat('dd-MM-yyyy').format(selectedDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('VISIT REPORT',
                    style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                pw.Divider(thickness: 2, color: PdfColors.grey300),
                pw.SizedBox(height: 20),
                _buildPdfRow('Generation Date:', currentDate),
                _buildPdfRow('Generation Time:', currentTime),
                pw.SizedBox(height: 15),
                pw.Text('Location Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _buildPdfRow('District:', selectedDistrict ?? 'N/A'),
                _buildPdfRow('Taluk:', selectedTaluk ?? 'N/A'),
                _buildPdfRow('Village:', selectedVillage ?? 'N/A'),
                _buildPdfRow('Date of Visit:', visitDate),
                pw.SizedBox(height: 25),
                pw.Text('Additional Notes:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(8)
                  ),
                  child: pw.Text(
                    _notesController.text.isEmpty ? 'No additional notes provided.' : _notesController.text,
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      final directory = await getTemporaryDirectory();
      final String fileName = 'Visit_Report_${DateFormat('yyyyMMdd_HHmm').format(now)}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)], subject: 'Visit Report PDF');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(width: 10),
          pw.Text(value, style: const pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Add Location Data', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionHeader('LOCATION DETAILS'),
              const SizedBox(height: 16),

              _isLoadingDistricts
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDropdownField(
                'District',
                'Select District',
                _districts.map((d) => d['districtnameenglish'].toString()).toList(),
                selectedDistrict,
                    (val) {
                  if (val != null) {
                    setState(() {
                      selectedDistrict = val;
                      selectedTaluk = null;
                      selectedVillage = null;
                    });
                    // Find the district code to fetch talukas
                    final district = _districts.firstWhere(
                          (d) => d['districtnameenglish'] == val,
                      orElse: () => {},
                    );
                    if (district.containsKey('districtcode')) {
                      _loadTalukas(district['districtcode'].toString());
                    }
                  }
                },
              ),

              if (_isLoadingTalukas)
                const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ))
              else
                _buildDropdownField(
                  'Taluk',
                  'Select Taluk',
                  _talukas.map((t) => t['subdistrictname'].toString()).toSet().toList(), // toSet() handles duplicates
                  selectedTaluk,
                      (val) => setState(() => selectedTaluk = val),
                ),

              _buildDropdownField('Village', 'Select Village', ['Village X', 'Village Y', 'Village Z'], selectedVillage,
                      (val) => setState(() => selectedVillage = val)),
              const Divider(height: 40),
              _buildSectionHeader('DATE OF VISIT'),
              const SizedBox(height: 16),
              _buildDatePickerTile(),
              const Divider(height: 40),
              _buildSectionHeader('ADDITIONAL NOTES'),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 120),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: ElevatedButton.icon(
                onPressed: _generateAndSavePdf,
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text('Save & Download PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold));
  }

  Widget _buildDropdownField(String label, String hint, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null, // Prevents "value not in items" error
          hint: Text(hint),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          isExpanded: true,
          menuMaxHeight: MediaQuery.of(context).size.height * 0.25,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDatePickerTile() {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
      leading: const Icon(Icons.calendar_today, color: Color(0xFF15803D)),
      title: const Text('Visit Date'),
      subtitle: Text(DateFormat('dd MMM, yyyy').format(selectedDate)),
      trailing: const Icon(Icons.edit),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Enter notes here...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
