// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/Unic/veriTabani/kullaniciYonetimPaneli.dart';
import 'package:video_player/video_player.dart';

import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';

class VeriTabaniYonetimPaneli extends StatefulWidget {
  String gelenKullaniciEmail;
  String gelenKullaniciUid;

  VeriTabaniYonetimPaneli(
      {required this.gelenKullaniciEmail, required this.gelenKullaniciUid});

  @override
  State<VeriTabaniYonetimPaneli> createState() =>
      _VeriTabaniYonetimPaneliState();
}

class _VeriTabaniYonetimPaneliState extends State<VeriTabaniYonetimPaneli> {
  late final VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    //controller.play();
  }

  @override
  Widget build(BuildContext context) {
    final kullanici = FirebaseAuth.instance.currentUser!;
    final _firestore = FirebaseFirestore.instance;
    Query postlarSorgu = _firestore
        .collection('Kullanicilar')
        .orderBy("email", descending: true)
        .limit(50);
    bool buyut = true;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: widget.gelenKullaniciEmail == 'sinermis@gmail.com' ||
                widget.gelenKullaniciEmail == 'nesenosun@gmail.com'
            ? widget.gelenKullaniciUid == 'ojZnZuyhpFQaoaXrr8Zux3DpIwk2' ||
                    widget.gelenKullaniciUid == 'PeIZjGhsTgPNuYKwVPUUJmhRBZG2'
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          color: Colors.green,
                        ),
                        StreamBuilder<QuerySnapshot>(
                            stream: postlarSorgu.snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot asyncSnapshot) {
                              if (asyncSnapshot.hasError) {
                                return const Center(
                                    child: Text(
                                        'Bir hata oluştu tekrar deneyin..'));
                              } else {
                                if (asyncSnapshot.hasData) {
                                  List<DocumentSnapshot> listOfDocumentSnap =
                                      asyncSnapshot.data.docs;

                                  return Flexible(
                                    child: ListView.builder(
                                        itemCount: listOfDocumentSnap.length,
                                        itemBuilder: (context, index) {
                                          // var begen = listOfDocumentSnap[index].get('begen');
                                          // var begenMe = listOfDocumentSnap[index].get('begenMe');
                                          // var bildirim = listOfDocumentSnap[index].get('bildirim');
                                          // var cuzdan = listOfDocumentSnap[index].get('cuzdan');
                                          // var dogumTarihi = listOfDocumentSnap[index].get('dogum tarihi');
                                          var email = listOfDocumentSnap[index]
                                              .get('email');
                                          // var hakkinda = listOfDocumentSnap[index].get('hakkinda');
                                          // var id = listOfDocumentSnap[index].get('id');
                                          // var iletisim = listOfDocumentSnap[index].get('iletisim');
                                          var isim = listOfDocumentSnap[index]
                                              .get('isim');
                                          // var kayitTarihi = listOfDocumentSnap[index].get('kayit tarihi');
                                          // var lazim = listOfDocumentSnap[index].get('lazim');
                                          // var metin = listOfDocumentSnap[index].get('metin');
                                          // var postSayisi = listOfDocumentSnap[index].get('postSayisi');
                                          // var profilresmilinki = listOfDocumentSnap[index].get('profilresmilinki');
                                          // var sehir = listOfDocumentSnap[index].get('sehir');
                                          // var sifre = listOfDocumentSnap[index].get('sifre');
                                          var soyisim =
                                              listOfDocumentSnap[index]
                                                  .get('soyisim');
                                          // tokenlarda problem var
                                          // var token = listOfDocumentSnap[index].get('token');
                                          var uid = listOfDocumentSnap[index]
                                              .get('uid');
                                          var unic = listOfDocumentSnap[index]
                                              .get('unic');

                                          return SizedBox(
                                            //height: 30,
                                            child: GestureDetector(
                                              onTap: () {
                                                Get.to(KullaniciYonetimPaneli(
                                                    gelenKullaniciEmail: email,
                                                    gelenKullaniciUid: uid));
                                              },
                                              child: Card(
                                                color: Colors.blueGrey,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                              isim.toString() +
                                                                  ' ' +
                                                                  soyisim),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                              email.toString()),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(uid
                                                              .toString()
                                                              .substring(
                                                                  5, 15)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                              unic.toString()),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
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
                            }),
                      ],
                    ),
                  )
                : Container(
                    height: 150,
                    width: 150,
                    color: Colors.yellow,
                  )
            : Container(
                // Expanded(
                //   child: Container(
                //     //height: 30,
                //     //width: 150,
                //     color: Colors.green,
                //     child: Row(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Expanded(child: Center(child: Text('Doğru'))),
                //         Expanded(child: Center(child: Text('Yanlış'))),
                //       ],
                //     ),
                //   ),
                // ),
                // Expanded(
                //   child: Container(
                //     //height: 30,
                //     //width: 150,
                //     color: Colors.red,
                //     //child: Text('Doğrulanmış'),
                //   ),
                // ),
                // Expanded(
                //   child: Container(
                //     //height: 30,
                //     //width: 150,
                //     color: Colors.yellow,
                //     //child: Text('Doğrulanmış'),
                //   ),
                // ),
                height: 150,
                width: 150,
                color: Colors.white,
              ),
      ),
    );
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
}
