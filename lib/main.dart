// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, prefer_interpolation_to_compose_strings

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification/demand_page.dart';
import 'package:push_notification/notifications.dart';

import 'firebase_options.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  FirebaseFirestore database = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? deviceToken;

  String errorMsg = '';
  Future<void> fcmMessage() async {
    final token = await messaging.getToken();
    await database
        .collection('users')
        .doc(auth.currentUser?.uid)
        .set({'deviceToken': token, 'iOS': Platform.isIOS});
    deviceToken = token;
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
    auth.authStateChanges().listen((user) {
      if (auth.currentUser != null)
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DemandPage(
                    userUUID: auth.currentUser?.uid,
                    token: deviceToken,
                  )),
        );
    });
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Login Screen',
              ),
              const SizedBox(height: 20),
              TextFormField(
                  onChanged: (value) {
                    setState(() {
                      errorMsg = '';
                    });
                  },
                  controller: emailController,
                  decoration: const InputDecoration(hintText: 'e-mail')),
              const SizedBox(height: 20),
              TextFormField(
                  onChanged: (value) {
                    setState(() {
                      errorMsg = '';
                    });
                  },
                  controller: passController,
                  decoration: const InputDecoration(hintText: 'senha')),
              const SizedBox(height: 20),
              if (errorMsg.isNotEmpty)
                Text(
                  errorMsg,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: login,
        tooltip: 'Login',
        child: const Icon(Icons.login),
      ),
    );
  }

  void login() async {
    await auth
        .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passController.text.trim())
        .catchError((e) {
      setState(() {
        errorMsg = 'Usuario ou senha não localizado';
      });
    });
  }
}
