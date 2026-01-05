import 'package:flutter/material.dart';
import 'package:mukadam_bi/getTransport/transport_registration_response.dart';
import 'package:mukadam_bi/getTransport/transport_registration_service.dart';
import 'package:provider/provider.dart';
import '../mukadan/authentication/userProvider.dart';

class TransportDirectoryScreen extends StatefulWidget {
  final String searchQuery;
  final String dateFrom;
  final String dateTo;

  const TransportDirectoryScreen({
    super.key,
    required this.searchQuery,
    required this.dateFrom,
    required this.dateTo,
  });

  @override
  State<TransportDirectoryScreen> createState() => _TransportDirectoryScreenState();
}

class _TransportDirectoryScreenState extends State<TransportDirectoryScreen> {
  late Future<TransportRegistrationResponse> _registrationFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Reload data if the date range changes in the parent widget
  @override
  void didUpdateWidget(covariant TransportDirectoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateFrom != widget.dateFrom || oldWidget.dateTo != widget.dateTo) {
      _loadData();
    }
  }

  void _loadData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Use the actual user ID from the provider
    int userId = userProvider.user?.id ?? 29;

    setState(() {
      _registrationFuture = getTransportRegistrationService().fetchRegistrations(
        userId: userId,
        dateFrom: widget.dateFrom,
        dateTo: widget.dateTo,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TransportRegistrationResponse>(
      future: _registrationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.transporters.isEmpty) {
          return const Center(child: Text("No transporters found for this date range."));
        }

        final filteredTransporters = snapshot.data!.transporters.where((t) {
          return t.name.toLowerCase().contains(widget.searchQuery.toLowerCase());
        }).toList();

        if (filteredTransporters.isEmpty) {
          return const Center(child: Text("No matching transporters."));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredTransporters.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return TransporterCard(transporter: filteredTransporters[index]);
          },
        );
      },
    );
  }
}

class TransporterCard extends StatelessWidget {
  final Transporter transporter;
  const TransporterCard({super.key, required this.transporter});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C252E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
        ),
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
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.orangeAccent,
            child: Text(
              transporter.name.isNotEmpty ? transporter.name[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transporter.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Mobile: ${transporter.mobile}",
                  style: const TextStyle(color: Color(0xFF137fec), fontSize: 14),
                ),
                Text(
                  "Village: ${transporter.village}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_shipping, color: Colors.grey),
        ],
      ),
    );
  }
}

