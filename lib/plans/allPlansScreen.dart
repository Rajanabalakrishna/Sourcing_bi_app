

import 'package:flutter/material.dart';


class PlannedVisitsApp extends StatelessWidget {
  const PlannedVisitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF19e63c),
          primary: const Color(0xFF19e63c),
          surface: Colors.white,
          background: const Color(0xFFf6f8f6),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF112114),
        cardColor: const Color(0xFF1a2c1e),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF19e63c),
          primary: const Color(0xFF19e63c),
          surface: const Color(0xFF1a2c1e),
        ),
      ),
      home: const VisitsListScreen(),
    );
  }
}

class VisitsListScreen extends StatelessWidget {
  const VisitsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _CircleIconButton(icon: Icons.notifications_none_outlined),
                        const SizedBox(width: 8),
                        _CircleIconButton(icon: Icons.add),
                      ],
                    ),
                    const Text(
                      'Planned Visits',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by location or purpose',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1a2c1e) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),

            // Today Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF19e63c).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '3 Visits',
                        style: TextStyle(color: Color(0xFF19e63c), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Visit Cards
            SliverList(
              delegate: SliverChildListDelegate([
                const VisitCard(
                  time: '10:00 AM - 12:00 PM',
                  location: 'Central Community Center',
                  purpose: 'New Voter Registration Drive',
                  target: '50',
                  status: 'Pending',
                  statusColor: Colors.orange,
                ),
                const VisitCard(
                  time: '02:00 PM - 04:00 PM',
                  location: 'Northside High School',
                  purpose: 'Student ID Registration',
                  target: '120',
                  status: 'Confirmed',
                  statusColor: Color(0xFF19e63c),
                ),
                const VisitCard(
                  time: '05:30 PM - 07:00 PM',
                  location: 'Downtown Metro Station',
                  purpose: 'Commuter Outreach',
                  target: '200',
                  status: 'Tentative',
                  statusColor: Colors.grey,
                ),

                // Tomorrow Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text('Tomorrow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),

                const VisitCard(
                  time: '09:00 AM - 11:30 AM',
                  location: 'West End Library',
                  purpose: 'Senior Citizen Support',
                  target: '30',
                  isOpacityReduced: true,
                ),
              ]),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF19e63c),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.play_arrow, weight: 700),
        label: const Text('Start Visit', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: StadiumBorder(),
      ),
    );
  }
}

class VisitCard extends StatelessWidget {
  final String time;
  final String location;
  final String purpose;
  final String target;
  final String? status;
  final Color? statusColor;
  final bool isOpacityReduced;

  const VisitCard({
    super.key,
    required this.time,
    required this.location,
    required this.purpose,
    required this.target,
    this.status,
    this.statusColor,
    this.isOpacityReduced = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: isOpacityReduced ? 0.8 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a2c1e) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Color(0xFF19e63c)),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    purpose,
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Tag(
                        icon: Icons.group_outlined,
                        label: 'Target: $target',
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                      ),
                      if (status != null)
                        _Tag(
                          dotColor: statusColor,
                          label: status!,
                          color: statusColor!.withOpacity(0.1),
                          textColor: statusColor,
                        ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/150'), // Replace with actual map logic
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData? icon;
  final Color? dotColor;
  final String label;
  final Color color;
  final Color? textColor;

  const _Tag({this.icon, this.dotColor, required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 14, color: const Color(0xFF19e63c)),
          if (dotColor != null) Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          if (icon != null || dotColor != null) const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  const _CircleIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
      ),
      child: Icon(icon, size: 22),
    );
  }
}