import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
//import 'package:printing/printing.dart';
import 'package:mukadam_bi/notes/visitApiService.dart';
import 'package:mukadam_bi/notes/visitPlanModel.dart';
import 'package:mukadam_bi/notes/visitedPlansScreen.dart';
import 'package:printing/printing.dart';

class VisitTrackingScreen extends StatefulWidget {
  const VisitTrackingScreen({super.key});

  @override
  State<VisitTrackingScreen> createState() => _VisitTrackingScreenState();
}

class _VisitTrackingScreenState extends State<VisitTrackingScreen> {
  final VisitApiService _apiService = VisitApiService();
  List<VisitPlan> _plans = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isShowingToday = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isShowingToday = false;
    });
    try {
      final data = await _apiService.fetchPlannedVisits();
      setState(() {
        _plans = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTodayData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isShowingToday = true;
    });
    try {
      String todayDate = DateTime.now().toIso8601String().split('T')[0];
      final data = await _apiService.fetchTodayVisits(todayDate);
      setState(() {
        _plans = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAndDownloadPdf() async {
    final pdf = pw.Document();
    final String todayDate = DateTime.now().toIso8601String().split('T')[0];

    // Get user info from the first plan if available
    String userName = _plans.isNotEmpty ? (_plans.first.userDetails?.fullName ?? "N/A") : "N/A";
    String userRole = _plans.isNotEmpty ? (_plans.first.userDetails?.role ?? "N/A") : "N/A";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Visit Plan Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Date: $todayDate"),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("User: $userName", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("Role: ${userRole.toUpperCase()}"),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['ID', 'Location', 'Purpose', 'Expected Reg.', 'Status'],
              data: _plans.map((plan) {
                return [
                  plan.id.toString(),
                  plan.locationSummary,
                  plan.purpose,
                  plan.expectedRegistrations.toString(),
                  plan.isExecuted ? "Executed" : "Pending",
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    try {
      // Show preview and allow print/save
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF generated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating PDF: $e")),
      );
    }
  }

  Future<void> _confirmMarkExecuted(VisitPlan plan) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Visit"),
          content: const Text("Did you complete this task?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes", style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _handleMarkExecuted(plan);
    }
  }

  Future<void> _handleMarkExecuted(VisitPlan plan) async {
    setState(() => plan.isSelected = true);
    bool success = await _apiService.markPlanAsExecuted(plan.id);
    if (success) {
      setState(() {
        plan.isExecuted = true;
        plan.isSelected = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plan marked as executed successfully")),
      );
    } else {
      setState(() => plan.isSelected = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to mark plan. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),
        elevation: 0,
        title: const Text(
          'Visit Tracking',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VisitedPlansScreen()),
              );
            },
            child: const Text("Plans visited", style: TextStyle(color: Color(0xFF15803D))),
          )
        ],
      ),
      floatingActionButton: _isShowingToday && _plans.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _generateAndDownloadPdf,
        backgroundColor: const Color(0xFF15803D),
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: const Text("Download PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF46EC13)))
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _loadData, child: const Text("Retry"))
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _isShowingToday ? _loadTodayData : _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeaderWithButton(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: _plans.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text("No pending plans found.")),
                  )
                      : Column(
                    children: _plans.map((plan) {
                      return Column(
                        children: [
                          CheckboxListTile(
                            value: plan.isExecuted || plan.isSelected,
                            onChanged: (plan.isExecuted)
                                ? null
                                : (val) {
                              if (val == true) {
                                _confirmMarkExecuted(plan);
                              }
                            },
                            activeColor: const Color(0xFF46EC13),
                            checkColor: Colors.white,
                            title: Text(
                              plan.locationSummary.isNotEmpty ? plan.locationSummary : "${plan.village}, ${plan.taluka}",
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 14),
                            ),
                            subtitle: Text(
                              "Purpose: ${plan.purpose}",
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                            secondary: const Icon(Icons.location_on, color: Color(0xFFCBD5E1)),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          if (plan != _plans.last) const Divider(height: 1, indent: 64),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeaderWithButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _isShowingToday ? "Today's Plans" : "Select Plans to Execute",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
          ),
          Row(
            children: [
              if (_isShowingToday)
                TextButton(
                  onPressed: _loadData,
                  child: const Text("Show All", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ElevatedButton(
                onPressed: _loadTodayData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text("Today Plan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
