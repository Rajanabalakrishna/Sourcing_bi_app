

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mukadam_Screen.dart';
import 'mukadan/authentication/screens/sendOtpScreen.dart';
import 'mukadan/get_mukadam_details/mukadam_details_Screen.dart';




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();

  }

  Future<void> _navigateToNext() async {
    // Wait for the splash duration
    await Future.delayed(const Duration(seconds: 3));

    // Check SharedPreferences for auth status
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn
              ? const MukadamDashboard()
              : const PhoneEntryScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 20),
            Image.asset(
              'assets/images/company.jpeg',
              width: 280,
            ),
            const SizedBox(height: 80),


            const CircularProgressIndicator(
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
