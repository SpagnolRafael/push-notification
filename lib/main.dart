// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification/notifications.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  Notifications.showTextNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      fln: flutterLocalNotificationsPlugin);
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print(settings.authorizationStatus);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> fcmMessage() async {
    final token = await messaging.getToken();
    print('token: $token');
    FirebaseMessaging.onMessage.listen((message) {
      final notificationTitle = message.notification?.title;
      final notificationDescription = message.notification?.body;

      if (message.notification != null)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Title: ' + notificationTitle!),
            Text('Description: ' + notificationDescription!)
          ]),
          duration: const Duration(seconds: 10),
        ));
      print('$notificationTitle | $notificationDescription');
    });
  }

  @override
  void initState() {
    super.initState();
    fcmMessage();
    Notifications.initialize(flutterLocalNotificationsPlugin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
