import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grock/grock.dart';
import 'package:unicotantic/Unic/fonksiyonlar/controllerNet.dart';
import 'package:unicotantic/Unic/fonksiyonlar/negatifOyVer_pozitifOyVer.dart';

import 'package:unicotantic/Unic/doluAkis/doluYorumOku.dart';
import 'package:unicotantic/Unic/fonksiyonlar/altButonlar.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:unicotantic/Unic/fonksiyonlar/postSabitleri.dart';

///////////////////////////////////
class YeniAkisPostlar extends StatefulWidget {
  String gelenKullaniciEmail;

  YeniAkisPostlar({required this.gelenKullaniciEmail});

  @override
  State<YeniAkisPostlar> createState() => _YeniAkisPostlarState();
}

class _YeniAkisPostlarState extends State<YeniAkisPostlar> {
  final controllerNet = Get.put(ControllerNet());

  bool kapat = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference kullaniciSorgu =
        controllerNet.firestore.collection('Kullanicilar');

    var kullaniciBilgileri = kullaniciSorgu
        .doc(widget.gelenKullaniciEmail.toString())
        .collection("postlar");

    Query postlarSorgu = controllerNet.firestore
        .collection('postlar')
        .where('email', isEqualTo: widget.gelenKullaniciEmail.toString())
        .orderBy("zaman", descending: true)
        .limit(100);

    return Container(
      color: Colors.black45,
      child: StreamBuilder<QuerySnapshot>(
          stream: postlarSorgu.snapshots(),
          builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
            if (kullaniciBilgileri.isEmpty) {
              return Center();
            } else {
              if (asyncSnapshot.hasError) {
                return const Center(
                    child: Text('Bir hata oluştu tekrar deneyin..'));
              } else {
                if (asyncSnapshot.hasData) {
                  List<DocumentSnapshot> listOfDocumentSnap =
                      asyncSnapshot.data.docs;

                  return Container(
                    height: 400,
                    child: ListView.builder(
                        itemCount: listOfDocumentSnap.length,
                        itemBuilder: (context, index) {
                          var begenKontrol =
                              listOfDocumentSnap[index].get('begen');
                          var email = listOfDocumentSnap[index].get('email');
                          var tarih = listOfDocumentSnap[index].get('tarih');
                          var baslik = listOfDocumentSnap[index].get('baslik');
                          var begenMeKontrol =
                              listOfDocumentSnap[index].get('begenMe');
                          var videoFoto =
                              listOfDocumentSnap[index].get('postVideoLinki');
                          var yorumSayisi =
                              listOfDocumentSnap[index].get('yorumSayisi');
                          var postFotolinki =
                              listOfDocumentSnap[index].get('postFotolinki');
                          var postAydi =
                              listOfDocumentSnap[index].get('postAydi');
                          var update =
                              listOfDocumentSnap[index].reference.update;
                          var bakBegenKontrol =
                              begenKontrol.contains(kullanici.email);
                          var bakBegenMeKontrol =
                              begenMeKontrol.contains(kullanici.email);

                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(DoluYorumOku(
                                    gelenKullaniciEmail: email.toString(),
                                    postAydi: postAydi.toString(),
                                  ));
                                },
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ustBolumKullaniciKimligi(postAydi, email,
                                          tarih, listOfDocumentSnap, index),
                                      ikinciBolumText(baslik),
                                      ucuncuBolumVideoFotograf(
                                          videoFoto, postFotolinki),
                                      Center(
                                        child: DorduncuBolumAltBar(
                                            email,
                                            listOfDocumentSnap,
                                            index,
                                            bakBegenMeKontrol,
                                            update,
                                            begenMeKontrol,
                                            bakBegenKontrol,
                                            begenKontrol,
                                            postAydi,
                                            yorumSayisi),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                  );
                } else {
                  /// yükleniyor bölümü
                  return buildDefaultTextStyle();
                }
              }
            }
          }),
    );
  }

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
          await FirebaseFirestore.instance
              .collection("Kullanicilar")
              .doc(kullanici.email)
              .update({
            'engelledim': FieldValue.arrayRemove([email.toString()])
          }).whenComplete(() {
            print('kullanıcı engellendi');
          });
          await FirebaseFirestore.instance
              .collection("Kullanicilar")
              .doc(email.toString())
              .update({
            "engelleyenler":
                FieldValue.arrayRemove([kullanici.email.toString()])
          });
        } else {
          await FirebaseFirestore.instance
              .collection("Kullanicilar")
              .doc(kullanici.email)
              .update({
            'engelledim': FieldValue.arrayUnion([email.toString()])
          }).whenComplete(() {
            print('kullanıcı engellendi');
          });
          await FirebaseFirestore.instance
              .collection("Kullanicilar")
              .doc(email.toString())
              .update({
            "engelleyenler": FieldValue.arrayUnion([kullanici.email.toString()])
          });
        }
      }
    }
  }

  ///
  SizedBox DorduncuBolumAltBar(
      email,
      List<DocumentSnapshot<Object?>> listOfDocumentSnap,
      int index,
      bakBegenMeKontrol,
      Future<void> update(Map<Object, Object?> data),
      begenMeKontrol,
      bakBegenKontrol,
      begenKontrol,
      postAydi,
      yorumSayisi) {
    return SizedBox(
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
                    bakBegenMeKontrol
                        ? Icons.heart_broken
                        : CupertinoIcons.heart_slash,
                    size: 20,
                    color: bakBegenMeKontrol ? Colors.red : Colors.white70,
                  )),
              Text(' ${begenMeKontrol.length}',
                  style: TextStyle(
                      fontSize: 13,
                      color: bakBegenMeKontrol ? Colors.red : Colors.white70)),
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
                      color: bakBegenKontrol ? Colors.green : Colors.white70)),
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
    );
  }

  ///
}
