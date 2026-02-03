// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicotantic/Unic/veriTabani/kullaniciProfiliDuzenle.dart';
import 'package:video_player/video_player.dart';

import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';

class KullaniciYonetimPaneli extends StatefulWidget {
  String gelenKullaniciEmail;
  String gelenKullaniciUid;

  KullaniciYonetimPaneli(
      {required this.gelenKullaniciEmail, required this.gelenKullaniciUid});

  @override
  State<KullaniciYonetimPaneli> createState() => _KullaniciYonetimPaneliState();
}

class _KullaniciYonetimPaneliState extends State<KullaniciYonetimPaneli> {
  late final VideoPlayerController controller;
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  final puanSa = Hive.box('unicotantic');
  late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
  String? indirmeBaglantisi;
  GetStorage getbox = GetStorage();
  String galeri = '';

  final isimC = TextEditingController();
  final soyadC = TextEditingController();
  final dogumTarihiC = TextEditingController();
  final iletisimC = TextEditingController();
  final hakkindaC = TextEditingController();
  final sehirC = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  Future<void> isimEkle() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(widget.gelenKullaniciEmail)
        .update({
      'isim': isimC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic isim = map['isim'];

    puanSa.put('isim', isim.toString());
    setState(() {});
  }

  Future<void> soyIsimEkle() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(widget.gelenKullaniciEmail)
        .update({
      'soyisim': soyadC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic soyisim = map['soyisim'];

    getbox.write('soyisim', soyisim.toString());
    setState(() {});
  }

  Future<void> dogumTarihi() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(widget.gelenKullaniciEmail)
        .update({
      'dogum tarihi': dogumTarihiC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic dogumtarihi = map['dogum tarihi'];

    getbox.write('dogum tarihi', dogumtarihi.toString());
    setState(() {});
  }

  Future<void> iletisimEkle() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(widget.gelenKullaniciEmail)
        .update({
      'iletisim': iletisimC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic iletisim = map['iletisim'];

    getbox.write('iletisim', iletisim.toString());
    setState(() {});
  }

  Future<void> sehirEkle() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(widget.gelenKullaniciEmail)
        .update({
      'sehir': sehirC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic sehir = map['sehir'];

    getbox.write('sehir', sehir.toString());
    setState(() {});
  }

  Future<void> hakkindaEkle() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(widget.gelenKullaniciEmail)
        .update({
      'hakkinda': hakkindaC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic hakkinda = map['hakkinda'];

    getbox.write('hakkinda', hakkinda.toString());
    setState(() {});
  }

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
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var kullaniciBilgileriSorgu = kullanicilar.doc(widget.gelenKullaniciEmail);

    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Form(
              key: _key,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      color: Colors.green,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.gelenKullaniciEmail +
                            '\n' +
                            widget.gelenKullaniciUid.toString()),
                      ),
                    ),
                    StreamBuilder<DocumentSnapshot>(
                        stream: kullaniciBilgileriSorgu.snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot asyncSnapshot) {
                          if (asyncSnapshot.hasError) {
                            return const Center(
                                child:
                                    Text('Bir hata oluştu tekrar deneyin..'));
                          } else {
                            if (asyncSnapshot.hasData) {
                              var begen = asyncSnapshot.data.data()['begen'];
                              var begenMe =
                                  asyncSnapshot.data.data()['begenme'];
                              var bildirim =
                                  asyncSnapshot.data.data()['bildirim'];
                              var cuzdan = asyncSnapshot.data.data()['cuzdan'];
                              var dogumTarihi =
                                  asyncSnapshot.data.data()['dogum tarihi'];
                              var email = asyncSnapshot.data.data()['email'];
                              var hakkinda =
                                  asyncSnapshot.data.data()['hakkinda'];
                              var id = asyncSnapshot.data.data()['id'];
                              var iletisim =
                                  asyncSnapshot.data.data()['iletisim'];
                              var isim = asyncSnapshot.data.data()['isim'];
                              var kayitTarihi =
                                  asyncSnapshot.data.data()['kayit tarihi'];
                              var lazim = asyncSnapshot.data.data()['lazim'];

                              var uid = asyncSnapshot.data.data()['uid'];
                              var soyisim =
                                  asyncSnapshot.data.data()['soyisim'];
                              var sehir = asyncSnapshot.data.data()['sehir'];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 140,
                                          child: Stack(children: [
                                            GestureDetector(
                                              onTap: () {
                                                galeridenProfilFotoYukleme(
                                                    email);
                                              },
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white70,
                                                radius: 60,
                                                child: ClipOval(
                                                  child: Image.network(
                                                    '${asyncSnapshot.data.data()['profilresmilinki']}',
                                                    width: 110,
                                                    height: 110,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 80,
                                              top: 80,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  //SystemNavigator.pop();
                                                  Get.to(
                                                      const KullaniciProfiliDuzenle());
                                                },
                                                child: SizedBox(
                                                  child: Image.asset(
                                                      'assets/images/png/arti.png'),
                                                  height: 35,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 10,
                                              top: 120,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Text(
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 12,
                                                        color:
                                                            Colors.greenAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        shadows: [
                                                          BoxShadow(
                                                              color: Colors.red
                                                                  .withOpacity(
                                                                      .15),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 10),
                                                        ]),
                                                    '@' +
                                                        uid
                                                            .toString()
                                                            .substring(5, 15),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Text(
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 12,
                                                        color:
                                                            Colors.greenAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        shadows: [
                                                          BoxShadow(
                                                              color: Colors.red
                                                                  .withOpacity(
                                                                      .15),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 10),
                                                        ]),
                                                    email.toString(),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Text(
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 12,
                                                        color:
                                                            Colors.greenAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        shadows: [
                                                          BoxShadow(
                                                              color: Colors.red
                                                                  .withOpacity(
                                                                      .15),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 10),
                                                        ]),
                                                    isim.toString() +
                                                        ' ' +
                                                        soyisim.toString(),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Text(
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 12,
                                                        color:
                                                            Colors.greenAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        shadows: [
                                                          BoxShadow(
                                                              color: Colors.red
                                                                  .withOpacity(
                                                                      .15),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 10),
                                                        ]),
                                                    sehir.toString() +
                                                        '       ' +
                                                        dogumTarihi.toString(),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Text(
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 13,
                                                        color:
                                                            Colors.greenAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        shadows: [
                                                          BoxShadow(
                                                              color: Colors.red
                                                                  .withOpacity(
                                                                      .15),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 10),
                                                        ]),
                                                    iletisim.toString(),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Text(
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 11,
                                                        color: Colors
                                                            .orangeAccent[700],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        shadows: [
                                                          BoxShadow(
                                                              color: Colors.red
                                                                  .withOpacity(
                                                                      .15),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 10),
                                                        ]),
                                                    hakkinda.toString(),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              /// yükleniyor bölümü
                              return buildDefaultTextStyle();
                            }
                          }
                        }),
                    Card(
                      //color: Colors.black87,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),

                            textFieldMethod(
                                isimC,
                                Icons.account_circle_outlined,
                                'isim',
                                isimEkle),
                            textFieldMethod(soyadC, Icons.account_circle,
                                'Soy isim', soyIsimEkle),
                            textFieldMethod(sehirC, Icons.location_city,
                                'Şehir', sehirEkle),
                            textFieldMethod(dogumTarihiC, Icons.cake_sharp,
                                'Doğum Tarihi', dogumTarihi),
                            textFieldMethod(
                                iletisimC,
                                Icons.accessibility_new_outlined,
                                'İletişim',
                                iletisimEkle),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      maxLength: 90,
                                      maxLines: 3,
                                      controller: hakkindaC,
                                      obscureText: false,
                                      style: const TextStyle(
                                          color: Colors.cyanAccent,
                                          fontSize: 16),
                                      decoration: InputDecoration(
                                        focusColor: Colors.black54,
                                        //add prefix icon
                                        prefixIcon: const Icon(
                                          Icons.accessibility_new_outlined,
                                          color: Colors.cyanAccent,
                                          size: 30,
                                        ),

                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),

                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.cyanAccent,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        fillColor: Colors.black54,

                                        //hintText: "İsim",

                                        //make hint text
                                        hintStyle: const TextStyle(
                                          color: Colors.cyanAccent,
                                          fontSize: 16,
                                          fontFamily: "verdana_regular",
                                          fontWeight: FontWeight.w400,
                                        ),

                                        labelText: 'Hakkımda',

                                        //lable style
                                        labelStyle: const TextStyle(
                                          color: Colors.cyanAccent,
                                          fontSize: 16,
                                          fontFamily: "verdana_regular",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: hakkindaEkle,
                                      child: const Text('Ok'),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 1),

                            // not a member? register now
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
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

  void galeridenProfilFotoYukleme(email) async {
    final kullanici = FirebaseAuth.instance.currentUser!;
    final _firestore = FirebaseFirestore.instance;

    final puanSa = Hive.box('unicotantic');
    late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
    String? indirmeBaglantisi;
    GetStorage getbox = GetStorage();
    String galeri = '';
    // ignore: deprecated_member_use
    var alinanDosya = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 30);

    //setState(() {
    if (alinanDosya != null) {
      yuklenecekDosya = File(alinanDosya!.path);
      //fotografKes(File(alinanDosya!.path));
    }
    //});

    // Seçilen resmi okuyun
    File resimDosyasi = File(alinanDosya!.path);

// Resmin boyutunu alın
    int boyut = await resimDosyasi.length();
    print('Resim Boyutu: $boyut byte');
    // Maksimum boyut sınırlaması (örneğin, 2 MB)
    const maksimumBoyut = 2 * 1024 * 1024; // 2 MB
    print('maksimum Boyut : ' + maksimumBoyut.toString());

    if (boyut > maksimumBoyut) {
      print('Resim çok büyük, yeniden boyutlandırın veya işlem yapın');

      galeri = 'Fotoğraf Boyutu Çok Büyük!';

      //Get.to(const VideoApp());

      // Resim çok büyük, yeniden boyutlandırın veya işlem yapın
      // Örnek: Resmi yeniden boyutlandırma işlemi için flutter_image_compress veya başka bir paket kullanabilirsiniz.
    } else {
      Reference referansYol = FirebaseStorage.instance
          .ref()
          .child('profilresimleri')
          .child(kullanici.email.toString())
          .child('profilresimleri')
          .child('${DateTime.now().second}profilResmi.png');
      UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
      String url = await (await yuklemeGorevi).ref.getDownloadURL();

      indirmeBaglantisi = url;
      getbox.write('profilresmilinki', indirmeBaglantisi.toString());

      FirebaseFirestore.instance.collection('Kullanicilar').doc(email).update({
        'profilresmilinki': indirmeBaglantisi.toString(),
      });
      galeri = '';
    }
  }

  Padding textFieldMethod(isimC, icon, isim, isimEkle) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: TextFormField(
              maxLength: 25,
              maxLines: 1,
              controller: isimC,
              obscureText: false,
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 16),
              decoration: InputDecoration(
                focusColor: Colors.black54,
                //add prefix icon
                prefixIcon: Icon(
                  icon,
                  color: Colors.cyanAccent,
                  size: 30,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.cyanAccent, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                fillColor: Colors.black54,

                //hintText: "İsim",

                //make hint text
                hintStyle: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 12,
                  fontFamily: "verdana_regular",
                  fontWeight: FontWeight.w400,
                ),

                labelText: isim,

                //lable style
                labelStyle: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 16,
                  fontFamily: "verdana_regular",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: isimEkle,
              child: const Text('Ok'),
            ),
          ),
        ],
      ),
    );
  }
}
