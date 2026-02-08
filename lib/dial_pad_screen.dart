import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mukadam_bi/mukadan/authentication/userProvider.dart'; // Adjust path
import 'package:mukadam_bi/notes/visitApiService.dart'; // Adjust path
import 'package:mukadam_bi/call_stack.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notes/visitPlanModel.dart'; // Adjust path for CallApiService

class DialPadScreen extends StatefulWidget {
  const DialPadScreen({super.key});

  @override
  State<DialPadScreen> createState() => _DialPadScreenState();
}

class _DialPadScreenState extends State<DialPadScreen> {
  String _displayNumber = "";
  bool _isLoading = false;

  void _onKeyPress(String value) {
    setState(() {
      if (_displayNumber.length < 10) {
        _displayNumber += value;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_displayNumber.isNotEmpty) {
        _displayNumber = _displayNumber.substring(0, _displayNumber.length - 1);
      }
    });
  }

  //deploy+testing now

  Future<void> _makeCustomCall() async {
    if (_displayNumber.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // 1. Fetch the central team number (from number)
      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final visitPlans = await VisitApiService().fetchTodayVisits(todayDate);

      final String toNumber = _displayNumber;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String userMobile = userProvider.user?.mobileNumber ?? "";
      final prefs = await SharedPreferences.getInstance();

      final int? userId = prefs.getInt('bg_user_id');

      // 2. Execute the call via your API Service
      final response = await CallApiService.makeCall(
          fromNumber: userMobile,
          toNumber: toNumber,
          userId: userId
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Call initiated to $toNumber"), backgroundColor: Colors.green),
        );
      } else {
        throw Exception(response['message'] ?? "Failed to initiate call");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Column(
            children: [
              const Spacer(),
              // Display Area with +91 prefix
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [

                    Text(
                      _displayNumber.isEmpty ? "" : _displayNumber,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Dial Pad Grid
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      _buildDialRow(["1", "2", "3"]),
                      _buildDialRow(["4", "5", "6"]),
                      _buildDialRow(["7", "8", "9"]),
                      _buildDialRow(["*", "0", "#"]),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 64), // Spacer
                          _buildCallButton(),
                          _buildBackspaceButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialRow(List<String> keys) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildDialButton(key)).toList(),
      ),
    );
  }

  Widget _buildDialButton(String value) {
    return InkWell(
      onTap: () => _onKeyPress(value),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton() {
    return InkWell(
      onTap: _isLoading ? null : _makeCustomCall,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: _isLoading
            ? const Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        )
            : const Icon(Icons.phone, color: Colors.white, size: 35),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return IconButton(
      onPressed: _onBackspace,
      icon: const Icon(Icons.backspace_outlined, color: Colors.grey, size: 30),
    );
  }
}
