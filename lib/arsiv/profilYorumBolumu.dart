/*
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/Unic/doluAkis/doluYorumOku.dart';
import 'package:unicotantic/arsiv/profilBilgilerim.dart';
import 'package:unicotantic/profil/profil_fotograf_degistir.dart';

import '../Unic/doluAkis/doluAkisAppBar.dart';
import '../Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import '../Unic/fonksiyonlar/kullaniciProfilUstBar.dart';
import '../Unic/fonksiyonlar/negatifOyVer_pozitifOyVer.dart';
import '../Unic/fonksiyonlar/postSabitleri.dart';
import '../profil/BenDrawer.dart';
import '../profil/ayarlar.dart';
import 'profilAkis.dart';

///////////////////////////////////
class ProfilYorumBolumu extends StatefulWidget {
  const ProfilYorumBolumu({super.key});

  @override
  State<ProfilYorumBolumu> createState() => _ProfilYorumBolumuState();
}

class _ProfilYorumBolumuState extends State<ProfilYorumBolumu> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
  ProfilFotografiDegistir getir = const ProfilFotografiDegistir();
  String? indirmeBaglantisi;

  final getbox = GetStorage();
  GetStorage box = GetStorage();
  final puanSa = Hive.box('unicotantic');
  String galeri = '';
  bool kapat = true;

  @override
  void initState() {
    //firebaseIndirHiveYukleFonksiyonu();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var kullaniciBilgileriSorgu = kullanicilar.doc(kullanici.email);

    Query postaYorumSorgu = _firestore.collection('postaYorum').orderBy("zaman", descending: true);

    return SafeArea(
      child: Scaffold(
        appBar: akisAppBar(),
        drawer: const BenDrawer(),
        body: Container(
          child: Column(
            children: [
              kapat == true
                  ? GestureDetector(
                      onTap: () {
                        kapat = false;
                        setState(() {});
                      },
                      child: SizedBox(
                        child: Column(
                          children: [
                            kullaniciProfilUstBar(kullaniciBilgileriSorgu),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(ProfilBilgilerim());
                                    },
                                    child: Card(
                                      color: Colors.black38,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Postlar',
                                          style: TextStyle(
                                              fontFamily: 'Avenir',
                                              fontSize: 14,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.normal),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      //Get.to(BireyselAkis());
                                    },
                                    child: Card(
                                      color: Colors.cyan,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Yorumlar',
                                          style: TextStyle(
                                              fontFamily: 'Avenir',
                                              fontSize: 14,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(ProfilAkis());
                                    },
                                    child: Card(
                                      color: Colors.black38,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Akışım',
                                          style: TextStyle(
                                              fontFamily: 'Avenir',
                                              fontSize: 14,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.normal),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.to(Ayarlar());
                                  },
                                  child: Card(
                                    color: Colors.black38,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.settings,
                                        size: 15,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Card(
                                    color: Colors.black87,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Yalnızca Postları Göster',
                                        style: TextStyle(
                                            fontFamily: 'Avenir',
                                            fontSize: 14,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              kapat = true;
                              setState(() {});
                            },
                            child: Card(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          BoxShadow(
                                              color: Colors.red.withOpacity(.15),
                                              offset: Offset(2.0, 2.0),
                                              blurRadius: 10),
                                        ]),
                                    // isim.toString() + ' ' + soyisim.toString(),
                                    'Yorumlar',
                                    textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              StreamBuilder<QuerySnapshot>(
                  stream: postaYorumSorgu.snapshots(),
                  builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                    if (asyncSnapshot.hasError) {
                      return const Center(child: Text('Bir hata oluştu tekrnnar deneyin..'));
                    } else {
                      if (asyncSnapshot.hasData) {
                        List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;

                        return Flexible(
                          child: ListView.builder(
                              itemCount: listOfDocumentSnap.length,
                              itemBuilder: (context, index) {
                                var begenKontrol = listOfDocumentSnap[index].get('begen');
                                var email = listOfDocumentSnap[index].get('email');
                                //var id = listOfDocumentSnap[index].get('id');
                                var tarih = listOfDocumentSnap[index].get('tarih');
                                var baslik = listOfDocumentSnap[index].get('metin');
                                var duzenlemeMetin = listOfDocumentSnap[index].get('baslik');
                                var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
                                var videoFoto = listOfDocumentSnap[index].get('postVideoLinki');
                                var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
                                var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
                                var postAydi = listOfDocumentSnap[index].get('postAydi');
                                var update = listOfDocumentSnap[index].reference.update;
                                var bakBegenKontrol = begenKontrol.contains(kullanici.email);
                                var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);

                                return Container(
                                  child: kullanici.email.toString() == email.toString()
                                      ? Card(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ustBolumKullaniciKimligi(
                                                  postAydi, email, tarih, listOfDocumentSnap, index),
                                              ikinciBolumText(baslik),
                                              ucuncuBolumVideoFotograf(videoFoto, postFotolinki),
                                              SizedBox(
                                                height: 35,
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        IconButton(
                                                            onPressed: () async {
                                                              await negatifOyVer(email, bakBegenMeKontrol, update);
                                                            },
                                                            icon: Icon(
                                                              bakBegenMeKontrol
                                                                  ? Icons.heart_broken
                                                                  : CupertinoIcons.heart_slash,
                                                              size: 20,
                                                              color: bakBegenMeKontrol ? Colors.red : Colors.white70,
                                                            )),
                                                        Text(' ${begenMeKontrol.length}',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    bakBegenMeKontrol ? Colors.red : Colors.white70)),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                            onPressed: () async {
                                                              await pozitifOyVer(listOfDocumentSnap, index,
                                                                  bakBegenKontrol, update, email);
                                                            },
                                                            icon: Icon(
                                                              bakBegenKontrol
                                                                  ? CupertinoIcons.heart_fill
                                                                  : CupertinoIcons.heart,
                                                              size: 20,
                                                              color: bakBegenKontrol ? Colors.green : Colors.white70,
                                                            )),
                                                        Text('${begenKontrol.length}',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    bakBegenKontrol ? Colors.green : Colors.white70)),
                                                      ],
                                                    ),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        IconButton(
                                                            onPressed: () async {
                                                              // puanSa.put('postAydi', postAydi.toString());
                                                              // puanSa.put('email', email.toString());
                                                              print(postAydi.toString());
                                                              Get.to(DoluYorumOku(
                                                                gelenKullaniciEmail: email.toString(),
                                                                postAydi: postAydi.toString(),
                                                              ));
                                                            },
                                                            icon: Icon(
                                                              CupertinoIcons.conversation_bubble,
                                                              size: 20,
                                                              color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
                                                            )),
                                                        Text('${yorumSayisi}' + '  ',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
                                                                fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Center(),
                                );
                              }),
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
      ),
    );
  }

  ///

  ///

  ///

  Future<void> engelleFonksiyonu(email) async {
    final _firestore = FirebaseFirestore.instance;
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic unic = map['unic'];
    dynamic engelledim = map['engelledim'];
    unicCikar();

    if (unic <= 0) {
    } else {
      if (email != kullanici.email) {
        if (engelledim.contains(email)) {
          await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
            'engelledim': FieldValue.arrayRemove([email.toString()])
          }).whenComplete(() {
            print('kullanıcı engellendi');
          });
          await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
            "engelleyenler": FieldValue.arrayRemove([kullanici.email.toString()])
          });
        } else {
          await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
            'engelledim': FieldValue.arrayUnion([email.toString()])
          }).whenComplete(() {
            print('kullanıcı engellendi');
          });
          await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
            "engelleyenler": FieldValue.arrayUnion([kullanici.email.toString()])
          });
        }
      }
    }
  }
}
*/
