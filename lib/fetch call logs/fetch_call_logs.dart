

import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> fetchCallLogs() async {
  // 1. Request Permission
  PermissionStatus status = await Permission.phone.request();

  if (status.isGranted) {
    // 2. Fetch Call Logs
    Iterable<CallLogEntry> entries = await CallLog.get();

    for (CallLogEntry entry in entries) {
      print('--- Call Entry ---');
      print('Name: ${entry.name}');
      print('Number: ${entry.number}');
      print('Type: ${entry.callType}');
      print('Duration: ${entry.duration} seconds');
      print('Timestamp: ${DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)}');
    }
  } else if (status.isPermanentlyDenied) {
    // Guide user to app settings
    openAppSettings();
  } else {
    print('Permission denied');
  }
}
