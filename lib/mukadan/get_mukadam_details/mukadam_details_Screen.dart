import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'mukadam_model.dart';
final String _baseUrl = 'https://supply.bharatintelligence.ai/api/mukkadam/';

class MukadamListScreen extends StatefulWidget {
  const MukadamListScreen({super.key});

  @override
  State<MukadamListScreen> createState() => _MukadamListScreenState();
}

class _MukadamListScreenState extends State<MukadamListScreen> {
  late Future<List<Mukadam>> futureMukadams;

  @override
  void initState() {
    super.initState();
    futureMukadams = fetchMukadams();
  }

  Future<List<Mukadam>> fetchMukadams() async {
    final response = await http.get(Uri.parse('${_baseUrl}dropdown_list/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((mukadam) => Mukadam.fromJson(mukadam)).toList();
    } else {
      print(response.body);
      throw Exception('Failed to load mukadams from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mukadam List'),
      ),
      body: FutureBuilder<List<Mukadam>>(
        future: futureMukadams,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final mukadam = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(mukadam.mukkadamName),
                    subtitle: Text('${mukadam.village} - ${mukadam.mobileNumbers}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MukadamDetailScreen(mukadam: mukadam),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No mukadams found.'));
          }
        },
      ),
    );
  }
}

// Mukadam Detail Screen to display individual mukadam details and handle backend interactions
class MukadamDetailScreen extends StatelessWidget {
  final Mukadam mukadam;

  const MukadamDetailScreen({super.key, required this.mukadam});

  // Example for handling a backend interaction (e.g., updating a mukadam)
  Future<void> updateMukadam(BuildContext context, Mukadam updatedMukadam) async {
    final response = await http.put(
      Uri.parse('${_baseUrl}${updatedMukadam.id}/'), // Replace with your actual update endpoint
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'mukkadam_name': updatedMukadam.mukkadamName,
        'mobile_numbers': updatedMukadam.mobileNumbers,
        'village': updatedMukadam.village,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mukadam updated successfully!')),
      );
      // You might want to navigate back or refresh the list after update
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update mukadam: ${response.statusCode}')),
      );
      throw Exception('Failed to update mukadam');
    }
  }

  // Example for handling another backend interaction (e.g., deleting a mukadam)
  Future<void> deleteMukadam(BuildContext context, int mukadamId) async {
    final response = await http.delete(
      Uri.parse('${_baseUrl}$mukadamId/'), // Replace with your actual delete endpoint
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 204) { // 204 No Content is common for successful DELETE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mukadam deleted successfully!')),
      );
      Navigator.pop(context); // Go back to the list screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete mukadam: ${response.statusCode}')),
      );
      throw Exception('Failed to delete mukadam');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mukadam.mukkadamName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement edit functionality, e.g., navigate to an edit form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit functionality placeholder')),
              );
              // Example of how to call updateMukadam:
              // updateMukadam(context, Mukadam(id: mukadam.id, mukkadamName: 'New Name', mobileNumbers: 'New Number', village: 'New Village'));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Implement delete functionality
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Delete Mukadam'),
                    content: Text('Are you sure you want to delete ${mukadam.mukkadamName}?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          deleteMukadam(context, mukadam.id); // Call the delete function
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${mukadam.id}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Name: ${mukadam.mukkadamName}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Mobile: ${mukadam.mobileNumbers}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Village: ${mukadam.village}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            // Placeholder for more complex backend interactions or related data display
            Text(
              'This screen can handle further backend interactions related to ${mukadam.mukkadamName}.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You can add forms for editing, buttons for specific actions, or display more detailed data fetched from another endpoint using the mukadam.id.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
