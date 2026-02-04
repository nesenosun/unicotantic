import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:unicotantic/Unic/sosyalMedya/YouTube.dart';
import 'package:unicotantic/Unic/sosyalMedya/facebook.dart';
import 'package:unicotantic/Unic/sosyalMedya/googleiwebview.dart';
import 'package:unicotantic/Unic/sosyalMedya/instagram.dart';
import 'package:unicotantic/Unic/sosyalMedya/twitter.dart';
import 'package:unicotantic/login/auth_kontrol.dart';
import 'package:unicotantic/profil/ayarlar.dart';
import 'package:unicotantic/profil/engelliler.dart';
import 'package:unicotantic/profil/kullanici_profil_sayfasi.dart';

import 'arkadaslar.dart';

class BenDrawer extends StatefulWidget {
  const BenDrawer({Key? key}) : super(key: key);

  @override
  State<BenDrawer> createState() => _BenDrawerState();
}

class _BenDrawerState extends State<BenDrawer> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  String errorMessage = '';
  GetStorage getbox = GetStorage();
  final puanSa = Hive.box('unicotantic');

  @override
  Widget build(BuildContext context) {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    return Drawer(
      backgroundColor: Colors.black87,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              //height: 320,
              child: DrawerHeader(
                  decoration: const BoxDecoration(),
                  child: GestureDetector(
                    onTap: () {
                      Get.off(const KullaniciProfilSayfasi());
                    },
                    child: StreamBuilder<DocumentSnapshot>(
                        stream: icerik.snapshots(),
                        builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                          if (asyncSnapshot.hasError) {
                            return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                          } else {
                            if (asyncSnapshot.hasData) {
                              return Container(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Center(
                                        child: Text(
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 13,
                                                color: Colors.greenAccent,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  BoxShadow(
                                                      color: Colors.red.withOpacity(.15),
                                                      offset: Offset(2.0, 2.0),
                                                      blurRadius: 10),
                                                ]),
                                            '${asyncSnapshot.data.data()['email']}',
                                            textAlign: TextAlign.center),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(1.0),
                                          bottomRight: Radius.circular(50.0),
                                          topRight: Radius.circular(1.0),
                                          bottomLeft: Radius.circular(50.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Image.network(
                                            '${asyncSnapshot.data.data()['profilresmilinki']}',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              /// yükleniyor bölümü
                              return buildDefaultTextStyle();
                            }
                          }
                        }),
                  )),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Get.to(const YouTube());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(height: 50, child: Image.asset('assets/images/png/youtube.png')),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.to(const Facebook());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(height: 50, child: Image.asset('assets/images/png/facebook.png')),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.to(const Instagram());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(height: 50, child: Image.asset('assets/images/png/instagram.png')),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Get.to(const Twitter());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(height: 50, child: Image.asset('assets/images/png/x.png')),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.to(const GoogleiWeb());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(height: 50, child: Image.asset('assets/images/png/googlei.png')),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.to(const AuthKontrol());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(height: 50, width: 50, child: Image.asset('assets/images/png/akis.png')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                Get.to(Ayarlar());

                setState(() {});
              },
              child: const Card(
                color: Colors.white10,
                elevation: 10,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Ayarlar',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Avenir',
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                        child: Icon(
                          Icons.settings,
                          size: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                SystemNavigator.pop();

                setState(() {});
              },
              child: const Card(
                color: Colors.white10,
                elevation: 10,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Çıkış',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Avenir',
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                //SystemNavigator.pop();
                Get.off(Arkadaslar(
                  gelenKullaniciEmail: kullanici.email.toString(),
                ));

                setState(() {});
              },
              child: const Card(
                color: Colors.white10,
                elevation: 10,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Arkadaşlar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Avenir',
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                //SystemNavigator.pop();
                Get.to(Engelliler(gelenKullaniciEmail: kullanici.email.toString()));

                setState(() {});
              },
              child: const Card(
                color: Colors.white10,
                elevation: 10,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Engelliler',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Avenir',
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                color: Colors.white24,
                elevation: 10,
                margin: EdgeInsets.all(15),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      ' v1.0\n  @nesenosun',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Avenir',
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// buildCard2 ///////////////////////////////////////////////////
  ///
  Card buildCard2(BuildContext context, yazi) {
    return Card(
      elevation: 5,
      //margin: const EdgeInsets.symmetric(horizontal: 5),
      color: Colors.white10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            yazi,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 9,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                shadows: [
                  BoxShadow(color: Colors.red.withOpacity(.15), offset: Offset(2.0, 2.0), blurRadius: 10),
                ]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  ///
  ///   /// buildCard ///////////////////////////////////////////////////
}
