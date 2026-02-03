import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';

import '../Unic/doluAkis/doluAkisAppBar.dart';
import '../Unic/fonksiyonlar/puan_controller.dart';
import 'BenDrawer.dart';

class ProfilYorumOku extends StatefulWidget {
  const ProfilYorumOku({super.key});

  @override
  State<ProfilYorumOku> createState() => _ProfilYorumOkuState();
}

class _ProfilYorumOkuState extends State<ProfilYorumOku> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  TextEditingController yorumController = TextEditingController();

  final box = GetStorage();
  final controller = Get.put(PuanC());
  double gozetop = Get.height / 5;
  double gozeleft = Get.width / 4;
  GetStorage getbox = GetStorage();
  String alinanDosya = 'assets/images/png/dactylo.png';
  String galeri = '......';
  late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
  String? indirmeBaglantisi;
  final puanSa = Hive.box('unicotantic');

  Future<dynamic> unicCikar() async {
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

  yorumEkle() async {
    //String postID = generateRandomNumber();

    String getfoto = getbox.read("postFotolinki");

    String metino = yorumController.text;
    String puansaPostAydi = puanSa.get('postAydi');
    String puansakimeYorumEmail = puanSa.get('kimeYorumEmail');
    print(puansakimeYorumEmail + ' puansakimeYorumEmail');

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic khakkinda = map['hakkinda'];
    dynamic ksehir = map['sehir'];
    dynamic kisim = map['isim'];
    dynamic ksoyisim = map['soyisim'];
    dynamic kiletisim = map['iletisim'];
    dynamic kdogumtarihi = map['dogum tarihi'];
    dynamic profilresmilinki = map['profilresmilinki'];
    icerik.update({'postSayisi': FieldValue.increment(1)});
    var dtNow = DateTime.now();

    var yil = DateTime.now().year;
    var ay = DateTime.now().month;
    var gun = DateTime.now().day;
    var saat = DateTime.now().hour;
    var dakika = DateTime.now().minute;
    //dynamic unic = map['unic'];

    CollectionReference kullanicilar1 = _firestore.collection('Kullanicilar');
    var icerik1 = kullanicilar1.doc(puanSa.get('kimeYorumEmail'));
    var secim1 = await icerik1.get();
    dynamic map1 = secim1.data();

    dynamic unic = map1['unic'];

    await icerik1.update({'bildirim': FieldValue.increment(1)});

    await FirebaseFirestore.instance.collection("yorumlar").doc(puansaPostAydi).collection("yorumlar").doc().set({
      'postAydi': puansaPostAydi.toString(),
      "email": kullanici.email.toString(),
      "kimeYorumEmail": puansakimeYorumEmail.toString(),
      "id": kullanici.uid.toString(),
      'isim': kisim,
      'soyisim': ksoyisim,
      'sehir': ksehir,
      'dogum tarihi': kdogumtarihi,
      'hakkinda': khakkinda,
      'iletisim': kiletisim,
      'metin': metino,
      'zaman': DateTime.now(),
      'begen': [],
      'yorumSayisi': 0,
      'bildirim': 1,
      'begenMe': [],
      'mapYorum': [],
      'profilresmilinki': profilresmilinki.toString(),
      'tarih': '$gun / ' + '$ay / ' + '$yil    ' + '$saat :' + ' $dakika ',
      'postFotolinki': getfoto.toString(),
      'postVideoLinki': '',
    });
    await FirebaseFirestore.instance.collection("postaYorum").doc().set({
      'postAydi': puansaPostAydi.toString(),
      "email": kullanici.email.toString(),
      "kimeYorumEmail": puansakimeYorumEmail.toString(),
      "id": kullanici.uid.toString(),
      'isim': kisim,
      'soyisim': ksoyisim,
      'sehir': ksehir,
      'dogum tarihi': kdogumtarihi,
      'hakkinda': khakkinda,
      'iletisim': kiletisim,
      'metin': metino,
      'zaman': DateTime.now(),
      'begen': [],
      'yorumSayisi': 0,
      'bildirim': 1,
      'begenMe': [],
      'mapYorum': [],
      'profilresmilinki': profilresmilinki.toString(),
      'tarih': '$gun / ' + '$ay / ' + '$yil    ' + '$saat :' + ' $dakika ',
      'postFotolinki': getfoto.toString(),
      'postVideoLinki': '',
    });

    await FirebaseFirestore.instance
        .collection("postlar")
        .doc(puansaPostAydi)
        .update({'yorumSayisi': FieldValue.increment(1)});

    await FirebaseFirestore.instance
        .collection("postlar")
        .doc(puansaPostAydi)
        .update({'bildirim': FieldValue.increment(1)});

    if (puansakimeYorumEmail != kullanici.email) {
      icerik1.update({'unic': FieldValue.increment(1)});
    }

    //}
  }

  @override
  void initState() {
    FirebaseFirestore.instance.collection("postlar").doc(puanSa.get('postAydi')).update({'bildirim': 0});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference yorumSorgu = _firestore.collection('postlar');
    print(yorumSorgu.toString() + '  yorumSorgu 01');

    var yicerik = yorumSorgu.doc();
    print(yicerik.toString() + '  yicerik 02');

    Query akisSorguy = _firestore.collection('postaYorum').orderBy("zaman", descending: false);
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    return Scaffold(
      //backgroundColor: Colors.teal,
      appBar: akisAppBar(),
      drawer: const BenDrawer(),
      body: Center(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            //Text(puanSa.get('postAydi')),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot>(
                    stream: akisSorguy.snapshots(),
                    builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      if (asyncSnapshot.hasError) {
                        return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                      } else {
                        if (asyncSnapshot.hasData) {
                          List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;
                          //var suzgec = listOfDocumentSnap.indexWhere((element) => true) == puanSa.get('postAydi');

                          return Flexible(
                            child: ListView.builder(
                                itemCount: listOfDocumentSnap.length,
                                itemBuilder: (context, index) {
                                  var begenKontrol = listOfDocumentSnap[index].get('begen');
                                  var isim = listOfDocumentSnap[index].get('isim');
                                  var soyisim = listOfDocumentSnap[index].get('soyisim');
                                  var email = listOfDocumentSnap[index].get('email');
                                  var id = listOfDocumentSnap[index].get('id');
                                  var tarih = listOfDocumentSnap[index].get('tarih');
                                  var baslik = listOfDocumentSnap[index].get('metin');
                                  var sehir = listOfDocumentSnap[index].get('sehir');
                                  var iletisim = listOfDocumentSnap[index].get('iletisim');
                                  var hakkinda = listOfDocumentSnap[index].get('hakkinda');
                                  var dogumtarihi = listOfDocumentSnap[index].get('dogum tarihi');
                                  var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
                                  var yorumMeKontrol = listOfDocumentSnap[index].get('mapYorum');
                                  var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
                                  var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
                                  var profilresmilinki = listOfDocumentSnap[index].get('profilresmilinki');
                                  var postAydi = listOfDocumentSnap[index].get('postAydi');
                                  var update = listOfDocumentSnap[index].reference.update;
                                  var bakBegenKontrol = begenKontrol.contains(kullanici.email);
                                  var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);

                                  return Container(
                                    child: puanSa.get('postAydi') == postAydi
                                        ? Card(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Card(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(15.0),
                                                                bottomRight: Radius.circular(15.0),
                                                              ),
                                                              child: Container(
                                                                color: Colors.blue,
                                                                width: 40.0,
                                                                height: 40.0,
                                                                child: GestureDetector(
                                                                  onTap: () async {
                                                                    CollectionReference kullanicilar =
                                                                        _firestore.collection('Kullanicilar');
                                                                    var icerik = kullanicilar.doc(email);
                                                                    var secim = await icerik.get();
                                                                    dynamic map = secim.data();

                                                                    dynamic profilresmilinki = map['profilresmilinki'];
                                                                  },
                                                                  child: Image.network(
                                                                    profilresmilinki,
                                                                    fit: BoxFit.fill,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text(' ' + isim + ' ' + soyisim,
                                                                  textAlign: TextAlign.start,
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.blueAccent,
                                                                      fontSize: 14)),
                                                              Text(
                                                                ' @' + id.substring(5, 15) + ' ',
                                                                style: const TextStyle(
                                                                    fontSize: 11,
                                                                    fontFamily: 'Montserrat',
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.white70),
                                                              ),
                                                              Text(' ' + tarih.toString() + ' ',
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      //fontWeight: FontWeight.bold,
                                                                      color: Colors.white60,
                                                                      fontSize: 12)),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                //isimTarihEnUstBolum(isim, soyisim, tarih, id),

                                                Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    '${baslik}',
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.green,
                                                      fontFamily: 'montserrat',
                                                      //fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                // profilFotoBaslikAcilanProfilBilgileri(context, isim, soyisim, profilresmilinki, id,
                                                //     sehir, iletisim, hakkinda, dogumtarihi, baslik),
                                                postFotolinki == 'bos'
                                                    ? Center()
                                                    : Image.network(
                                                        postFotolinki,
                                                        fit: BoxFit.fill,
                                                      ),
                                                altButonlar(
                                                    bakBegenKontrol,
                                                    listOfDocumentSnap,
                                                    index,
                                                    email,
                                                    postAydi,
                                                    begenMeKontrol,
                                                    yorumMeKontrol,
                                                    yorumSayisi,
                                                    bakBegenMeKontrol,
                                                    update,
                                                    begenKontrol),
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
            Positioned(
              top: gozetop,
              left: gozeleft,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    gozetop = max(-300, gozetop + details.delta.dy);
                    gozeleft = max(-200, gozeleft + details.delta.dx);
                  });
                },
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: Obx(
                    () => GestureDetector(
                      onTap: () async {
                        getbox.write('postFotolinki', 'bos');
                        var secim = await icerik.get();
                        dynamic map = secim.data();

                        dynamic unic = map['unic'];

                        if (unic <= 0) {
                          controller.acilGoze = false.obs;
                        } else {
                          setState(() {
                            controller.acilGoze = true.obs;
                          });
                        }
                      },
                      child: Wrap(children: [
                        if (controller.acilGoze == true.obs)
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: GestureDetector(
                                      onTap: () async {
                                        setState(() async {
                                          if (yorumController.text.isNotEmpty) {
                                            //kullaniciBilgileriEkle();

                                            var secim = await icerik.get();
                                            dynamic map = secim.data();

                                            dynamic unic = map['unic'];

                                            if (unic <= 0) {
                                            } else {
                                              unicCikar();
                                              yorumEkle();
                                              getbox.write('postFotolinki', 'bos');
                                              galeri = '......';
                                              setState(() {});
                                            }
                                          } else {
                                            FocusScope.of(context).requestFocus(FocusNode());
                                            controller.acilGoze = false.obs;
                                          }

                                          yorumController.clear();
                                        });
                                      },
                                      child: SizedBox(
                                        width: 150,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: SizedBox(
                                                  height: 40,
                                                  width: 50,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      galeridenYukle();
                                                      galeri = '......';
                                                      setState(() {});
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Image.asset(
                                                        'assets/images/png/gallery.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                  height: 40,
                                                  width: 50,
                                                  child: Image.asset(
                                                    'assets/images/png/unic.png',
                                                    fit: BoxFit.cover,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.acilGoze = false.obs;
                                      setState(() {});
                                    },
                                    // kapatma ikonu koyulabilir
                                    child: SizedBox(
                                      height: 300,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                          child: Column(
                                            children: [
                                              Card(
                                                color: Colors.black87,
                                                child: TextField(
                                                    onSubmitted: (value) {
                                                      if (value.isEmpty) {
                                                        //  kullaniciBilgileriEkle();
                                                        yorumEkle();
                                                        galeri = '......';
                                                      } else {
                                                        controller.acilGoze = false.obs;
                                                        setState(() {});
                                                      }
                                                    },
                                                    maxLength: 440,
                                                    maxLines: 5,
                                                    controller: yorumController,
                                                    decoration: InputDecoration(
                                                      focusColor: Colors.cyanAccent,
                                                      //add prefix icon

                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                      ),

                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: const BorderSide(color: Colors.cyan, width: 1.0),
                                                        borderRadius: BorderRadius.circular(10.0),
                                                      ),
                                                      fillColor: Colors.cyanAccent,

                                                      //make hint text
                                                      hintStyle: const TextStyle(
                                                        color: Colors.cyan,
                                                        fontSize: 18,
                                                        fontFamily: "verdana_regular",
                                                        fontWeight: FontWeight.w400,
                                                      ),

                                                      //create lable
                                                      labelText: galeri.toString(),
                                                      //lable style
                                                      labelStyle: const TextStyle(
                                                        textBaseline: TextBaseline.alphabetic,
                                                        color: Colors.cyan,
                                                        fontSize: 18,
                                                        fontFamily: "verdana_regular",
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (controller.acilGoze == false.obs)
                          Center(
                            child: Card(
                              color: Colors.black45,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                    height: 30,
                                    width: 50,
                                    child: Image.asset(
                                      alinanDosya,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            ),
                          ),
                      ]),
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

  ///
  ///
  ///
  Card isimTarihEnUstBolum(isim, soyisim, tarih, id) {
    return Card(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(' ' + isim + ' ' + soyisim,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ' @' + id.substring(5, 15) + ' ',
                style: const TextStyle(
                    fontSize: 11, fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              Text(' ' + tarih.toString() + ' ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      color: Colors.white60,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  ///

  ///
  Row profilFotoBaslikAcilanProfilBilgileri(
      BuildContext context, isim, soyisim, profilresmilinki, id, sehir, iletisim, hakkinda, dogumtarihi, baslik) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
            ),
            child: Container(
              color: Colors.blue,
              width: 70.0,
              height: 70.0,
              child: GestureDetector(
                onTap: () {},
                child: Image.network(
                  profilresmilinki,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: Text(
            '${baslik}',
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontFamily: 'montserrat',
              //fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  ///

  ///

  SizedBox altButonlar(
      contains,
      List<DocumentSnapshot<Object?>> listOfDocumentSnap,
      int index,
      email,
      postAydi,
      begenMeKontrol,
      yorumMeKontrol,
      yorumSayisi,
      containsBegenme,
      Future<void> update(Map<Object, Object?> data),
      begenKontrol) {
    return SizedBox(
      // height: 150,
      child: Card(
        //color: Colors.blueGrey[700],
        //shadowColor: contains ? Colors.greenAccent : Colors.yellow,
        shape: contains
            ? Border(bottom: BorderSide(color: Colors.cyan, width: 5))
            : Border(bottom: BorderSide(color: Colors.white, width: 5)),
        elevation: 0,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                    child: kullanici.email == email.toString()
                        ? IconButton(
                            onPressed: () async {
                              puanSa.put('postAydi', postAydi.toString());

                              await FirebaseFirestore.instance
                                  .collection("postlar")
                                  .doc(puanSa.get('postAydi'))
                                  .update({'yorumSayisi': FieldValue.increment(-1)});

                              await listOfDocumentSnap[index].reference.delete();
                            },
                            icon: const Icon(
                              Icons.delete,
                              size: 23,
                              color: Colors.red,
                            ))
                        : Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2))),
                Text(' ${begenMeKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
                IconButton(
                    onPressed: () async {
                      CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
                      var icerik = kullanicilar.doc(kullanici.email);
                      var secim = await icerik.get();
                      dynamic map = secim.data();

                      dynamic unic = map['unic'];

                      if (unic <= 0) {
                      } else {
                        if (email != kullanici.email) {
                          if (containsBegenme) {
                            update({
                              'begenMe': FieldValue.arrayRemove([kullanici.email])
                            });
                            update({'unic': FieldValue.increment(1)});

                            await FirebaseFirestore.instance
                                .collection("Kullanicilar")
                                .doc(email.toString())
                                .update({"unic": FieldValue.increment(1)});
                          } else {
                            unicCikar();
                            update({
                              'begenMe': FieldValue.arrayUnion([kullanici.email])
                            });
                            update({'unic': FieldValue.increment(-1)});

                            await FirebaseFirestore.instance
                                .collection("Kullanicilar")
                                .doc(email.toString())
                                .update({"unic": FieldValue.increment(-1)});
                          }
                        }
                      }
                    },
                    icon: Icon(
                      Icons.heart_broken,
                      size: 25,
                      color: containsBegenme ? Colors.red : Colors.white70,
                    )),
                Text('${begenKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
                IconButton(
                    onPressed: () async {
                      CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
                      var icerik = kullanicilar.doc(kullanici.email);
                      var secim = await icerik.get();
                      dynamic map = secim.data();

                      dynamic unic = map['unic'];

                      if (unic <= 0) {
                      } else {
                        if (listOfDocumentSnap[index].get('email') != kullanici.email) {
                          if (contains) {
                            update({
                              'begen': FieldValue.arrayRemove([kullanici.email])
                            });
                            update({'unic': FieldValue.increment(-1)});

                            await FirebaseFirestore.instance
                                .collection("Kullanicilar")
                                .doc(email.toString())
                                .update({"unic": FieldValue.increment(-1)});
                          } else {
                            unicCikar();

                            update({
                              'begen': FieldValue.arrayUnion([kullanici.email]),
                            });
                            update({'unic': FieldValue.increment(1)});

                            await FirebaseFirestore.instance
                                .collection("Kullanicilar")
                                .doc(email.toString())
                                .update({"unic": FieldValue.increment(1)});
                          }
                        }
                      }
                    },
                    icon: Icon(
                      Icons.thumb_up_alt_rounded,
                      size: 25,
                      color: contains ? Colors.cyan : Colors.white70,
                    )),
                // IconButton(
                //     onPressed: () async {
                //       puanSa.put('postAydi', postAydi.toString());
                //       puanSa.put('email', email.toString());
                //       print(postAydi.toString());
                //       Get.to(DoluYorumOku());
                //     },
                //     icon: Icon(
                //       Icons.mode_comment_sharp,
                //       size: 25,
                //       color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
                //     )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///
  ///
  ///

  galeridenYukle() async {
    // ignore: deprecated_member_use
    var alinanDosya = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 30);
    setState(() {
      yuklenecekDosya = File(alinanDosya!.path);
    });

    // Seçilen resmi okuyun
    File resimDosyasi = File(alinanDosya!.path);

// Resmin boyutunu alın
    int boyut = await resimDosyasi.length();
    print('Resim Boyutu: $boyut byte');
    // Maksimum boyut sınırlaması (örneğin, 2 MB)
    const maksimumBoyut = 2 * 1024 * 1024; // 2 MB
    print('maksimum buyuat : ' + maksimumBoyut.toString());

    if (boyut > maksimumBoyut) {
      print('Resim çok büyük, yeniden boyutlandırın veya işlem yapın');

      galeri = 'Dosya Boyutu Çok Büyük!';

      //Get.to(const VideoApp());

      // Resim çok büyük, yeniden boyutlandırın veya işlem yapın
      // Örnek: Resmi yeniden boyutlandırma işlemi için flutter_image_compress veya başka bir paket kullanabilirsiniz.
    } else {
      Reference referansYol = FirebaseStorage.instance
          .ref()
          .child('postFotoları')
          .child(kullanici.email.toString())
          .child('${DateTime.now().microsecondsSinceEpoch}postFoto.png');
      UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
      String url = await (await yuklemeGorevi).ref.getDownloadURL();
      setState(() {
        indirmeBaglantisi = url;
        getbox.write('postFotolinki', indirmeBaglantisi.toString());
        galeri = 'Yüklendi.. ileti girin.';
      });
    }
  }
}
