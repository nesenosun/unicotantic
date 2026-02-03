import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/Unic/zaman/zamanBildirimi.dart';

import 'dakikaController.dart';

DateTime scheduleTime = DateTime.now();

class DakikaSayac extends StatefulWidget {
  const DakikaSayac({super.key});
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  State<DakikaSayac> createState() => _DakikaSayacState();
}

class _DakikaSayacState extends State<DakikaSayac> {
  final controller = DakikaController();
  int intervalZaman = 20;
  int intervalZamanB = 30;

  @override
  void initState() {
    super.initState();
    controller.sadeceVerileriCek();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Card(
            child: SizedBox(
              width: 700,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      controller.ilerikiZamanBas();
                      await NotificationService.showNotification(
                        title: 'Zamanı Geldi',
                        body: 'Geri sayım Bitti',
                        summary: 'Small Summary',
                        scheduled: true,
                        interval: 15,
                        notificationLayout: NotificationLayout.Default,
                        actionType: ActionType.Default,
                        category: NotificationCategory.Reminder,

                        // actionButton: [
                        //   NotificationActionButton(
                        //     key: 'check',
                        //     label: 'Bildirimi kaldır',
                        //     color: Colors.green,
                        //   )
                        // ],

                        // notificationLayout: NotificationLayout.BigPicture,
                        // bigPicture: 'https://pbs.twimg.com/media/GJtTIg5XkAAM_Z7?format=jpg&name=medium',
                      );
                    },
                    child: Text('Büyük Zaman',
                        style: TextStyle(
                          fontFamily: 'Madimi',
                          fontSize: 24,
                          color: controller.mesaj == 'Sureyi Başlat' ? Colors.green : Colors.yellow,
                        )),
                  ),
                  Text('Dakika Sayaç',
                      style: TextStyle(
                        fontFamily: 'Madimi',
                        fontSize: 24,
                        color: Colors.blue,
                      )),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        color: Colors.yellow,
                        child: Center(
                          child: Obx(() => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    controller.dakikaCeviri.value.obs.toString() +
                                        ' : ' +
                                        controller.saniyeCeviri.value.obs.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.black87,
                                    )),
                              )),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          controller.ilerikiZamanBas();
                          await NotificationService.showNotification(
                            title: 'Zamanı Geldi',
                            body: 'Geri sayım Bitti',
                            scheduled: true,
                            interval: intervalZaman,
                            payload: {
                              'navigate': 'true',
                            },
                            actionButton: [
                              NotificationActionButton(
                                key: 'check',
                                label: 'Bildirimi kaldır',
                                actionType: ActionType.Default,
                                color: Colors.green,
                              )
                            ],
                            // summary: 'small summ',
                            // notificationLayout: NotificationLayout.BigPicture,
                            // bigPicture: 'https://pbs.twimg.com/media/GJtTIg5XkAAM_Z7?format=jpg&name=medium',
                          );
                          //BildirimHelper.bildirimGoster(id: 7, title: 'Başlık', body: 'Gövde', payload: 'payload');

                          // BildirimHelper.zamanlanmisBildirim(
                          //   id: 2,
                          //   title: 'Başlık Z',
                          //   body: 'Gövde Z',
                          //   payload: 'payload',
                          // );
                        },
                        child: Text('Başla',
                            style: TextStyle(
                              fontFamily: 'Madimi',
                              fontSize: 24,
                              color: controller.mesaj == 'Sureyi Başlat' ? Colors.green : Colors.yellow,
                            )),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.black12,
                    child: Center(
                      child: Obx(() => Text(controller.mesaj.toString(),
                          style: TextStyle(
                            fontFamily: 'Madimi',
                            fontSize: 44,
                            color: controller.mesaj == 'KAZANDINIZ' ? Colors.green : Colors.yellow,
                          ))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
