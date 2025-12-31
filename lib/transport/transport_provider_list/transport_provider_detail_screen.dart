// // File: lib/screens/transport_provider_detail_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:mukadam_bi/transport/transport_provider_list/transport_delete_service.dart';
// import '../Transport_provider/transport_model.dart'; // Adjust this import path if necessary
// import 'transport_provider_edit_screen.dart'; // Import the new edit screen
// //import '../Transport_provider/transport_delete_service.dart'; // Import the new delete service
//
// class TransportProviderDetailScreen extends StatefulWidget {
//   final TransportProvider provider;
//
//   const TransportProviderDetailScreen({super.key, required this.provider});
//
//   @override
//   State<TransportProviderDetailScreen> createState() => _TransportProviderDetailScreenState();
// }
//
// class _TransportProviderDetailScreenState extends State<TransportProviderDetailScreen> {
//   late TransportProvider _currentProvider;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentProvider = widget.provider;
//   }
//
//   Future<void> _confirmAndDelete() async {
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Transport Provider'),
//           content: Text('Are you sure you want to delete ${_currentProvider.name}? This action cannot be undone.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false), // User cancels
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true), // User confirms
//               child: const Text('Delete', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (confirm == true) {
//       try {
//         await TransportDeleteService().deleteTransportProvider(_currentProvider.id!);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Transport Provider deleted successfully!')),
//           );
//           Navigator.of(context).pop(true); // Pop with true to indicate deletion
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to delete Transport Provider: $e')),
//           );
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_currentProvider.name),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () async {
//               final result = await Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => TransportProviderEditScreen(provider: _currentProvider),
//                 ),
//               );
//
//               if (result == true) {
//                 // In a real application, you might re-fetch the provider details
//                 // or pass the updated provider back from the edit screen.
//                 print('Provider details might have been updated. Consider refreshing.');
//                 // For demonstration, we'll just show a confirmation.
//                 // If the edit screen passed back the updated provider, you would do:
//                 // setState(() { _currentProvider = updatedProvider; });
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: _confirmAndDelete, // Call the delete function
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Placeholder for transport image
//             Center(
//               child: Container(
//                 width: double.infinity,
//                 height: 200,
//                 color: Colors.grey[300],
//                 child: const Icon(
//                   Icons.image,
//                   size: 100,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _currentProvider.name,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueAccent,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildDetailRow('Location', _currentProvider.baseLocation),
//             _buildDetailRow('Contact', _currentProvider.contactNumber ?? 'N/A'),
//             _buildDetailRow('Max Distance', '${_currentProvider.maxDistance} km'),
//             _buildDetailRow('Vehicle Type', _currentProvider.vehicleType),
//             _buildDetailRow('Active', _currentProvider.isActive ? 'Yes' : 'No'),
//             if (_currentProvider.notes.isNotEmpty) _buildDetailRow('Notes', _currentProvider.notes),
//             if (_currentProvider.createdAt != null)
//               _buildDetailRow('Created', _currentProvider.createdAt!.toLocal().toString().split(' ')[0]),
//             if (_currentProvider.updatedAt != null)
//               _buildDetailRow('Updated', _currentProvider.updatedAt!.toLocal().toString().split(' ')[0]),
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
//           SizedBox(
//             width: 120, // Adjust width as needed
//             child: Text(
//               '$label:',
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
