import 'package:flutter/material.dart';
import 'package:mukadam_bi/verifications/transporter_verifcations/verification_model.dart';

import 'package:provider/provider.dart';
import '../mukadan/authentication/userProvider.dart';
import '../verifications/transporter_verifcations/verificatrion_service.dart';

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
  late Future<List<VerificationEntity>> _verificationFuture;
  final VerificationService _verificationService = VerificationService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant TransportDirectoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateFrom != widget.dateFrom || oldWidget.dateTo != widget.dateTo) {
      _loadData();
    }
  }

  void _loadData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    int userId = userProvider.user?.id ?? 29;

    setState(() {
      // Loading data from fetchPendingVerifications as requested
      _verificationFuture = _verificationService.fetchPendingVerifications(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VerificationEntity>>(
      future: _verificationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No transporters found."));
        }

        // Filter: Load/Show data if and only if is_rc_verified && is_dl_verified == true
        final filteredEntities = snapshot.data!.where((entity) {
          bool isRcVerified = entity.verifications.any((v) => v.isRcVerified == true);
          bool isDlVerified = entity.verifications.any((v) => v.isDlVerified == true);

          bool matchesVerification = isRcVerified && isDlVerified;
          bool matchesSearch = entity.entity.name.toLowerCase().contains(widget.searchQuery.toLowerCase());

          return matchesVerification && matchesSearch;
        }).toList();

        if (filteredEntities.isEmpty) {
          return const Center(child: Text("No verified transporters match your search."));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredEntities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return TransporterCard(entity: filteredEntities[index].entity);
          },
        );
      },
    );
  }
}

class TransporterCard extends StatelessWidget {
  final EntityDetails entity;
  const TransporterCard({super.key, required this.entity});

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
              entity.name.isNotEmpty ? entity.name[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entity.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Contact: ${entity.contactNumber}",
                  style: const TextStyle(color: Color(0xFF137fec), fontSize: 14),
                ),
                Text(
                  "Location: ${entity.baseLocation}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified, color: Colors.green),
        ],
      ),
    );
  }
}
