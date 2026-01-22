import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';
import 'package:mukadam_bi/call_stack.dart';
import 'package:mukadam_bi/plans/allPlansScreen.dart';
import 'package:mukadam_bi/referral/user_referral_mukadam_screen.dart';
import 'package:mukadam_bi/sms/sms_service.dart';
import 'package:mukadam_bi/sqflite/local_db.dart';
import 'package:mukadam_bi/tracking%20control/tracking_control_screen.dart';

// Your existing imports
import 'package:mukadam_bi/transport/Transport_provider/transport_provider_Screen.dart';
//import 'package:mukadam_bi/transport/transport_provider_list/transport_provider_list_screen.dart';
import 'package:mukadam_bi/verifications/mukadam_dashboard/mukadam_dashborad.dart';
import 'package:mukadam_bi/verifications/transporter_verifcations/verification_transporter_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contacts/contact_service.dart';
import 'dial_pad_screen.dart';
import 'fetch call logs/call_log_service.dart';
import 'firebase_message.dart';
import 'getTransport/gettransportscreen.dart';
import 'map/location_api_service.dart';
import 'mukadan/authentication/screens/sendOtpScreen.dart';
import 'mukadan/authentication/userProvider.dart';
import 'mukadan/quick_registration/quick_registration_Screen.dart';
import 'mukadan/registration/mukadam_registration_Screen.dart';
import 'notes/end_Screen.dart';
import 'notes/todo_screen.dart';
import 'notes/visitApiService.dart'; // Assuming this contains DataEntryScreen

class MukadamDashboard extends StatefulWidget {
  const MukadamDashboard({super.key});

  @override
  State<MukadamDashboard> createState() => _MukadamDashboardState();
}

class _MukadamDashboardState extends State<MukadamDashboard> {
  int _selectedIndex = 0;

  // List of widgets to display for each tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildDashboardContent(), // Modern Grid View
     const DataEntryScreen(),
    ];
    //_checkAndFetchCallLogs();
    _setupFCM();
    _syncAllData();
    _checkAndSyncOldLocationData();// Your existing Data Entry Screen

  }

  // //test data
  // Future<void> _checkAndSyncOldLocationData() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //
  //     // 1. Get current date
  //     final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //
  //     // --- TEST DATA START ---
  //     // Commenting out real DB fetch
  //     // final dbHelper = DatabaseHelper.instance;
  //     // List<Map<String, dynamic>> localData = await dbHelper.getAllLocations();
  //
  //     // Fake Data for testing
  //     String oldestRecordDate = "2024-01-01"; // Fake old date to trigger sync
  //     List<Map<String, dynamic>> localData = [
  //       {
  //         'latitude': 12.9716,
  //         'longitude': 77.5946,
  //         'date': "2024-01-01",
  //         'time': "10:30:00" // Changed from "10:30 AM"
  //       },
  //       {
  //         'latitude': 12.9717,
  //         'longitude': 77.5947,
  //         'date': "2024-01-01",
  //         'time': "10:35:00" // Changed from "10:35 AM"
  //       }
  //     ];
  //
  //     // --- TEST DATA END ---
  //
  //     if (localData.isNotEmpty) {
  //       // 3. If the date is NOT today, it's old data from a previous day
  //       if (oldestRecordDate != todayDate) {
  //         print("⏳ [TEST SYNC] Triggering sync with FAKE data from $oldestRecordDate...");
  //
  //         final Map<String, dynamic> payload = {
  //           "user_id": userProvider.user?.id ?? 0,
  //           "today_date": todayDate,
  //           "locations": localData.map((loc) => {
  //             "latitude": loc['latitude'],
  //             "longitude": loc['longitude'],
  //             "date": loc['date'],
  //             "time": loc['time']
  //           }).toList(),
  //         };
  //
  //         // 4. Hit the API
  //         await LocationApiService.postLocation(payload);
  //
  //         // 5. SUCCESS: (Commented out clearLocations to avoid losing real data while testing)
  //         // await dbHelper.clearLocations();
  //         await prefs.setString("last_successful_sync_date", todayDate);
  //
  //         print("🚀 [TEST SYNC] Fake data hit API successfully.");
  //       } else {
  //         print("ℹ️ [TEST SYNC] Date matches today, no sync triggered.");
  //       }
  //     }
  //   } catch (e) {
  //     print("❌ [TEST SYNC] Failed to hit API: $e");
  //   }
  // }




  //real data

  Future<void> _checkAndSyncOldLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 1. Fetch REAL data from local database
      final dbHelper = DatabaseHelper.instance;
      List<Map<String, dynamic>> localData = await dbHelper.getAllLocations();

      if (localData.isNotEmpty) {
        // Get the date of the oldest record to check if it's from a previous day
        String oldestRecordDate = localData.first['date'];

        if (oldestRecordDate != todayDate) {
          print("⏳ [SYNC] Triggering sync with real data from $oldestRecordDate...");

          final Map<String, dynamic> payload = {
            "user_id": userProvider.user?.id ?? 0,
            "today_date": todayDate,
            "locations": localData.map((loc) {
              // 2. Convert "10:30 AM" to "10:30:00" for Django backend
              String rawTime = loc['time'];
              String formattedTime = rawTime;

              try {
                // Parses "10:30 AM" and formats to "10:30:00"
                DateTime parsedTime = DateFormat.jm().parse(rawTime);
                formattedTime = DateFormat("HH:mm:ss").format(parsedTime);
              } catch (e) {
                print("Time parsing error: $e");
              }

              return {
                "latitude": loc['latitude'],
                "longitude": loc['longitude'],
                "date": loc['date'],
                "time": formattedTime
              };
            }).toList(),
          };

          // 4. Hit the API
          await LocationApiService.postLocation(payload);

          // 5. SUCCESS: Clear local DB and update sync flag
          await dbHelper.clearLocations();
          await prefs.setString("last_successful_sync_date", todayDate);

          print("🚀 [DASHBOARD SYNC] Old data synced and cleared successfully.");
        } else {
          print("ℹ️ [DASHBOARD SYNC] Data in DB is from today. Waiting for background schedule.");
        }
      }
    } catch (e) {
      print("❌ [DASHBOARD SYNC] Failed to sync old data: $e");
    }
  }

  bool _isCalling = false;


  //this is deployment+testing side


  Future<void> _initiateCall() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String userMobile = userProvider.user?.mobileNumber ?? "";

    if (userMobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User mobile number not found")),
      );
      return;
    }

    setState(() => _isCalling = true);

    try {
      // 1. Get today's date and fetch plans to get the central team number
      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final visitPlans = await VisitApiService().fetchTodayVisits(todayDate);

      if (visitPlans.isEmpty) {
        throw Exception("No plans found for today to fetch central team number.");
      }

      // 2. Get the central team phone from the first plan
      // Assuming your VisitPlan model has a field 'centralTeamPhone' mapped to 'central_team_phone'
      final String centralPhone = visitPlans.first.centralTeamPhone ?? "+91-804-7361521";

      print("Central Team Phone: $centralPhone");

      if (centralPhone.isEmpty) {
        throw Exception("Central team phone number not available in today's plan.");
      }

      final prefs = await SharedPreferences.getInstance();

      final int? userId = prefs.getInt('bg_user_id');

      // 3. Initiate Call
      // As requested: fromNumber = central team phone, toNumber = user provider number
      final response = await CallApiService.makeCall(
        fromNumber: centralPhone,
        toNumber: userMobile,
        userId:userId
      );



      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Call initiated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response['message'] ?? "Failed to initiate call");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCalling = false);
      }
    }
  }



  //after deploy

  // Future<void> _initiateCall() async {
  //   final userProvider = Provider.of<UserProvider>(context, listen: false);
  //   final String userMobile = userProvider.user?.mobileNumber ?? "";
  //
  //   if (userMobile.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("User mobile number not found")),
  //     );
  //     return;
  //   }
  //
  //   setState(() => _isCalling = true);
  //
  //   try {
  //     final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //
  //     // 1. Fetch plans (this updates SharedPreferences)
  //     await VisitApiService().fetchTodayVisits(todayDate);
  //
  //     // 2. Get the number from SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();
  //     final String? centralPhone = prefs.getString("centralPhone");
  //
  //     if (centralPhone == null || centralPhone.isEmpty) {
  //       throw Exception("Central team phone number not found.");
  //     }
  //
  //     // 3. Initiate Call
  //     final response = await CallApiService.makeCall(
  //       fromNumber: centralPhone,
  //       toNumber: userMobile,
  //     );
  //
  //     if (response['success'] == true) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(response['message'] ?? "Call initiated successfully"),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     } else {
  //       throw Exception(response['message'] ?? "Failed to initiate call");
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(e.toString().replaceAll("Exception: ", "")),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isCalling = false);
  //     }
  //   }
  // }




  Future<void> _setupFCM() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user != null) {
      print('--- INITIALIZING FCM ON DASHBOARD ---');
      await FirebaseMsg().initFCM(
        userProvider.user!.id.toString(),
        userProvider.user!.mobileNumber.toString(),
      );
    }
  }

  Future<void> _syncAllData() async {
    // 1. Request all permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.contacts,
      Permission.sms,
    ].request();

    // --- CALL LOGS ---
    if (statuses[Permission.phone]!.isGranted) {
      print('--- FETCHING CALL LOGS ---');
      Iterable<CallLogEntry> entries = await CallLog.get();
      if (entries.isEmpty) print('No call logs found on device.');
      for (var entry in entries.take(5)) {
        print('Call: ${entry.name} (${entry.number})');
      }
      await CallLogService().syncCallLogs(context);
    } else {
      print('Call Log Permission Denied');
    }

    // --- CONTACTS ---
    if (statuses[Permission.contacts]!.isGranted) {
      print('--- FETCHING CONTACTS ---');
      // Double check with the specific contact plugin permission
      bool contactPermission = await FlutterContacts.requestPermission(readonly: true);
      if (contactPermission) {
        List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);

        if (contacts.isEmpty) {
          print('No contacts found on this device.');
        } else {
          print('Found ${contacts.length} contacts. Printing first 5:');
          for (var contact in contacts.take(5)) {
            print('Contact: ${contact.displayName} - ${contact.phones.firstOrNull?.number}');
          }
          await ContactService().syncContacts(context);
        }
      } else {
        print('FlutterContacts plugin internal permission denied.');
      }
    }

    // --- SMS MESSAGES ---
    if (statuses[Permission.sms]!.isGranted) {
      print('--- FETCHING SMS MESSAGES ---');
      SmsQuery query = SmsQuery();
      List<SmsMessage> messages = await query.getAllSms;
      if (messages.isEmpty) print('No SMS found on device.');
      for (var msg in messages.take(5)) {
        print('SMS from ${msg.address}: ${msg.body?.substring(0, 20)}...');
      }
      await SmsService().syncSms(context);
    }

    print("--- ALL DATA SYNC PROCESSES COMPLETED ---");
  }


  Future<void> _checkAndFetchCallLogs() async {
    // 1. Request Phone/Call Log Permission
    PermissionStatus status = await Permission.phone.request();

    if (status.isGranted) {
      // 2. Fetch and Print Call Logs
      Iterable<CallLogEntry> entries = await CallLog.get();

      print('--- CALL LOG DATA FETCHED ---');
      for (CallLogEntry entry in entries) {
        print('Name: ${entry.name}');
        print('Number: ${entry.number}');
        print('Type: ${entry.callType}');
        print('Duration: ${entry.duration} sec');
        print('Date: ${DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)}');
        print('-------------------------------');
      }

      await CallLogService().syncCallLogs(context);


    } else if (status.isDenied) {
      print('Call log permission was denied by the user.');
    } else if (status.isPermanentlyDenied) {
      print('Permission permanently denied. Opening settings...');
      openAppSettings();
    }
  }

  Future<void> _handleLogout() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Would you want to log out from the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 1. Clear SharedPreferences and Reset Provider via the logout method
      await Provider.of<UserProvider>(context, listen: false).logout();

      // 2. Navigate to SendOtpScreen and remove all previous routes from the stack
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PhoneEntryScreen()),
              (route) => false,
        );
      }
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // Background Color for the top section (matches the header)
          Container(
            height: 200,
            color: const Color(0xFF3B82F6),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  // FIX 2: Added safety check to prevent black screen if index is out of bounds
                  child: _selectedIndex < _pages.length
                      ? _pages[_selectedIndex]
                      : const Center(child: Text("Page not found")),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed:_isCalling?null:_initiateCall,
        backgroundColor: const Color(0xFF3B82F6),
        shape: const CircleBorder(),
        elevation: 4,
        child:_isCalling?CircularProgressIndicator(color: Colors.white,): const Icon(Icons.call, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
              const Text(
                "Mukadam\nManagement",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
          // Added Logout IconButton
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDashboardContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              _buildActionCard(
                "Mukadam\nRegistration",
                Icons.person_add_alt_1,
                Colors.blue,
                const MukkadamRegistrationScreen(),
              ),
              _buildActionCard(
                "Quick Mukadam\nRegistration",
                Icons.bolt,
                Colors.orange.shade800,
                const QuickMukkadamRegistrationScreen(),
              ),
              // _buildActionCard(
              //   "Get Mukadam\nDetails",
              //   Icons.record_voice_over,
              //     Color(0xFF50C878),
              //   const MukadamListScreen(),
              // ),
              _buildActionCard(
                "Transport\nRegistration",
                Icons.local_shipping,
                Colors.redAccent,
                const TransportProviderScreen(),
              ),

              _buildActionCard(
                "My\nReferrals",
                Icons.receipt_long,
                Colors.green,
                const DirectoryScreen(),
              ),

              // _buildActionCard(
              //   "Map",
              //   Icons.map,
              //   Colors.blue,
              //   const OfflineMapScreen(),
              // ),
              //
              // _buildActionCard(
              //   "control_Screen",
              //   Icons.map,
              //   Colors.blue,
              //   const TrackingControlScreen(),
              // ),

              // Inside _buildDashboardContent GridView.count children:
              // _buildActionCard(
              //   "Audio\nRecording",
              //   Icons.mic,
              //   Colors.purple,
              //   const AudioRecordScreen(),
              // ),

              _buildActionCard(
                "My Plans",
                Icons.next_plan,
                Colors.grey,
                const VisitTrackingScreen(),
              ),

              _buildActionCard(
                "Mukadam Verification",
                Icons.man,
                Colors.blueAccent,
                const MukkadamListScreen(),
              ),

              _buildActionCard(
                "Dialpad",
                Icons.call,
                Colors.green,
                const DialPadScreen(),
              ),



              _buildActionCard(
                "Transport verification",
                Icons.fire_truck_rounded,
                Colors.red,
                const PendingVerificationListScreen() ,
              ),







            ],
          ),
          const SizedBox(height: 16),
          // _buildWideCard(
          //   "Transport Provider",
          //   "Search database",
          //   Icons.receipt_long,
          //   const TransportProviderListScreen(),
          // ),




          SizedBox(height: 25,),


        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(top: 0, left: 0, right: 0, child: Container(height: 4, color: color)),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideCard(String title, String subtitle, IconData icon, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      height: 70,
      notchMargin: 8,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.grid_view_rounded, "Home", 0),
          const SizedBox(width: 40), // Space for FAB
         _navItem(Icons.table_chart_outlined, "Create plan", 1),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF3B82F6) : Colors.grey[400]),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF3B82F6) : Colors.grey[400],
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildPlanTile(Map<String, dynamic> plan) {
  return ListTile(
    title: Text(plan['purpose'] ?? "No Purpose"),
    // Use location_summary from backend to avoid RangeErrors
    subtitle: Text(plan['location_summary'] ?? "No locations selected"),
  );
}