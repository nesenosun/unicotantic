import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/Unic/doluAkis/yorumaYorum.dart';
import 'package:unicotantic/profil/yeniZiyaretciProfil.dart';

import '../fonksiyonlar/buildDefaultTextStyle.dart';
import '../fonksiyonlar/controllerFnksiyon.dart';
import '../fonksiyonlar/controllerNet.dart';
import '../fonksiyonlar/postSabitleri.dart';
import '../fonksiyonlar/profilResmiGetir.dart';

///////////////////////////////////
class YorumBildirimleri extends StatefulWidget {
  const YorumBildirimleri({super.key});

  @override
  State<YorumBildirimleri> createState() => _YorumBildirimleriState();
}

class _YorumBildirimleriState extends State<YorumBildirimleri> {
  final controllerNet = Get.put(ControllerNet());
  final controllerFonk = Get.put(ControllerFonksiyon());
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  final getbox = GetStorage();
  GetStorage box = GetStorage();
  dynamic puanSa = Hive.box('unicotantic');

  @override
  void initState() {
    //firebaseIndirHiveYukleFonksiyonu();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Query yorumSorgu = _firestore
        .collection('yorumaYorum')
        .orderBy("zaman", descending: true)
        .limit(100);

    return StreamBuilder<QuerySnapshot>(
        stream: yorumSorgu.snapshots(),
        builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return const Center(
                child: Text('Bir hata oluştu tekrar deneyin..'));
          } else {
            if (asyncSnapshot.hasData) {
              List<DocumentSnapshot> listOfDocumentSnap =
                  asyncSnapshot.data.docs;

              return Flexible(
                child: ListView.builder(
                    itemCount: listOfDocumentSnap.length,
                    itemBuilder: (context, index) {
                      var kimeYorumEmail =
                          listOfDocumentSnap[index].get('kimeYorumEmail');
                      var bildirim = listOfDocumentSnap[index].get('bildirim');
                      var begenKontrol = listOfDocumentSnap[index].get('begen');
                      var email = listOfDocumentSnap[index].get('email');
                      var tarih = listOfDocumentSnap[index].get('tarih');
                      var baslik = listOfDocumentSnap[index].get('metin');
                      var begenMeKontrol =
                          listOfDocumentSnap[index].get('begenMe');
                      var videoFoto =
                          listOfDocumentSnap[index].get('postVideoLinki');
                      var yorumSayisi =
                          listOfDocumentSnap[index].get('yorumSayisi');
                      var postYorumID =
                          listOfDocumentSnap[index].get('postYorumID');

                      var postFotolinki =
                          listOfDocumentSnap[index].get('postFotolinki');

                      var postAydi = listOfDocumentSnap[index].get('postAydi');
                      var update = listOfDocumentSnap[index].reference.update;

                      var bakBegenKontrol =
                          begenKontrol.contains(kullanici.email);
                      var bakBegenMeKontrol =
                          begenMeKontrol.contains(kullanici.email);

                      dynamic profilIsmiCikar(email) {
                        return profilIsmiGetir(email);
                      }

                      dynamic unicCikar(email) {
                        return profilUnicGetir(email);
                      }

                      dynamic profilIdGetire(email) {
                        return profilIdGetir(email);
                      }

                      return Container(
                        child: email != kullanici.email
                            ? kimeYorumEmail == kullanici.email
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      bildirim >= 0.1
                                          ? GestureDetector(
                                              onTap: () async {
                                                Get.to(YorumaYorum(
                                                  postYorumID: postYorumID,
                                                  gelenKullaniciEmail:
                                                      kimeYorumEmail.toString(),
                                                  postAydi: postAydi.toString(),
                                                ));
                                                listOfDocumentSnap[index]
                                                    .reference
                                                    .update({"bildirim": 0.5});
                                              },
                                              child: Card(
                                                color: bildirim >= 1
                                                    ? Colors.white10
                                                    : Colors.black54,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Card(
                                                      color: bildirim >= 1
                                                          ? Colors.white10
                                                          : Colors.black54,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 2,
                                                                    horizontal:
                                                                        2),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              8),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              15.0),
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      //color: Colors.blue,
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          // puanSa.put('postAydi', postAydi.toString());
                                                                          puanSa.put(
                                                                              'email',
                                                                              email.toString());
                                                                          Get.to(
                                                                              YeniZiyaretciProfil(gelenKullaniciEmail: email));
                                                                        },
                                                                        child: profilResmiGetir(
                                                                            email.toString()),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  profilIsmiCikar(
                                                                      email),
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceAround,
                                                                    children: [
                                                                      Card(
                                                                        child: profilIdGetire(
                                                                            email),
                                                                      ),
                                                                      Card(
                                                                        child: unicCikar(
                                                                            email),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              2),
                                                                      child: Text(
                                                                          tarih.toString() +
                                                                              ' ',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              //fontWeight: FontWeight.bold,
                                                                              color: Colors.white60,
                                                                              fontSize: 10))),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(1.0),
                                                            child: IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  listOfDocumentSnap[
                                                                          index]
                                                                      .reference
                                                                      .update({
                                                                    "bildirim":
                                                                        0
                                                                  });
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons.delete,
                                                                  size: 20,
                                                                  color: Colors
                                                                      .red,
                                                                )),
                                                          ),

                                                          //postuDuzenleIconu(email, postAydi),
                                                        ],
                                                      ),
                                                    ),
                                                    ikinciBolumText(baslik),
                                                    ucuncuBolumVideoFotograf(
                                                        videoFoto,
                                                        postFotolinki),
                                                    DorduncuBolumAltBar(
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
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Center(),
                                    ],
                                  )
                                : Center()
                            : Center(),
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

  ///

  ///
}
