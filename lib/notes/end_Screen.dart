import 'package:flutter/material.dart';
import 'package:mukadam_bi/notes/visitApiService.dart';
import 'package:mukadam_bi/notes/visitPlanModel.dart';
import 'package:mukadam_bi/notes/visitedPlansScreen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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

  // 1. New Confirmation Dialog
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

  // Function to handle the actual API call
  Future<void> _handleMarkExecuted(VisitPlan plan) async {
    setState(() => plan.isSelected = true);

    bool success = await _apiService.markPlanAsExecuted(plan.id);

    if (success) {
      setState(() {
        _plans.removeWhere((item) => item.id == plan.id);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF46EC13)))
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Select Plans to Execute'),
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
                            value: plan.isSelected,
                            onChanged: (val) {
                              if (val == true) {
                                // Trigger dialog instead of immediate API call
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
      ),
    );
  }
}
