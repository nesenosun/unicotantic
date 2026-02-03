import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/Unic/bildirimler/akisBildirimleri.dart';
import 'package:unicotantic/Unic/bildirimler/akisaYorumBildirimleri.dart';
import 'package:unicotantic/Unic/bildirimler/postBildirimleri.dart';
import 'package:unicotantic/Unic/bildirimler/yorumBildirimleri.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';
import 'package:unicotantic/Unic/fonksiyonlar/controllerFnksiyon.dart';
import 'package:unicotantic/Unic/fonksiyonlar/controllerNet.dart';
import 'package:unicotantic/profil/BenDrawer.dart';
import 'package:unicotantic/profil/profil_fotograf_degistir.dart';

///////////////////////////////////
class Bildirim extends StatefulWidget {
  const Bildirim({super.key});

  @override
  State<Bildirim> createState() => _BildirimState();
}

class _BildirimState extends State<Bildirim> {
  final StreamController<String> streamController1 = StreamController<String>();
  final StreamController<String> streamController2 = StreamController<String>();
  final controllerNet = Get.put(ControllerNet());
  final controllerFonk = Get.put(ControllerFonksiyon());
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
  ProfilFotografiDegistir getir = const ProfilFotografiDegistir();
  String? indirmeBaglantisi;

  final getbox = GetStorage();
  GetStorage box = GetStorage();
  dynamic puanSa = Hive.box('unicotantic');
  var postlar = 1;
  var akis = 3;

  final _pageController = PageController(initialPage: 0);
  int aktifSayfa = 0;
  final List<Widget> sayfa = [
    PostBildirimleri(),
    YorumBildirimleri(),
    AkisBildirimleri(),
  ];

  @override
  void initState() {
    //firebaseIndirHiveYukleFonksiyonu();
    // TODO: implement initState
    super.initState();
    postlar = 1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    streamController1.close();
    streamController2.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: akisAppBar(),
        drawer: const BenDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: postlar == 1 ? 2 : 1,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          akis = 3;

                          postlar = 1;
                        });
                      },
                      child: Card(
                        color: postlar == 1 ? Colors.cyan : Colors.black38,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            postlar == 1 ? 'Gönderine gelen yorumlar' : 'Gönderi',
                            style: TextStyle(
                                fontFamily: 'Avenir',
                                fontSize: 12,
                                color: postlar == 1 ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: postlar == 2 ? 2 : 1,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          akis = 3;
                          postlar = 2;
                        });
                      },
                      child: Card(
                        color: postlar == 2 ? Colors.cyan : Colors.black38,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            postlar == 2 ? 'Yorumuna cevap verildi' : 'Yorum',
                            style: TextStyle(
                                fontFamily: 'Avenir',
                                fontSize: 12,
                                color: postlar == 2 ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: akis == 1 ? 2 : 1,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          postlar = 3;
                          akis = 1;
                        });
                      },
                      child: Card(
                        color: akis == 1 ? Colors.cyan : Colors.black38,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            akis == 1 ? 'Akışa gelen post' : 'Akışıma post',
                            style: TextStyle(
                                fontFamily: 'Avenir',
                                fontSize: 12,
                                color: akis == 1 ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: akis == 2 ? 2 : 1,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          postlar = 3;
                          akis = 2;
                        });
                      },
                      child: Card(
                        color: akis == 2 ? Colors.cyan : Colors.black38,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            akis == 2 ? 'Akışa gelen yorum' : 'Akışıma yorum',
                            style: TextStyle(
                                fontFamily: 'Avenir',
                                fontSize: 12,
                                color: akis == 2 ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              postlar == 1
                  ? PostBildirimleri()
                  : postlar == 2
                      ? YorumBildirimleri()
                      : Center(),
              akis == 1
                  ? AkisBildirimleri()
                  : akis == 2
                      ? AkisaYorumBildirimleri()
                      : Center(),
            ],
          ),
        ),
      ),
    );
  }

  ///

  ///
}
