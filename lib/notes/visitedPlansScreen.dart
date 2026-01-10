import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl to pubspec.yaml for date formatting
import 'package:mukadam_bi/notes/markVisitedModel.dart';
import 'package:mukadam_bi/notes/visitApiService.dart';
import 'package:mukadam_bi/notes/visitPlanModel.dart';

class VisitedPlansScreen extends StatefulWidget {
  const VisitedPlansScreen({super.key});

  @override
  State<VisitedPlansScreen> createState() => _VisitedPlansScreenState();
}

class _VisitedPlansScreenState extends State<VisitedPlansScreen> {
  final VisitApiService _apiService = VisitApiService();
  List<alreadyVisitedPaln> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final data = await _apiService.fetchExecutedVisits();
      setState(() {
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Visit History', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF15803D)))
          : _history.isEmpty
          ? const Center(child: Text("No visited plans found."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final plan = _history[index];
          return _buildHistoryCard(plan);
        },
      ),
    );
  }

  Widget _buildHistoryCard(alreadyVisitedPaln plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: Color(0xFF15803D)),
        ),
        title: Text(
          plan.locationSummary.isNotEmpty ? plan.locationSummary : "${plan.village}, ${plan.taluka}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Purpose: ${plan.purpose}", style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  "Visited on: ${plan.plannedDate}", // You can format this date better if needed
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
      ),
    );
  }
}
