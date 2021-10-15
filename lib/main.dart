import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_firebase/second_page.dart';
import 'local_notification/local_notification.dart';

Future<void> _firebaseMessBackgroundHandler(RemoteMessage message) async {
  debugPrint('*******************');
  debugPrint('Background messages');
  debugPrint(message.data.toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //Background messages.
  //App không chạy or app chạy ở chế độ nền.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/SecondPage": (context) => const SecondPage(),
      },
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = 'This is Notification Firebase';

  @override
  void initState() {
    super.initState();
    LocalNotificationService.initialize(context);
    //App not run.
    //when user click on notification.
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      debugPrint('********************');
      debugPrint('onTap notification');
      if (message != null) {
        setState(() {
          text = '${message.notification!.title}';
        });
      }
    });



    //Foreground message.
    //App đang chạy ở màn hình.
    FirebaseMessaging.onMessage.listen((event) {
      debugPrint('*******************');
      debugPrint('Foreground message.');
      debugPrint('Message data: ${event.data}');
      if (event.notification != null) {
        LocalNotificationService.simpleNotify(event);
      }
    });

    //when app background but opened and user taps.
    //App ở chế độ chạy nền khi click vào notification sẽ chạy vào đây.
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      debugPrint('****************************');
      debugPrint('BackgroundOpenedApp message.');
      debugPrint('Message data: ${event.data}');
    });
  }

  void permissionIos() async {
    //permission ios
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void simpleLocalNotify() {
    RemoteMessage message = const RemoteMessage(
      notification: RemoteNotification(title: 'HELLO', body: 'DATPM'),
    );
    LocalNotificationService.simpleNotify(message);
  }

  void scheduleLocalNotify() {
    DateTime date = DateTime.now().add(const Duration(seconds: 10));
    Time time = Time(11,38,00);
    LocalNotificationService.scheduleWeeklyNotify('HELLO', 'Datpm', time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Firebase')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: const TextStyle(fontSize: 20)),
            Container(
              height: 1,
              color: Colors.grey,
              margin: const EdgeInsetsDirectional.all(30),
            ),
            const Text(
              'This is Local notification',
              style: TextStyle(fontSize: 20, color: Colors.redAccent),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: simpleLocalNotify,
              child: const Text('Simple local notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: scheduleLocalNotify,
              child: const Text('Schedule local notification'),
            ),
          ],
        ),
      ),
    );
  }
}
