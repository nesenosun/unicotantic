// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
//
// class BildirimHelper {
//   static final bildirim = FlutterLocalNotificationsPlugin();
//
//   static Future bildirimYukle() async {
//     const androidSimge = AndroidInitializationSettings('mipmap/flutter_logo');
//
//     const baslatmaAyarlari = InitializationSettings();
//     await bildirim.initialize(baslatmaAyarlari);
//   }
//
//   static Future _bildirimDetaylari() async => const NotificationDetails(
//           android: AndroidNotificationDetails(
//         'Unic Otan',
//         'Bildirim',
//         importance: Importance.max,
//       ));
//
//   static Future bildirimGoster({
//     int id = 0,
//     required String title,
//     required String body,
//     required String payload,
//   }) async =>
//       bildirim.show(id, title, body, await _bildirimDetaylari(), payload: 'payload');
//
//   static Future<void> zamanlanmisBildirim({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     debugPrint('Notification payload: $payload');
//     final scheduledTime = DateTime.now().add(const Duration(seconds: 5));
//     await bildirim.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledTime, tz.local),
//       await _bildirimDetaylari(),
//       androidScheduleMode: AndroidScheduleMode.alarmClock,
//       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
//     );
//     debugPrint('Notification payload3: $payload');
//   }
// }
// // static Future zamanlanmisBildirim({
// //   //  DateTime suankiZaman = DateTime.now();
// //   //
// //   // Duration sure = Duration(days: 0, hours: 0, minutes: 0, seconds: 10, microseconds: 0, milliseconds: 0);
// //   // DateTime ilerikiZaman = suankiZaman.add(sure);
// //   //
// //
// //   int id = 0,
// //   String? title,
// //   String? body,
// //   String? payload,
// // }) async =>
// //     bildirim.zonedSchedule(id, title, body,
// //         tz.TZDateTime.from(DateTime.now().add(Duration(milliseconds: 5000)), tz.local), await _bildirimDetaylari(),
// //         androidScheduleMode: AndroidScheduleMode.alarmClock,
// //         uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime);

// class DatePickerTxt extends StatefulWidget {
//   const DatePickerTxt({super.key});
//
//   @override
//   State<DatePickerTxt> createState() => _DatePickerTxtState();
// }
//
// class _DatePickerTxtState extends State<DatePickerTxt> {
//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//         onPressed: () {
//           DatePicker.showDateTimePicker(
//             context,
//             showTitleActions: true,
//             onChanged: (date) => scheduleTime = date,
//             onConfirm: (date) {},
//           );
//         },
//         child: Text('Zamanı Seç'));
//   }
// }
//
// class ScheduleBtn extends StatelessWidget {
//   const ScheduleBtn({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//         onPressed: () {
//           debugPrint('İşlem Başarılı $scheduleTime');
//
//           NotificationService().showNotification(
//             title: 'Başlık',
//             body: 'Gövde',
//           );
//         },
//         child: Text('Schedule notifications'));
//   }
// }

// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
//   Future<void> initNotification() async {
//     AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('flutter_logo');
//     var initializationSettingsIOS = DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//         onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {});
//     var initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//
//     await notificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {});
//   }
//
//   notificationDetails() {
//     return const NotificationDetails(
//         android: AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max),
//         iOS: DarwinNotificationDetails());
//   }
//
//   Future showNotification({int id = 0, String? title, String? body, String? payload}) async {
//     return notificationsPlugin.show(id, title, body, await notificationDetails());
//   }
// }

// DateTime suankiZaman = DateTime.now();
//
// final now = DateTime.now();
// final nowaEkle = now.add(Duration(seconds: 10 - now.second));
//
// Duration sure =
//     Duration(days: 0, hours: 0, minutes: 0, seconds: 10, microseconds: 0, milliseconds: 0);
// DateTime ilerikiZaman = suankiZaman.add(sure);
