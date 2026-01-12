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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF15803D),
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
        _startDate = picked.start;
        _endDate = picked.end;
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
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range, color: Color(0xFF15803D)),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
                ),
                Text(
                  "Count: ${_history.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
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
                ? const Center(child: Text("No executed plans found for this range."))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
