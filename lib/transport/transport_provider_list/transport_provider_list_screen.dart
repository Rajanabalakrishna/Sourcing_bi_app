// File: lib/screens/transport_provider_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:mukadam_bi/transport/transport_provider_list/transport_provider_list_service.dart'; // Adjust this import path if necessary
import '../Transport_provider/transport_model.dart'; // Adjust this import path if necessary
import 'transport_provider_detail_screen.dart'; // Import the new detail screen

// Color Palette Constants (Tailwind equivalents)
class AppColors {
  static const primary = Color(0xFF6366F1);
  static const backgroundLight = Color(0xFFF3F4F6);
  static const cardLight = Colors.white;
  static const textLight = Color(0xFF1F2937);
  static const subtextLight = Color(0xFF6B7280);
  static const borderLight = Color(0xFFE5E7EB);
}

class TransportProviderListScreen extends StatefulWidget {
  const TransportProviderListScreen({super.key});

  @override
  State<TransportProviderListScreen> createState() => _TransportProviderListScreenState();
}

class _TransportProviderListScreenState extends State<TransportProviderListScreen> {
  late Future<List<TransportProvider>> _transportProviders;
  final TransportProviderListService _service = TransportProviderListService();

  // Controllers for input fields
  final TextEditingController _baseLocationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isActive = true; // Default value for is_active
  String? _selectedOrdering; // Default to null, or provide an initial value like 'name'

  final List<String> _orderingOptions = [
    'name',
    'max_distance',
    'base_location'
  ];

  @override
  void initState() {
    super.initState();
    _fetchProviders(); // Fetch initial list without filters
  }

  @override
  void dispose() {
    _baseLocationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchProviders() {
    setState(() {
      _transportProviders = _service.fetchTransportProviders(
        baseLocation: _baseLocationController.text.isNotEmpty ? _baseLocationController.text : null,
        isActive: _isActive,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        ordering: _selectedOrdering,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450), // Emulating mobile view
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                )
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildFilterCard(),
                      const SizedBox(height: 24),
                      FutureBuilder<List<TransportProvider>>(
                        future: _transportProviders,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Error loading providers: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            );
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No transport providers found.'));
                          } else {
                            return Column(
                              children: snapshot.data!.map((provider) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TransportProviderDetailScreen(provider: provider),
                                        ),
                                      );
                                    },
                                    child: _buildProviderCard(
                                      name: provider.name,
                                      location: provider.baseLocation,
                                      vehicle: provider.vehicleType,
                                      distance: '${provider.maxDistance} km',
                                      notes: provider.notes.isNotEmpty ? provider.notes : null,
                                      isActive: provider.isActive,
                                      createdAt: provider.createdAt,
                                      updatedAt: provider.updatedAt,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardLight, // Changed from backgroundLight for better contrast
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Handle back action, e.g., Navigator.pop(context) if applicable
            },
            icon: const Icon(Icons.arrow_back),
          ),
          const Expanded(
            child: Text(
              "Transport Providers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight),
            ),
          ),
          IconButton(onPressed: _fetchProviders, icon: const Icon(Icons.refresh)),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildInput(Icons.location_on_outlined, "Base Location", _baseLocationController),
          const SizedBox(height: 12),
          _buildInput(Icons.search, "Search (Name or Location)", _searchController),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("Is Active", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isActive,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOrdering,
                    hint: const Text("Order by: Select", style: TextStyle(fontSize: 13, color: AppColors.subtextLight)),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOrdering = newValue;
                      });
                    },
                    items: _orderingOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    style: const TextStyle(color: AppColors.textLight),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.subtextLight),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _fetchProviders,
              icon: const Icon(Icons.filter_list, size: 18),
              label: const Text("Apply Filters"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(IconData icon, String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    required String name,
    required String location,
    required String vehicle,
    required String distance,
    String? notes,
    required bool isActive,
    Color accentColor = AppColors.primary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.7,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: accentColor)),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 14, color: AppColors.subtextLight),
                        Text(location, style: const TextStyle(fontSize: 12, color: AppColors.subtextLight)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? "Active" : "Inactive",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.green[800] : Colors.grey[700]),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoBit("Vehicle Type", Icons.local_shipping, vehicle),
                const SizedBox(width: 24),
                _buildInfoBit("Max Distance", Icons.map, distance),
              ],
            ),
            if (notes != null) ...[
              const SizedBox(height: 12),
              const Text("Notes", style: TextStyle(fontSize: 11, color: AppColors.subtextLight)),
              Text(notes, style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.3)),
            ],
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (createdAt != null)
                      Text("Created: ${createdAt.toLocal().toString().split(' ')[0]}", style: const TextStyle(fontSize: 10, color: AppColors.subtextLight)),
                    if (updatedAt != null)
                      Text("Updated: ${updatedAt.toLocal().toString().split(' ')[0]}", style: const TextStyle(fontSize: 10, color: AppColors.subtextLight)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.chevron_right, size: 18, color: AppColors.subtextLight),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBit(String label, IconData icon, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.subtextLight)),
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.cardLight,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.local_shipping, "Providers", isSelected: true),
          _navItem(Icons.history, "History"),
          _navItem(Icons.person, "Profile"),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? AppColors.primary : Colors.grey[400]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : Colors.grey[400])),
      ],
    );
  }
}

// You might also need to update your main.dart or the entry point of your app
// to use GoogleFonts and the new AppColors theme if it's not already set up globally.
// Example:
// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         textTheme: GoogleFonts.interTextTheme(),
//       ),
//       home: const TransportProviderListScreen(), // Set your refactored screen as home
//     );
//   }
// }
