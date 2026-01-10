import 'dart:async';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mukadam_Screen.dart';
import 'mukadan/authentication/screens/sendOtpScreen.dart';
import 'mukadan/authentication/userProvider.dart';





class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {

  bool _isChecking = true;
  String _errorMessage = "";
  String _failedPermission = "";
  bool _isXiaomi = false;

  final List<Permission> _requiredPermissions = [
    Permission.contacts,
    Permission.sms,
    Permission.phone,
    Permission.notification,
    Permission.microphone,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkDeviceManufacturer();
    _initializeApp(shouldRequest: true);
  }

  Future<void> _checkDeviceManufacturer() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      setState(() {
        _isXiaomi = androidInfo.manufacturer.toLowerCase().contains("xiaomi") ||
            androidInfo.brand.toLowerCase().contains("poco");
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _initializeApp(shouldRequest: false);
      });
    }
  }

  Future<void> _initializeApp({required bool shouldRequest}) async {
    if (!mounted) return;

    setState(() {
      _isChecking = true;
      _errorMessage = "";
      _failedPermission = "";
    });

    try {
      // 1. Check Base Permissions
      for (var p in _requiredPermissions) {
        var status = await p.status;
        if (!status.isGranted) {
          if (shouldRequest) status = await p.request();
          if (!status.isGranted) {
            _setDenied("Please allow ${p.toString().split('.').last.toUpperCase()} permission.", p.toString());
            return;
          }
        }
      }

      // 2. Check Location Always
      bool locAlways = await _verifyLocationAlways(shouldRequest);
      if (!locAlways) {
        _setDenied("Location must be set to 'Allow all the time'.", "Location Always");
        return;
      }

      // 3. Check Battery Optimization
      bool isBatteryUnrestricted = await Permission.ignoreBatteryOptimizations.isGranted;
      if (!isBatteryUnrestricted) {
        if (shouldRequest) await Permission.ignoreBatteryOptimizations.request();
        isBatteryUnrestricted = await Permission.ignoreBatteryOptimizations.isGranted;
        if (!isBatteryUnrestricted) {
          _setDenied("Battery usage must be set to 'Unrestricted'.", "Battery Optimization");
          return;
        }
      }

      // 4. Xiaomi Specific: Auto-Start Check
      if (_isXiaomi) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        bool hasEnabledAutoStart = prefs.getBool('auto_start_done') ?? false;

        if (!hasEnabledAutoStart) {
          _setDenied("Auto-start must be enabled for background tracking.", "Poco/Xiaomi Optimization");
          return;
        }
      }

      _proceedToNextScreen();
    } catch (e) {
      _setDenied("Initialization failed. Check settings manually.", "Error");
    }
  }

  void _openAutoStartSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'miui.intent.action.OP_AUTO_START',
        componentName: 'com.miui.securitycenter/com.miui.permcenter.autostart.AutoStartManagementActivity',
      );
      try {
        await intent.launch();
      } catch (e) {
        openAppSettings();
      }
    }
  }

  Future<bool> _verifyLocationAlways(bool shouldRequest) async {
    var status = await Permission.location.status;
    if (!status.isGranted && shouldRequest) status = await Permission.location.request();
    if (!status.isGranted) return false;

    var alwaysStatus = await Permission.locationAlways.status;
    if (!alwaysStatus.isGranted && shouldRequest) alwaysStatus = await Permission.locationAlways.request();
    return alwaysStatus.isGranted;
  }

  void _setDenied(String message, String permissionName) {
    if (mounted) {
      setState(() {
        _isChecking = false;
        _errorMessage = message;
        _failedPermission = permissionName;
      });
    }
  }

  Future<void> _proceedToNextScreen() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadSavedUser();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => userProvider.isAuthenticated
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/company.jpeg', width: 200),
              const SizedBox(height: 60),
              if (_isChecking)
                const CircularProgressIndicator(color: Colors.blue)
              else
                _buildRequirementUI(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementUI() {
    return Column(
      children: [
        const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
        const SizedBox(height: 20),
        Text(
          _failedPermission,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 10),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 40),
        if (_isXiaomi && _failedPermission == "Poco/Xiaomi Optimization")
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () async {
              // CRITICAL: Set the flag to true here so that the app knows you've clicked it
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('auto_start_done', true);
              _openAutoStartSettings();
            },
            child: const Text("ENABLE AUTO-START", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          onPressed: () => openAppSettings(),
          child: const Text("OPEN APP SETTINGS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => _initializeApp(shouldRequest: true),
          child: const Text("I've Enabled All - Check Again"),
        ),
      ],
    );
  }
}
