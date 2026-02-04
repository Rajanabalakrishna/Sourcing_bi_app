import 'package:flutter/material.dart';
import 'package:mukadam_bi/seeplan/plan_service_model.dart';
import 'package:mukadam_bi/seeplan/village_execution_screen.dart';
import 'package:mukadam_bi/seeplan/plan_Service_file.dart'; // Import your service
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DailyPlansScreen extends StatefulWidget {
  final VillageVisitPlan plan;

  const DailyPlansScreen({super.key, required this.plan});

  @override
  State<DailyPlansScreen> createState() => _DailyPlansScreenState();
}

class _DailyPlansScreenState extends State<DailyPlansScreen> {
  late VillageVisitPlan _currentPlan;
  bool _isLoading = false;
  final PlanService _planService = PlanService();

  @override
  void initState() {
    super.initState();
    // Initialize with the passed plan, then refresh to get latest statuses
    _currentPlan = widget.plan;
    _refreshData();
  }

  // Method to fetch latest data from API
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final plans = await _planService.fetchVisitPlans();
      // Find the specific plan we are viewing by ID
      final updatedPlan = plans.firstWhere((p) => p.id == _currentPlan.id);
      setState(() {
        _currentPlan = updatedPlan;
      });
    } catch (e) {
      debugPrint("Error refreshing plans: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAndDownloadPdf(String date, String purpose) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Visit Plan - $date",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text(purpose),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'plan_$date.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_currentPlan.planName),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      // Wrap with RefreshIndicator for pull-to-refresh
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Plan Schedule",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 4),
                  Text("${_currentPlan.startDate} - ${_currentPlan.endDate}",
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            if (_isLoading && _currentPlan.dailyPlans.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _currentPlan.dailyPlans.length,
                  itemBuilder: (context, index) {
                    final daily = _currentPlan.dailyPlans[index];
                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                    color: Colors.blue, shape: BoxShape.circle),
                              ),
                              Expanded(
                                child: Container(
                                    width: 2,
                                    color: index == _currentPlan.dailyPlans.length - 1
                                        ? Colors.transparent
                                        : Colors.blue.shade100),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      daily.visitDate,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    if (daily.purpose.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.picture_as_pdf,
                                            color: Colors.redAccent),
                                        onPressed: () => _generateAndDownloadPdf(
                                            daily.visitDate, daily.purpose),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...daily.villageVisits.map((v) => Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.location_on, color: Colors.redAccent),
                                    title: Text(v.village),
                                    subtitle: Text("${v.taluka}, ${v.district}"),
                                    trailing: Text(
                                      v.statusDisplay,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: v.status.toLowerCase() == 'completed' ? Colors.grey : Colors.green
                                      ),
                                    ),
                                    onTap: v.status.toLowerCase() == 'completed'
                                        ? null
                                        : () async {
                                      if (v.canExecute ||
                                          v.status.toLowerCase() == 'in_progress' ||
                                          v.status.toLowerCase() == 'planned') {

                                        // Await the push so we know when the user returns
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VillageExecutionScreen(village: v),
                                          ),
                                        );

                                        // REFRESH DATA HERE after popping back
                                        _refreshData();

                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("This visit cannot be executed at this time.")),
                                        );
                                      }
                                    },
                                  ),
                                )),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
