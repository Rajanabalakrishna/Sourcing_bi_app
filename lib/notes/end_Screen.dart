import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
  String _headerTitle = "Planned Visits";

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
      _headerTitle = "Planned Visits";
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
      _headerTitle = "Today's Schedule";
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

  // New logic to load data for a specific selected date
  Future<void> _loadDataForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isShowingToday = true;
      _headerTitle = "Plans: ${DateFormat('dd MMM').format(date)}";
    });
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      // Calling the new API with from/to as the same date
      final data = await _apiService.fetchPlannedVisitsByRange(formattedDate, formattedDate);
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF15803D)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _loadDataForDate(picked);
    }
  }

  Future<void> _generateAndDownloadPdf() async {
    final pdf = pw.Document();
    final String todayDate = DateTime.now().toIso8601String().split('T')[0];
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
            ),
          ];
        },
      ),
    );

    try {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _confirmMarkExecuted(VisitPlan plan) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Visit"),
          content: const Text("Did you complete this visit?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No", style: TextStyle(color: Colors.red))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes", style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold))),
          ],
        );
      },
    );
    if (confirmed == true) _handleMarkExecuted(plan);
  }

  Future<void> _handleMarkExecuted(VisitPlan plan) async {
    setState(() => _isLoading = true);
    bool success = await _apiService.markPlanAsExecuted(plan.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Plan marked as executed")));
      _isShowingToday ? _loadTodayData() : _loadData();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to mark plan.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Visit Tracking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF1E293B))),
        actions: [
          IconButton(onPressed: _selectDate, icon: const Icon(Icons.calendar_month, color: Color(0xFF15803D))),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VisitedPlansScreen())),
            child: const Text("History", style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold)),
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF15803D)))
          : RefreshIndicator(
        onRefresh: _isShowingToday ? _loadTodayData : _loadData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeaderCard()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _plans.isEmpty
                  ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("No pending plans found."))))
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildVisitCard(_plans[index]),
                  childCount: _plans.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF15803D), Color(0xFF166534)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_headerTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (_isShowingToday)
                IconButton(onPressed: _loadData, icon: const Icon(Icons.close, color: Colors.white, size: 20)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loadTodayData,
                  icon: const Icon(Icons.today, size: 16),
                  label: const Text("Today"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF15803D)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.event, size: 16),
                  label: const Text("Pick Date"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(VisitPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
            backgroundColor: Color(0xFFF1F5F9),
            child: Icon(Icons.holiday_village_sharp, color: Color(0xFF15803D))
        ),
        title: Text(
            plan.locationSummary.isNotEmpty ? plan.locationSummary : "${plan.village}, ${plan.taluka}",
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.purpose),
            const SizedBox(height: 4),
            Text(
              "Expected Reg: ${plan.expectedRegistrations}",
              style: const TextStyle(
                  color: Color(0xFF15803D),
                  fontWeight: FontWeight.w600,
                  fontSize: 12
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _confirmMarkExecuted(plan),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white
          ),
          child: const Text("Mark"),
        ),
      ),
    );
  }

}
