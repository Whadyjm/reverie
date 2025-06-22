import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotiService {
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;
  NotiService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Notification channel constants
  static const String _channelId = 'my_notification_channel';
  static const String _channelName = 'My Notifications';
  static const String _channelDescription = 'Important notifications';

  /// Initialize notification service
  Future<void> initNotification() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Android initialization (use 'app_icon' if you have a custom drawable)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidSettings,
          // Add iOS settings if needed
          // iOS: DarwinInitializationSettings()
        );

    // Create notification channel for Android 8.0+
    await _createNotificationChannel();

    await notificationsPlugin.initialize(
      initializationSettings,
      // Optional: handle notification taps
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap logic here
      },
    );

    _isInitialized = true;
  }

  /// Create notification channel (required for Android 8.0+)
  Future<void> _createNotificationChannel() async {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Get notification details
  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  /// Show notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initNotification();
    }

    await notificationsPlugin.show(
      id,
      title ?? 'Notification Title',
      body ?? 'Notification Body',
      _notificationDetails(), // Fixed: Use the proper details
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    int id = 0,
    String? title,
    String? body,
    int? hour,
    int? minute,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initNotification();
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour ?? 7,
      minute ?? 0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    print('Notification scheduled for $scheduledDate');
  }

  Future<void> cancelAllNotifications(){
    return notificationsPlugin.cancelAll();
  }
}
