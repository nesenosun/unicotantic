import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/profil/postaYorumOku.dart';
import 'package:video_player/video_player.dart';

import '../Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import '../Unic/fonksiyonlar/negatifOyVer_pozitifOyVer.dart';
import '../Unic/fonksiyonlar/postSabitleri.dart';

class BireyselAkis extends StatefulWidget {
  const BireyselAkis({super.key});

  @override
  State<BireyselAkis> createState() => _BireyselAkisState();
}

class _BireyselAkisState extends State<BireyselAkis> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  final puanSa = Hive.box('unicotantic');

  Future<void> saveTokenToFirestore() async {
    //uidEkle();
    final String? token = await getTokenFromSomewhere(); // Burada cihazdan tokenı alma kodunu çağırman gerekiyor
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('token')
          .doc(kullanici.email)
          .set({'token': token}, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(kullanici.email)
          .set({'uid': kullanici.uid.toString()}, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(kullanici.email)
          .set({'token': token.toString()}, SetOptions(merge: true));
    }
  }

  Future<String?> getTokenFromSomewhere() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Firebase Messaging token'ı al
    String? token = await messaging.getToken();

    // Firebase Messaging token'ı varsa, geri dön
    if (token != null) {
      return token;
    }
    print('token : ' + token!);

    // Firebase Messaging token'ı yoksa, hata mesajı göster ve null geri dön
    print('Firebase Messaging tokenı alınamadı');
    return null;
  }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  late final VideoPlayerController controller;
  final gidecekVideoLinki =
      'https://firebasestorage.googleapis.com/v0/b/unic-otantic-e4f32.appspot.com/o/postVideolari%2F3195353059890115276.mp4?alt=media&token=09aa881f-416d-40ef-8d6c-ca0be546b2f7&_gl=1*krfqyo*_ga*OTUyNTQyNzIzLjE2ODY0ODM1MDc.*_ga_CW55HF8NVT*MTY5OTAwNDY2NC4yNDIuMS4xNjk5MDA0ODgwLjQ2LjAuMA..';
  final gidecekVideoLinki2 = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  @override
  void initState() {
    super.initState();
    saveTokenToFirestore();
    puanSa.put('yorumYapanEmail', '');
  }

  @override
  Widget build(BuildContext context) {
    Query postlarSorgu = _firestore
        .collection('postlar')
        .where('email', isEqualTo: kullanici.email)
        .orderBy("zaman", descending: true)
        .limit(100);

    return StreamBuilder<QuerySnapshot>(
        stream: postlarSorgu.snapshots(),
        builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
          } else {
            if (asyncSnapshot.hasData) {
              List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;

              return Flexible(
                child: ListView.builder(
                    itemCount: listOfDocumentSnap.length,
                    itemBuilder: (context, index) {
                      var begenKontrol = listOfDocumentSnap[index].get('begen');
                      var email = listOfDocumentSnap[index].get('email');
                      var tarih = listOfDocumentSnap[index].get('tarih');
                      var baslik = listOfDocumentSnap[index].get('baslik');
                      var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
                      var videoFoto = listOfDocumentSnap[index].get('postVideoLinki');
                      var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');

                      var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');

                      var postAydi = listOfDocumentSnap[index].get('postAydi');
                      var update = listOfDocumentSnap[index].reference.update;
                      var bakBegenKontrol = begenKontrol.contains(kullanici.email);
                      var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);

                      return GestureDetector(
                        onTap: () {
                          puanSa.put('postAydi', postAydi.toString());
                          puanSa.put('email', email.toString());
                          print(postAydi.toString());
                          //Get.to(DoluYorumOku());
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ustBolumKullaniciKimligi(postAydi, email, tarih, listOfDocumentSnap, index),
                              ikinciBolumText(baslik),
                              ucuncuBolumVideoFotograf(videoFoto, postFotolinki),
                              SizedBox(
                                height: 35,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                              bakBegenMeKontrol ? Icons.heart_broken : CupertinoIcons.heart_slash,
                                              size: 20,
                                              color: bakBegenMeKontrol ? Colors.red : Colors.white70,
                                            )),
                                        Text(' ${begenMeKontrol.length}',
                                            style: TextStyle(
                                                fontSize: 13, color: bakBegenMeKontrol ? Colors.red : Colors.white70)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () async {
                                              await pozitifOyVer(
                                                  listOfDocumentSnap, index, bakBegenKontrol, update, email);
                                            },
                                            icon: Icon(
                                              bakBegenKontrol ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                              size: 20,
                                              color: bakBegenKontrol ? Colors.green : Colors.white70,
                                            )),
                                        Text('${begenKontrol.length}',
                                            style: TextStyle(
                                                fontSize: 13, color: bakBegenKontrol ? Colors.green : Colors.white70)),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                            onPressed: () async {
                                              print(postAydi.toString());
                                              Get.to(PostaYorumOku(
                                                gelenKullaniciEmail: kullanici.email.toString(),
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
                        ),
                      );
                    }),
              );
            } else {
              /// yükleniyor bölümü
              return buildDefaultTextStyle();
            }
          }
        });
  }

  Padding postuDuzenleIconu(email, postAydi) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        child: kullanici.email == email.toString()
            ? IconButton(
                onPressed: () async {
                  puanSa.put('postAydi', postAydi.toString());
                  puanSa.put('email', email.toString());

                  //Get.to(PostuDuzenle());
                },
                icon: const Icon(
                  Icons.edit,
                  size: 15,
                  color: Colors.greenAccent,
                ))
            : Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2)));
  }

  Future<dynamic> unicCikart() async {
    final kullanici = FirebaseAuth.instance.currentUser!;
    final _firestore = FirebaseFirestore.instance;
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic unic = map['unic'];

    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update(unic >= 1 ? {"unic": FieldValue.increment(-1)} : {"unic": 0});
    return unic;
  }

  ///
}
