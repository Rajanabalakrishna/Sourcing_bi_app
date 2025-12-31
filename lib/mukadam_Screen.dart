import 'package:flutter/material.dart';
import 'package:mukadam_bi/plans/allPlansScreen.dart';

// Your existing imports
import 'package:mukadam_bi/transport/Transport_provider/transport_provider_Screen.dart';
import 'package:mukadam_bi/transport/transport_provider_list/transport_provider_list_screen.dart';
import 'mukadan/get_mukadam_details/mukadam_details_Screen.dart'; // Ensure path matches MukadamListScreen
import 'mukadan/quick_registration/quick_registration_Screen.dart';
import 'mukadan/registration/mukadam_registration_Screen.dart';
import 'notes/end_Screen.dart';
import 'notes/todo_screen.dart'; // Assuming this contains DataEntryScreen

class MukadamDashboard extends StatefulWidget {
  const MukadamDashboard({super.key});

  @override
  State<MukadamDashboard> createState() => _MukadamDashboardState();
}

class _MukadamDashboardState extends State<MukadamDashboard> {
  int _selectedIndex = 0;

  // List of widgets to display for each tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildDashboardContent(), // Modern Grid View
      const DataEntryScreen(),   // Your existing Data Entry Screen
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // Background Color for the top section (matches the header)
          Container(
            height: 200,
            color: const Color(0xFF3B82F6),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // You can trigger a quick action here, or navigate to registration
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const DataEntryScreen()),
      //     );
      //   },
      //   backgroundColor: const Color(0xFF3B82F6),
      //   shape: const CircleBorder(),
      //   elevation: 4,
      //   child: const Icon(Icons.add, color: Colors.white, size: 30),
      // ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
              const Text(
                "Mukadam\nManagement",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
          // IconButton(
          //   onPressed: () {},
          //
          //   style: IconButton.styleFrom(
          //     backgroundColor: Colors.white.withOpacity(0.2),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              _buildActionCard(
                "Mukadam\nRegistration",
                Icons.person_add_alt_1,
                Colors.blue,
                const MukkadamRegistrationScreen(),
              ),
              _buildActionCard(
                "Quick Mukadam\nRegistration",
                Icons.bolt,
                Colors.orange.shade800,
                const QuickMukkadamRegistrationScreen(),
              ),
              // _buildActionCard(
              //   "Get Mukadam\nDetails",
              //   Icons.record_voice_over,
              //     Color(0xFF50C878),
              //   const MukadamListScreen(),
              // ),
              _buildActionCard(
                "Transport\nRegistration",
                Icons.local_shipping,
                Colors.redAccent,
                const TransportProviderScreen(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // _buildWideCard(
          //   "Transport Provider",
          //   "Search database",
          //   Icons.receipt_long,
          //   const TransportProviderListScreen(),
          // ),

          // _buildWideCard(
          //   "All plan details",
          //   "Search database",
          //   Icons.receipt_long,
          //   const PlannedVisitsApp(),
          // ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(top: 0, left: 0, right: 0, child: Container(height: 4, color: color)),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideCard(String title, String subtitle, IconData icon, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      height: 70,
      notchMargin: 8,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.grid_view_rounded, "Home", 0),
          const SizedBox(width: 40), // Space for FAB
         _navItem(Icons.table_chart_outlined, "Data", 1),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF3B82F6) : Colors.grey[400]),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF3B82F6) : Colors.grey[400],
            ),
          )
        ],
      ),
    );
  }
}