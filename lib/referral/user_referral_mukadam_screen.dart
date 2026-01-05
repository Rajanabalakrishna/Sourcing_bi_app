import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mukadam_bi/referral/referral_service.dart';
import 'package:mukadam_bi/referral/registration_response.dart';
import 'package:provider/provider.dart';
import '../getTransport/gettransportscreen.dart';
import '../mukadan/authentication/userProvider.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  late Future<RegistrationResponse> _registrationFuture;
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
        _registrationFuture = referralRegistrationService().fetchRegistrations(
          username: userProvider.user!.username,
          dateFrom: DateFormat('yyyy-MM-dd').format(_startDate),
          dateTo: DateFormat('yyyy-MM-dd').format(_endDate),
        );
      });
    } else {
      setState(() {
        _registrationFuture = Future.error("User not logged in");
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026, 12, 31),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateRangeStr = "${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd').format(_endDate)}";

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Directory", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: _selectDateRange,
            )
          ],
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
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.date_range, size: 16),
                    label: Text(dateRangeStr),
                    onPressed: _selectDateRange,
                  ),
                ],
              ),
            ),
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
                  fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C252E) : Colors.white,
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
                    dateFrom: DateFormat('yyyy-MM-dd').format(_startDate),
                    dateTo: DateFormat('yyyy-MM-dd').format(_endDate),
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
    return FutureBuilder<RegistrationResponse>(
      future: _registrationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.mukkadams.isEmpty) {
          return const Center(child: Text("No registrations found."));
        }

        final filteredMukkadams = snapshot.data!.mukkadams.where((m) {
          return m.name.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filteredMukkadams.isEmpty) {
          return const Center(child: Text("No matching registrations."));
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
  final Mukkadam mukkadam;
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
              mukkadam.name.isNotEmpty ? mukkadam.name[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mukkadam.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                //Text("Mobile: ${mukkadam.mobile}", style: const TextStyle(color: Color(0xFF137fec), fontSize: 14)),
                Text("Village: ${mukkadam.village} • Crew: ${mukkadam.crewSize}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
         // const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
