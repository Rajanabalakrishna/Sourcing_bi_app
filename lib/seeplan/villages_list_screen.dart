import 'package:flutter/material.dart';
import 'package:mukadam_bi/seeplan/plan_Service_file.dart';
import 'package:mukadam_bi/seeplan/plan_list_screen.dart';
import 'package:mukadam_bi/seeplan/plan_service_model.dart';

class VillagePlansScreen extends StatefulWidget {
  const VillagePlansScreen({super.key});

  @override
  State<VillagePlansScreen> createState() => _VillagePlansScreenState();
}

class _VillagePlansScreenState extends State<VillagePlansScreen> {

  late Future<List<VillageVisitPlan>> _plansFuture;

  @override
  void initState() {
    super.initState();
    _plansFuture = PlanService().fetchVisitPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Village Visit Plans', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<VillageVisitPlan>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No plans available.'));
          }

          final plans = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                //margin: const EdgeInsets.bottom(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    plan.planName.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text("${plan.startDate} to ${plan.endDate}"),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // child: Text(
                          //   plan.statusDisplay,
                          //   style: TextStyle(color: Colors.blue.shade800, fontSize: 12),
                          // ),
                        )
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyPlansScreen(plan: plan),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
