import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/Unic/zaman/saniyeController.dart';

import 'dakikaSayac.dart';

class SaniyeDeneme extends StatefulWidget {
  const SaniyeDeneme({super.key});

  @override
  State<SaniyeDeneme> createState() => _SaniyeDenemeState();
}

class _SaniyeDenemeState extends State<SaniyeDeneme> {
  final controller = SaniyeController();
  @override
  void initState() {
    super.initState();
    controller.sadeceVerileriCek();
  }

  @override
  void dispose() {
    super.dispose();
    controller.geriSayacSaniye;
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
                  Text('Saniye Sayaç',
                      style: TextStyle(
                        fontFamily: 'Madimi',
                        fontSize: 24,
                        color: Colors.brown,
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
                                child: Text(controller.saniyeCeviri.value.obs.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.black87,
                                    )),
                              )),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          controller.ilerikiZamanBas();
                        },
                        child: Text('Sureyi Başlat',
                            style: TextStyle(
                              fontFamily: 'Madimi',
                              fontSize: 24,
                              color: controller.mesaj == 'Sureyi Başlat' ? Colors.green : Colors.yellow,
                            )),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Get.offAll(DakikaSayac());
                        },
                        child: Text('Dakikaya Git',
                            style: TextStyle(
                              fontFamily: 'Madimi',
                              fontSize: 24,
                              color: Colors.yellow,
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
