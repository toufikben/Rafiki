import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const init = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(settings: init);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> showMissingYou(String petName) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'rafiq_missing',
        'Missing You',
        channelDescription: 'Gentle reminders from your pet',
        importance: Importance.low,
        priority: Priority.low,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: 0,
      title: '$petName misses you',
      body: 'Come back soon, I will wait 🐾',
      notificationDetails: details,
    );
  }

  static Future<void> showEvolution(String petName) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'rafiq_evolution',
        'Evolution',
        channelDescription: 'Your pet evolved',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: 1,
      title: '$petName grew up! ✨',
      body: 'Look how big they are now',
      notificationDetails: details,
    );
  }
}
