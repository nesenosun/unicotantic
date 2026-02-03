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
import 'package:unicotantic/profil/yeniZiyaretciProfil.dart';

import '../../profil/BenDrawer.dart';
import '../doluAkis/doluAkisAppBar.dart';
import '../fonksiyonlar/buildDefaultTextStyle.dart';
import '../fonksiyonlar/profilResmiGetir.dart';
import '../fonksiyonlar/puan_controller.dart';

class PostuDuzenle extends StatefulWidget {
  const PostuDuzenle({super.key});

  @override
  State<PostuDuzenle> createState() => _PostuDuzenleState();
}

class _PostuDuzenleState extends State<PostuDuzenle> {
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

    await FirebaseFirestore.instance
        .collection("duzenlenmisPost")
        .doc(puansaPostAydi)
        .collection("duzenlemeler")
        .doc()
        .set({
      'id': kullanici.uid,
      'postAydi': kullanici.email.toString() + dtNow.toString(),
      "email": kullanici.email.toString(),
      'isim': kisim,
      'unic': unic,
      'soyisim': ksoyisim,
      'sehir': ksehir,
      'dogum tarihi': kdogumtarihi,
      'hakkinda': khakkinda,
      'iletisim': kiletisim,
      'metin': metino,
      'baslik': metino,
      'zaman': dtNow,
      'tarih': '$gun / ' + '$ay / ' + '$yil    ' + '$saat :' + ' $dakika ',
      'begen': [],
      'yorumSayisi': 0,
      'bildirim': 0,
      'begenMe': [],
      'mapYorum': [],
      'profilresmilinki': profilresmilinki.toString(),
      'postFotolinki': getfoto.toString(),
    });
    await FirebaseFirestore.instance.collection("postlar").doc(puansaPostAydi.toString()).update({
      'duzenlendi': 'duzenlendi',
      'baslik': metino,
      'tarih': '$gun / ' + '$ay / ' + '$yil    ' + '$saat :' + ' $dakika ',
      'postFotolinki': getfoto.toString(),
    });

    if (puansaEmail != kullanici.email) {
      icerik1.update({'unic': FieldValue.increment(-1)});
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
    Query postaYorumSorgu = _firestore.collection('postaYorum').orderBy("zaman", descending: false);
    //Query postlarSorgu = _firestore.collection('postlar').orderBy("zaman", descending: false);
    CollectionReference postlar = _firestore.collection('postlar');
    var postIcerik = postlar.doc(puansaPostAydi.toString());
    return SafeArea(
      child: Scaffold(
        appBar: akisAppBar(),
        drawer: const BenDrawer(),
        body: Stack(
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: postIcerik.snapshots(),
                builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                  if (asyncSnapshot.hasError) {
                    return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                  } else {
                    if (asyncSnapshot.hasData) {
                      var postBegen = asyncSnapshot.data.data()['begen'];
                      var postuAtanEmail = asyncSnapshot.data.data()['email'];
                      var postId = asyncSnapshot.data.data()['id'];
                      var postTarih = asyncSnapshot.data.data()['tarih'];
                      var postBaslik = asyncSnapshot.data.data()['baslik'];
                      var postBegenMe = asyncSnapshot.data.data()['begenMe'];
                      var postFotolinki = asyncSnapshot.data.data()['postFotolinki'];
                      var postAydi = asyncSnapshot.data.data()['postAydi'];

                      var bakBegenKontrol = postBegen.contains(kullanici.email);
                      var bakBegenMeKontrol = postBegenMe.contains(kullanici.email);

                      dynamic profilResmiCikar(email) {
                        return profilResmiGetir(email);
                      }

                      dynamic profilIsmiCikar(email) {
                        return profilIsmiGetir(email);
                      }

                      dynamic profilSoyIsimCikar(email) {
                        return profilSoyisimGetir(email);
                      }

                      dynamic unicCikarGetir(email) {
                        return profilUnicGetir(email);
                      }

                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Card(
                              color: Colors.indigo,
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
                                          color: Colors.blue,
                                          width: 42.0,
                                          height: 42.0,
                                          child: GestureDetector(
                                            onTap: () async {
                                              Get.to(YeniZiyaretciProfil(gelenKullaniciEmail: postuAtanEmail));
                                            },
                                            child: profilResmiCikar(postuAtanEmail.toString()),
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
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          profilIsmiCikar(postuAtanEmail),
                                          SizedBox(width: 3),
                                          profilSoyIsimCikar(postuAtanEmail),
                                        ],
                                      ),
                                      Text(
                                        '@' + postId.substring(5, 15) + ' ',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            //fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70),
                                      ),
                                      Text(postTarih.toString() + ' ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              //fontWeight: FontWeight.bold,
                                              color: Colors.white60,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            //isimTarihEnUstBolum(isim, soyisim, tarih, id),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                postFotolinki == 'bos'
                                    ? Center()
                                    : Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          child: Image.network(
                                            postFotolinki,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: SizedBox(
                                      height: 120,
                                      width: 230,
                                      child: SingleChildScrollView(
                                        child: Text(
                                          postBaslik.toString(),
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontFamily: 'montserrat',
                                            //fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Container(
                              height: 40,
                              //color: Colors.indigo,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                                      child: kullanici.email == postuAtanEmail.toString()
                                          ? IconButton(
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection("postlar")
                                                    .doc(postAydi.toString())
                                                    .update({'baslik': ' Bu içerik Kullanıcı tarafından silinmiştir'});
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.red,
                                              ))
                                          : Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2))),
                                  Text(' ${postBegenMe.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
                                  IconButton(
                                      onPressed: () async {
                                        var KullaniciUnicSayisi = await KullaniciUnicSayisiGetirFonksiyonu();

                                        if (KullaniciUnicSayisi <= 0) {
                                        } else {
                                          if (postuAtanEmail != kullanici.email) {
                                            if (bakBegenMeKontrol) {
                                              await postBegenMedenEmailCikarFonksiyonu(postAydi);
                                              await poostSahibineUnicEkle(postuAtanEmail);
                                            } else {
                                              await postBegenMEyeEmailEkleFonksiyonu(postAydi);
                                              await kullanicidanUnicCikar(KullaniciUnicSayisi);
                                              await postSahibinidenUnicCikar(postuAtanEmail);
                                            }
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        Icons.heart_broken,
                                        size: 20,
                                        color: Colors.white70,
                                      )),
                                  Text('${postBegen.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
                                  IconButton(
                                      onPressed: () async {
                                        var KullaniciUnicSayisi = await KullaniciUnicSayisiGetirFonksiyonu();

                                        if (KullaniciUnicSayisi <= 0) {
                                        } else {
                                          if (postuAtanEmail != kullanici.email) {
                                            if (bakBegenKontrol) {
                                              await postBegendenEmailCikarFonksiyonu(postAydi);

                                              await postSahibinidenUnicCikar(postuAtanEmail);
                                            } else {
                                              await postBegeneEmailEkleFonksiyonu(postAydi);
                                              await kullanicidanUnicCikar(KullaniciUnicSayisi);
                                              await poostSahibineUnicEkle(postuAtanEmail);
                                            }
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        Icons.thumb_up_alt_rounded,
                                        size: 20,
                                        color: Colors.white70,
                                      )),
                                ],
                              ),
                            ),

                            Container(color: Colors.red, height: 2),
                          ],
                        ),
                      );
                    } else {
                      /// yükleniyor bölümü
                      return buildDefaultTextStyle();
                    }
                  }
                }),
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
                        var secim = await postIcerik.get();
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

                                            var secim = await postIcerik.get();
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

  Future<void> postBegenMEyeEmailEkleFonksiyonu(postAydi) async {
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
