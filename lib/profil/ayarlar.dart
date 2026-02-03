import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';
import 'package:unicotantic/Unic/doluAkis/yeniAkis.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:unicotantic/Unic/veriTabani/veriTabaniYonetimPaneli.dart';
import 'package:unicotantic/login/email_giris.dart';
import 'package:unicotantic/login/sifremi_unuttum.dart';
import 'package:unicotantic/login/uyeYap.dart';
import 'package:unicotantic/profil/admin_sayfasi.dart';
import 'package:unicotantic/profil/profil_duzenle.dart';

import 'BenDrawer.dart';
import 'arkadaslar.dart';
import 'engelliler.dart';
import 'kullaniciAdiSorgu.dart';

class Ayarlar extends StatefulWidget {
  const Ayarlar({super.key});

  @override
  State<Ayarlar> createState() => _AyarlarState();
}

class _AyarlarState extends State<Ayarlar> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  String errorMessage = '';
  GetStorage getbox = GetStorage();
  final puanSa = Hive.box('unicotantic');
  @override
  Widget build(BuildContext context) {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var kullaniciBilgileriSorgu = kullanicilar.doc(kullanici.email);
    var icerik = kullanicilar.doc(kullanici.email);

    return Scaffold(
      appBar: akisAppBar(),
      drawer: const BenDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: kullaniciBilgileriSorgu.snapshots(),
                builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                  if (asyncSnapshot.hasError) {
                    return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                  } else {
                    if (asyncSnapshot.hasData) {
                      var profilGizli = asyncSnapshot.data.data()['profilGizli'];
                      var id = asyncSnapshot.data.data()['id'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          kullanici.email == 'sinermis@gmail.com' || kullanici.email == 'nesenosun@gmail.com'
                              ? Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(VeriTabaniYonetimPaneli(
                                            gelenKullaniciEmail: kullanici.email.toString(),
                                            gelenKullaniciUid: kullanici.uid.toString()));
                                      },
                                      child: Card(
                                        color: Colors.white10,
                                        elevation: 10,
                                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(15.0),
                                                child: Text(
                                                  'Yönetim',
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
                                                  Icons.token,
                                                  size: 20,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (kullanici.email == 'nesenosun@gmail.com')
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(const AdminSayfasi());
                                        },
                                        child: Card(
                                          color: Colors.red.withOpacity(0.2),
                                          elevation: 10,
                                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                                          child: const Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(15.0),
                                                  child: Text(
                                                    'Admin Paneli',
                                                    style: TextStyle(
                                                      color: Colors.red,
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
                                                    Icons.admin_panel_settings,
                                                    size: 20,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              : Center(),
                          GestureDetector(
                            onTap: () async {
                              //SystemNavigator.pop();
                              Get.off(const EmailGiris());

                              try {
                                await FirebaseAuth.instance.signOut();
                                errorMessage = '';
                              } on FirebaseAuthException catch (error) {
                                errorMessage = error.message!;
                              }
                              try {
                                await GoogleSignIn().signOut();
                                errorMessage = '';
                              } catch (e) {
                                errorMessage = errorMessage;
                              }

                              setState(() {});
                            },
                            child: const Card(
                              color: Colors.white10,
                              elevation: 10,
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Text(
                                    'Beni Unut',
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
                          id == '.....'
                              ? GestureDetector(
                                  onTap: () async {
                                    //SystemNavigator.pop();
                                    Get.to(KullaniciAdiSorgu());

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
                                          'Kullanıcı Adını Değiştir',
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
                                )
                              : Center(),
                          GestureDetector(
                            onTap: () async {
                              if (profilGizli == false) {
                                await FirebaseFirestore.instance
                                    .collection("Kullanicilar")
                                    .doc(kullanici.email)
                                    .update({'profilGizli': true});
                              } else {
                                await FirebaseFirestore.instance
                                    .collection("Kullanicilar")
                                    .doc(kullanici.email)
                                    .update({'profilGizli': false});
                              }

                              setState(() {});
                            },
                            child: Card(
                              color: Colors.white10,
                              elevation: 10,
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Text(
                                        'Profili Gizle',
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
                                        Icons.lock,
                                        size: 20,
                                        color: profilGizli == true ? Colors.red : Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              Get.to(ProfilDuzenle());

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
                                      padding: EdgeInsets.all(15.0),
                                      child: Text(
                                        'Profili Düzenle',
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
                              Get.to(SifremiUnuttum());

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
                                      padding: EdgeInsets.all(15.0),
                                      child: Text(
                                        'Şifre Değiştir',
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
                              //SystemNavigator.pop();
                              Get.to(Arkadaslar(
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
                                  padding: EdgeInsets.all(15.0),
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
                              Get.to(Engelliler(gelenKullaniciEmail: kullanici.email.toString()));

                              setState(() {});
                            },
                            child: const Card(
                              color: Colors.white10,
                              elevation: 10,
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
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
                          GestureDetector(
                            onTap: () async {
                              setState(() {});
                            },
                            child: const Card(
                              color: Colors.white10,
                              elevation: 10,
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Text(
                                    'Oyun',
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
                              Get.to(UyeYap());

                              setState(() {});
                            },
                            child: const Card(
                              color: Colors.white10,
                              elevation: 10,
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Text(
                                    'Uye Ekle',
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
                              Get.to(YeniAkis(gelenKullaniciEmail: kullanici.email.toString()));

                              setState(() {});
                            },
                            child: const Card(
                              color: Colors.white10,
                              elevation: 10,
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Text(
                                    'Yeni Akış',
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
                        ],
                      );
                    } else {
                      /// yükleniyor bölümü
                      return buildDefaultTextStyle();
                    }
                  }
                }),
          ],
        ),
      ),
    );
  }
}
