import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings(
        'mipmap/ic_launcher'); //to change icon on notification
    var initializationSettings =
        InitializationSettings(android: androidInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future showTextNotification({
    int id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin fln,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'my_custom_id',
      'my_custom_channel',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('custom_sound'),
      importance: Importance.max,
      priority: Priority.high,
    );

    var noti = NotificationDetails(android: androidNotificationDetails);
    await fln.show(0, title, body, noti);
  }
}
