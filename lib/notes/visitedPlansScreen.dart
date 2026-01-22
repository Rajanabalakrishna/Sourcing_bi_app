import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mukadam_bi/notes/visitApiService.dart';
import 'package:mukadam_bi/notes/markVisitedModel.dart';

class VisitedPlansScreen extends StatefulWidget {
  const VisitedPlansScreen({super.key});

  @override
  State<VisitedPlansScreen> createState() => _VisitedPlansScreenState();
}

class _VisitedPlansScreenState extends State<VisitedPlansScreen> {
  final VisitApiService _apiService = VisitApiService();
  List<alreadyVisitedPaln> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Default range: Last 7 days to Today
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Formatting dates to yyyy-MM-dd as required by the API
      String dateFrom = DateFormat('yyyy-MM-dd').format(_startDate);
      String dateTo = DateFormat('yyyy-MM-dd').format(_endDate);

      final data = await _apiService.fetchExecutedVisits(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      setState(() {
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Simplified Date Selection: Pick one date at a time
  // This is much easier for farmers to understand than a range picker
  Future<void> _pickDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: isStartDate ? 'SELECT FROM DATE' : 'SELECT TO DATE',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF15803D), // Theme color
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _fetchHistory();
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
          'Execution History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Simplified Date Selection Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Start Date Button
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("From Date", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Color(0xFF15803D)),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_startDate),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // End Date Button
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("To Date", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Color(0xFF15803D)),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_endDate),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Visits: ${_history.length}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                    ),
                    TextButton.icon(
                      onPressed: _fetchHistory,
                      icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF15803D)),
                      label: const Text("Refresh", style: TextStyle(color: Color(0xFF15803D))),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF46EC13)))
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _history.isEmpty
                ? const Center(child: Text("No executed plans found for these dates."))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final plan = _history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFDCFCE7),
                      child: Icon(Icons.check_circle, color: Color(0xFF15803D)),
                    ),
                    title: Text(
                      plan.locationSummary.isNotEmpty ? plan.locationSummary : "${plan.village}, ${plan.taluka}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Purpose: ${plan.purpose}", style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          "Planned Date: ${plan.plannedDate}",
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
