import 'package:flutter/material.dart';
import 'package:mukadam_bi/verifications/transporter_verifcations/verification_model.dart';
import 'package:mukadam_bi/verifications/transporter_verifcations/verificatrion_service.dart';
import 'package:provider/provider.dart';
import '../../mukadan/authentication/userProvider.dart';
import '../transporter_update_screen.dart';




class PendingVerificationListScreen extends StatefulWidget {
  const PendingVerificationListScreen({super.key});

  @override
  State<PendingVerificationListScreen> createState() => _PendingVerificationListScreenState();
}

class _PendingVerificationListScreenState extends State<PendingVerificationListScreen> {
  late Future<List<VerificationEntity>> _futureVerifications;
  final VerificationService _service = VerificationService();
  String _searchQuery = ""; // Added search query state

  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  void _loadVerifications() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final int userId = userProvider.user?.id ?? 29;
    setState(() {
      _futureVerifications = _service.fetchPendingVerifications(userId);
    });
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
      body: Column(
        children: [
          // Added Search Bar like TransportDirectoryScreen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.05),
                //     blurRadius: 10,
                //     offset: const Offset(0, 4),
                //   ),
                // ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<VerificationEntity>>(
              future: _futureVerifications,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {

                  return const Center(child: CircularProgressIndicator());

                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No pending verifications found.'));
                }

                // Filter logic for search
                final filteredEntities = snapshot.data!.where((item) {
                  return item.entity.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredEntities.isEmpty) {
                  return const Center(child: Text("No matching verifications found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  itemCount: filteredEntities.length,
                  itemBuilder: (context, index) {
                    final item = filteredEntities[index];
                    final transporter = item.entity;

                    final firstVerif = item.verifications.isNotEmpty ? item.verifications.first : null;
                    bool anyVerified = (firstVerif?.isAadhaarVerified ?? false) ||
                        (firstVerif?.isPanVerified ?? false) ||
                        (firstVerif?.isRcVerified ?? false) ||
                        (firstVerif?.isDlVerified ?? false);

// Determine Status and Color
                    String statusText = anyVerified ? "Pending" : "Not Verified";
                    Color themeColor = anyVerified ? Colors.orange : Colors.red;


                    return InkWell(
                      onTap: () async {
                        bool? updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransporterUpdateScreen(transporterId: transporter.id),
                          ),
                        );

                        if (updated == true) {

                          _loadVerifications();

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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Verification Status",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: themeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: themeColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: themeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: item.verifications.map((v) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      v.typeDisplay,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
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
          ),
        ],
      ),
    );
  }
}
