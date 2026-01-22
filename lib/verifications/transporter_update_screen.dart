import 'package:flutter/material.dart';
import 'package:mukadam_bi/verifications/transporter_verifcations/verificatrion_service.dart';

class TransporterUpdateScreen extends StatefulWidget {
  final int transporterId;

  const TransporterUpdateScreen({super.key, required this.transporterId});

  @override
  State<TransporterUpdateScreen> createState() => _TransporterUpdateScreenState();
}

class _TransporterUpdateScreenState extends State<TransporterUpdateScreen> {
  final VerificationService _service = VerificationService();

  final TextEditingController _dlController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();

  bool _isLoading = true;
  String _name = "";

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    try {
      final data = await _service.fetchTransporterDetails(widget.transporterId);
      setState(() {
        _name = data['name'] ?? 'Transporter';
        _dlController.text = data['dl_number'] ?? '';
        _vehicleController.text = data['vehicle_number'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    }
  }

  void _handleUpdate() async {
    setState(() => _isLoading = true);

    final updateData = {
      "dl_number": _dlController.text.trim(),
      "vehicle_number": _vehicleController.text.trim(),
    };

    bool success = await _service.updateTransporter(widget.transporterId, updateData);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated Successfully")));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update details")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Update $_name", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Transporter Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _dlController,
              decoration: InputDecoration(
                labelText: "DL Number",
                prefixIcon: const Icon(Icons.badge), // Fixed: Changed from id_card to badge
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vehicleController,
              decoration: InputDecoration(
                labelText: "Vehicle Number",
                prefixIcon: const Icon(Icons.local_shipping),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _handleUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Update Transporter", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
