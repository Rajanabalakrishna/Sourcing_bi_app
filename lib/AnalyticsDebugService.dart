import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsDebugService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logDebugEvent(String eventName, {Map<String, Object>? params}) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: params,
      );
      print('📊 [ANALYTICS] Event sent: $eventName with params: $params');
    } catch (e) {
      print('❌ [ANALYTICS] Error sending event $eventName: $e');
    }
  }

  static Future<void> setUserId(String id) async {
    await _analytics.setUserId(id: id);
    print('👤 [ANALYTICS] User ID set to: $id');
  }


  static Future<void> testAllEvents() async {
    print('🧪 [ANALYTICS] Starting comprehensive test...');

    // Test screen view
    await _analytics.logScreenView(
      screenName: 'TestScreen',
      screenClass: 'AnalyticsTestScreen',
    );

    // Test different event types - explicitly cast to Map<String, Object>
    await logDebugEvent('test_button_click', params: {
      'button_id': 'test_button',
      'timestamp': DateTime.now().toString(),
    } as Map<String, Object>?);

    // Test ecommerce-style event

    // Test custom event
    await logDebugEvent('user_interaction', params: {
      'action': 'swipe',
      'direction': 'left',
      'screen': 'dashboard',
    } as Map<String, Object>?);

    // Set user property
    await _analytics.setUserProperty(
      name: 'test_group',
      value: 'debug_users',
    );

    print('✅ [ANALYTICS] Test completed');
  }
}