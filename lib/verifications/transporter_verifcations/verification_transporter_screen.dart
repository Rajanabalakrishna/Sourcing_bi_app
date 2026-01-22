import 'package:flutter/material.dart';
import 'package:mukadam_bi/verifications/transporter_verifcations/verification_model.dart';
import 'package:mukadam_bi/verifications/transporter_verifcations/verificatrion_service.dart';
import 'package:provider/provider.dart';
import '../../mukadan/authentication/userProvider.dart';
import '../transporter_update_screen.dart';
// Import the update screen
//import 'transporter_update_screen.dart';

class PendingVerificationListScreen extends StatefulWidget {
  const PendingVerificationListScreen({super.key});

  @override
  State<PendingVerificationListScreen> createState() => _PendingVerificationListScreenState();
}

class _PendingVerificationListScreenState extends State<PendingVerificationListScreen> {
  late Future<List<VerificationEntity>> _futureVerifications;
  final VerificationService _service = VerificationService();

  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  void _loadVerifications() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final int userId = userProvider.user?.id ?? 29;
    _futureVerifications = _service.fetchPendingVerifications(userId);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'not_started':
        return Colors.orange.shade700;
      case 'pending':
        return Colors.blue.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pending Verifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<List<VerificationEntity>>(
        future: _futureVerifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending verifications found.'));
          }

          final entities = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: entities.length,
            itemBuilder: (context, index) {
              final item = entities[index];
              final transporter = item.entity;

              return InkWell(
                onTap: () async {
                  bool? updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransporterUpdateScreen(transporterId: transporter.id),
                    ),
                  );

                  if (updated == true) {
                    setState(() {
                      _loadVerifications();
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                transporter.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                transporter.vehicleType ?? 'Transporter',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              transporter.contactNumber,
                              style: TextStyle(color: Colors.grey[700], fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                transporter.baseLocation,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        const Text(
                          "Verification Status",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: item.verifications.map((v) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(v.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getStatusColor(v.status).withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.info_outline, size: 14, color: _getStatusColor(v.status)),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${v.typeDisplay}: ${v.status.replaceAll('_', ' ')}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _getStatusColor(v.status),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
