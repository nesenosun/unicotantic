import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicotantic/profil/yeniZiyaretciProfil.dart';

import '../../profil/BenDrawer.dart';
import '../doluAkis/doluAkisAppBar.dart';
import '../fonksiyonlar/buildDefaultTextStyle.dart';
import '../fonksiyonlar/profilResmiGetir.dart';
import '../fonksiyonlar/puan_controller.dart';

class DuzenlemeleriGor extends StatefulWidget {
  const DuzenlemeleriGor({super.key});

  @override
  State<DuzenlemeleriGor> createState() => _DuzenlemeleriGorState();
}

class _DuzenlemeleriGorState extends State<DuzenlemeleriGor> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  TextEditingController yorumController = TextEditingController();
  bool kapat = false;

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
    var unic = await KullaniciUnicSayisiGetirFonksiyonu();

    await kullanicidanUnicCikar(unic);
    return unic;
  }

  yorumEkle() async {
    //String postID = generateRandomNumber();

    String getfoto = getbox.read("postFotolinki");

    String metino = yorumController.text;
    String puansaPostAydi = puanSa.get('postAydi');
    String puansaEmail = puanSa.get('email');
    print(puansaEmail + ' nedersin');

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
    var icerik1 = kullanicilar1.doc(puansaEmail);
    var secim1 = await icerik1.get();
    dynamic map1 = secim1.data();

    dynamic unic = map1['unic'];
    await icerik1.update({'bildirim': FieldValue.increment(1)});

    await FirebaseFirestore.instance.collection("yorumlar").doc(puansaPostAydi).collection("yorumlar").doc().set({
      'id': kullanici.uid,
      'postAydi': puansaPostAydi.toString(),
      "email": kullanici.email.toString(),
      "kimeYorumEmail": puansaEmail.toString(),
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
    });
    await FirebaseFirestore.instance.collection("postaYorum").doc().set({
      'id': kullanici.uid,
      'postAydi': puansaPostAydi.toString(),
      "email": kullanici.email.toString(),
      "kimeYorumEmail": puansaEmail.toString(),
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
    });

    await FirebaseFirestore.instance
        .collection("postlar")
        .doc(puansaPostAydi)
        .update({'yorumSayisi': FieldValue.increment(1)});

    await FirebaseFirestore.instance
        .collection("postlar")
        .doc(puansaPostAydi)
        .update({'bildirim': FieldValue.increment(1)});

    if (puansaEmail != kullanici.email) {
      icerik1.update({'unic': FieldValue.increment(1)});
    }

    //}
    galeri = '......';
  }

  @override
  void initState() {
    // FirebaseFirestore.instance.collection("postlar").doc(puanSa.get('postAydi')).update({'bildirim': 0});

    super.initState();
    kapat == true;
  }

  @override
  Widget build(BuildContext context) {
    String puansaPostAydi = puanSa.get('postAydi');
    Query duzenlenmisPostAkis = _firestore
        .collection('duzenlenmisPost')
        .doc(puansaPostAydi)
        .collection('duzenlemeler')
        .orderBy("zaman", descending: true);
    //Query postlarSorgu = _firestore.collection('postlar').orderBy("zaman", descending: false);
    CollectionReference postlar = _firestore.collection('postlar');
    var postIcerik = postlar.doc(puansaPostAydi.toString());
    return SafeArea(
      child: Scaffold(
        appBar: akisAppBar(),
        drawer: const BenDrawer(),
        body: Center(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: duzenlenmisPostAkis.snapshots(),
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
                                var id = listOfDocumentSnap[index].get('id');
                                var tarih = listOfDocumentSnap[index].get('tarih');
                                var baslik = listOfDocumentSnap[index].get('baslik');
                                var duzenlemeMetin = listOfDocumentSnap[index].get('metin');
                                var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
                                var yorumMeKontrol = listOfDocumentSnap[index].get('mapYorum');
                                var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
                                var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
                                var postAydi = listOfDocumentSnap[index].get('postAydi');
                                var update = listOfDocumentSnap[index].reference.update;
                                var bakBegenKontrol = begenKontrol.contains(kullanici.email);
                                var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);

                                dynamic profilResmiCikar(email) {
                                  return profilResmiGetir(email);
                                }

                                dynamic profilIsmiCikar(email) {
                                  return profilIsmiGetir(email);
                                }

                                dynamic profilSoyIsimCikar(email) {
                                  return profilSoyisimGetir(email);
                                }

                                dynamic unicCikar(email) {
                                  return profilUnicGetir(email);
                                }

                                return Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Card(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(15.0),
                                                    bottomRight: Radius.circular(15.0),
                                                  ),
                                                  child: Container(
                                                    //color: Colors.blue,
                                                    width: 42.0,
                                                    height: 42.0,
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        Get.to(YeniZiyaretciProfil(gelenKullaniciEmail: email));
                                                      },
                                                      child: profilResmiCikar(email.toString()),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    profilIsmiCikar(email),
                                                    SizedBox(width: 3),
                                                    profilSoyIsimCikar(email),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Text(
                                                      '@' + id.substring(5, 15) + ' ',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          //fontFamily: 'Montserrat',
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white70),
                                                    ),
                                                    Card(
                                                      child: unicCikar(email),
                                                    ),
                                                  ],
                                                ),
                                                duzenlemeMetin == ''
                                                    ? Text(tarih.toString() + ' ',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            //fontWeight: FontWeight.bold,
                                                            color: Colors.white60,
                                                            fontSize: 12))
                                                    : Text(tarih.toString() + '  düzenlendi ',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            //fontWeight: FontWeight.bold,
                                                            color: Colors.redAccent,
                                                            fontSize: 12)),
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
                                            fontWeight: FontWeight.normal,
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

  Future<void> poostSahibineUnicEkle(postuAtanEmail) async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(postuAtanEmail.toString())
        .update({'unic': FieldValue.increment(1)});
  }

  Future<void> kullanicidanUnicCikar(KullaniciUnicSayisi) async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update(KullaniciUnicSayisi >= 1 ? {"unic": FieldValue.increment(-1)} : {"unic": 0});
  }

  Future<void> postBegeneEmailEkleFonksiyonu(postAydi) async {
    await FirebaseFirestore.instance.collection("postlar").doc(postAydi.toString()).update({
      'begen': FieldValue.arrayUnion([kullanici.email])
    });
  }

  Future<void> postBegeneMEyeEmailEkleFonksiyonu(postAydi) async {
    await FirebaseFirestore.instance.collection("postlar").doc(postAydi.toString()).update({
      'begenMe': FieldValue.arrayUnion([kullanici.email])
    });
  }

  Future<void> postSahibinidenUnicCikar(email) async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(email.toString())
        .update({'unic': FieldValue.increment(-1)});
  }

  Future<void> postBegendenEmailCikarFonksiyonu(postAydi) async {
    await FirebaseFirestore.instance.collection("postlar").doc(postAydi.toString()).update({
      'begen': FieldValue.arrayRemove([kullanici.email])
    });
  }

  Future<void> postBegenMedenEmailCikarFonksiyonu(postAydi) async {
    await FirebaseFirestore.instance.collection("postlar").doc(postAydi.toString()).update({
      'begenMe': FieldValue.arrayRemove([kullanici.email])
    });
  }

  Future<dynamic> postuKimlerBegenmisFonksiyonu(postAydi) async {
    CollectionReference kullanicilar = _firestore.collection('postlar');
    var icerik = kullanicilar.doc(postAydi.toString());
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic postuKimlerBegenmis = map['begen'];
    print(postuKimlerBegenmis.toString());
    return postuKimlerBegenmis;
  }

  Future<dynamic> KullaniciUnicSayisiGetirFonksiyonu() async {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic unic = map['unic'];
    return unic;
  }

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
                onTap: () async {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => acilanProfilBilgileri(
                        isim, soyisim, profilresmilinki, id, sehir, iletisim, hakkinda, dogumtarihi, context),
                  );
                },
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
  AlertDialog acilanProfilBilgileri(
      isim, soyisim, profilresmilinki, id, sehir, iletisim, hakkinda, dogumtarihi, BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
      contentPadding: EdgeInsets.only(top: 5.0),
      title: Text(
        '@' + id.substring(5, 15),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 300,
              child: Image.network(
                profilresmilinki.toString(),
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Card(
                color: Colors.white12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    isim.toString() + ' ' + soyisim.toString(),
                    style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
                  ),
                ),
              ),
            ),
            kutuPaddingler(iletisim),
            kutuPaddingler(sehir),
            kutuPaddingler(dogumtarihi),
            kutuPaddingler(hakkinda),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Kapat'),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  Padding kutuPaddingler(iletisim) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      child: Card(
        color: Colors.white12,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Text(
            iletisim.toString(),
            style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
          ),
        ),
      ),
    );
  }

  Padding paddingKutulari(isim, soyisim) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Text(
        isim.toString() + ' ' + soyisim.toString(),
        style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
      ),
    );
  }

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
        //color: Colors.black38,

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
                Text(' ${begenMeKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
                IconButton(
                    onPressed: () async {
                      var unic = await KullaniciUnicSayisiGetirFonksiyonu();

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
                      var unic = await KullaniciUnicSayisiGetirFonksiyonu();

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
              ],
            ),
          ],
        ),
      ),
    );
  }

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
