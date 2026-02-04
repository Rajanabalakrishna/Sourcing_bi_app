import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../getTransport/gettransportscreen.dart';
import '../mukadan/authentication/userProvider.dart';
import '../verifications/mukadam_dashboard/mukadam_service.dart';
import '../verifications/mukadam_dashboard/mukkadam_data_model.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  late Future<List<MukkadamDataModel>> _mukkadamFuture;
  String _searchQuery = "";

  DateTime _startDate = DateTime(2025, 12, 1);
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user != null) {
      setState(() {
        _mukkadamFuture = MukkadamService().fetchMukkadams(userProvider.user!.id);
      });
    } else {
      setState(() {
        _mukkadamFuture = Future.error("User not logged in");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Directory", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
          surfaceTintColor: Colors.transparent,
          bottom: const TabBar(
            indicatorColor: Color(0xFF137fec),
            labelColor: Color(0xFF137fec),
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.grid_on), text: "Registrations"),
              Tab(icon: Icon(Icons.assignment_ind), text: "Transport"),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search by name...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1C252E) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildRegistrationList(),
                  TransportDirectoryScreen(
                    searchQuery: _searchQuery,

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationList() {
    return FutureBuilder<List<MukkadamDataModel>>(
      future: _mukkadamFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No registrations found."));
        }

        final filteredMukkadams = snapshot.data!.where((m) {
          bool matchesSearch = m.mukkadamName.toLowerCase().contains(_searchQuery);
          bool isFullyVerified = m.isPanVerified && m.isAadharVerified;
          return matchesSearch && isFullyVerified;
        }).toList();

        if (filteredMukkadams.isEmpty) {
          return const Center(child: Text("No verified registrations found."));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredMukkadams.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return MukkadamCard(mukkadam: filteredMukkadams[index]);
          },
        );
      },
    );
  }
}

class MukkadamCard extends StatelessWidget {
  final MukkadamDataModel mukkadam;
  const MukkadamCard({super.key, required this.mukkadam});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C252E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF137fec),
            child: Text(
              mukkadam.mukkadamName.isNotEmpty ? mukkadam.mukkadamName[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mukkadam.mukkadamName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Village: ${mukkadam.village} • Crew: ${mukkadam.crewSize}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text("Fully Verified", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
