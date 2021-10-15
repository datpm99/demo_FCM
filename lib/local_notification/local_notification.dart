import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'helper.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static late NotificationDetails platformChannelSpecifics;

  //Custom Notify.
  static String bigImg = 'assets/images/nature.jpg';
  static String largeIcon = 'assets/images/girl.jpg';

  static void initialize(BuildContext context) async {
    //Settings default.
    AndroidInitializationSettings initSettingsAndroid =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    IOSInitializationSettings initSettingsIOS =
        const IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initSettingsAndroid, iOS: initSettingsIOS);
    await _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) {
        //onTap notify.
        Helper.navigateNamed(context, '$payload');
      },
    );

    final styleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigImg),
      largeIcon: FilePathAndroidBitmap(largeIcon),
    );

    //Settings notification.
    AndroidNotificationDetails androidPlatformChannel =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: styleInformation, // custom.
    );

    IOSNotificationDetails iOSPlatformChannel = const IOSNotificationDetails();

    platformChannelSpecifics = NotificationDetails(
        iOS: iOSPlatformChannel, android: androidPlatformChannel);

    tz.initializeTimeZones();
  }

  static void simpleNotify(RemoteMessage message) {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _notificationsPlugin.show(
      id,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: '/SecondPage',
    );
  }

  static void scheduleNotify(String title, String body, DateTime date) {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 999;
    _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: '/SecondPage',
    );
  }

  //Notify will show in day of week.
  static void scheduleWeeklyNotify(String title, String body, Time time) {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 888;
    _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _scheduleWeekly(time, [DateTime.monday, DateTime.friday]),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: '/SecondPage',
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static tz.TZDateTime _scheduleDaily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(tz.local, now.year, now.month,
        now.day, time.hour, time.minute, time.second);
    return scheduleDate.isBefore(now)
        ? scheduleDate.add(const Duration(days: 1))
        : scheduleDate;
  }

  static tz.TZDateTime _scheduleWeekly(Time time, List<int> day) {
    tz.TZDateTime scheduleDate = _scheduleDaily(time);
    while (!day.contains(scheduleDate.weekday)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }
}
