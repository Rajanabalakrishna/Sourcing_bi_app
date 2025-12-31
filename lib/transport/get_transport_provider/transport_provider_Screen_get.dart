// // transport_provider_screen.dart
// import 'package:flutter/material.dart';
// import 'package:mukadam_bi/transport/get_transport_provider/transport_provider_service.dart';
//
// import '../Transport_provider/transport_model.dart';
// //import 'package:your_app_name/transport_service.dart'; // Make sure this path is correct
//
// class TransportProviderScreenGet extends StatefulWidget {
//   const TransportProviderScreenGet({super.key});
//
//   @override
//   State<TransportProviderScreenGet> createState() => _TransportProviderScreenState();
// }
//
// class _TransportProviderScreenState extends State<TransportProviderScreenGet> {
//   final TextEditingController _idController = TextEditingController();
//   TransportProvider? _transportProvider;
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   Future<void> _searchTransportProvider() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _transportProvider = null;
//     });
//
//     try {
//       final int? id = int.tryParse(_idController.text);
//       if (id == null) {
//         throw Exception('Please enter a valid ID.');
//       }
//
//       final TransportService transportService = TransportService();
//       final TransportProvider provider = await transportService.getTransportProvider(id);
//
//       setState(() {
//         _transportProvider = provider;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString().replaceFirst('Exception: ', '');
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Transport Provider Details'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _idController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Enter Transport Provider ID',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _searchTransportProvider,
//               child: _isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Search'),
//             ),
//             const SizedBox(height: 24.0),
//             if (_errorMessage != null)
//               Text(
//                 _errorMessage!,
//                 style: const TextStyle(color: Colors.red, fontSize: 16.0),
//                 textAlign: TextAlign.center,
//               ),
//             if (_transportProvider != null)
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Card(
//                     elevation: 4.0,
//                     margin: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildDetailRow('ID:', _transportProvider!.id?.toString() ?? 'N/A'),
//                           _buildDetailRow('Name:', _transportProvider!.name),
//                           _buildDetailRow('Contact Number:', _transportProvider!.contactNumber ?? 'N/A'),
//                           _buildDetailRow('Base Location:', _transportProvider!.baseLocation),
//                           _buildDetailRow('Max Distance:', '${_transportProvider!.maxDistance} km'),
//                           _buildDetailRow('Vehicle Type:', _transportProvider!.vehicleType),
//                           _buildDetailRow('Active:', _transportProvider!.isActive ? 'Yes' : 'No'),
//                           _buildDetailRow('Notes:', _transportProvider!.notes),
//                           _buildDetailRow(
//                             'Created At:',
//                             _transportProvider!.createdAt?.toLocal().toString().split('.')[0] ?? 'N/A',
//                           ),
//                           _buildDetailRow(
//                             'Updated At:',
//                             _transportProvider!.updatedAt?.toLocal().toString().split('.')[0] ?? 'N/A',
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//             SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }
// }
