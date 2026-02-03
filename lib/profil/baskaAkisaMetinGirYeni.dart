import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

import '../Unic/fonksiyonlar/altButonlar.dart';
import '../Unic/fonksiyonlar/doluYorumFonksiyonlari.dart';
import '../Unic/fonksiyonlar/puan_controller.dart';

class BaskaAkisaMetinGirYeni extends StatefulWidget {
  final gelenKullaniciEmail;

  BaskaAkisaMetinGirYeni({
    required this.gelenKullaniciEmail,
  });

  @override
  State<BaskaAkisaMetinGirYeni> createState() => _BaskaAkisaMetinGirYeniState();
}

class _BaskaAkisaMetinGirYeniState extends State<BaskaAkisaMetinGirYeni> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
  late File yuklenecekgetThumbnailDosya = 'assets/images/icon/icon256.png' as File;
  String? indirmeBaglantisi;
  String? indirmeBaglantisiThumbnail;

  final _firestore = FirebaseFirestore.instance;
  TextEditingController metinController = TextEditingController();
  TextEditingController baslikController = TextEditingController();
  final box = GetStorage();
  final controller = Get.put(PuanC());
  double gozetop = Get.height / 5;
  double gozeleft = Get.width / 4;
  GetStorage getbox = GetStorage();
  String alinanDosya = 'assets/images/png/dactylo.png';
  String alinanDosyaVideo = 'assets/images/png/dactylo.png';
  String galeri = '.....';

  galeridenYukle() async {
    // ignore: deprecated_member_use
    var alinanDosya = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 40);
    setState(() {
      yuklenecekDosya = File(alinanDosya!.path);
    });

    // Seçilen resmi okuyun
    File resimDosyasi = File(alinanDosya!.path);

// Resmin boyutunu alın
    int boyut = await resimDosyasi.length();
    print('Resim Boyutu: $boyut byte');
    // Maksimum boyut sınırlaması (örneğin, 2 MB)
    const maksimumBoyut = 4 * 1024 * 1024; // 2 MB
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

  compressVideoFile(String alinanDosyaVideo) async {
    final compressVideoFilePath = await VideoCompress.compressVideo(alinanDosyaVideo, quality: VideoQuality.LowQuality);
    return compressVideoFilePath!.file;
  }

  galeridenVideoYukle() async {
    // ignore: deprecated_member_use
    var alinanDosyaVideo = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: 60),
    );
    setState(() {
      galeri = 'Video yükleniyor';
    });

    var compressVideoFilePath =
        await VideoCompress.compressVideo(alinanDosyaVideo!.path, quality: VideoQuality.LowQuality);
    var compressVideoFilePathFile = compressVideoFilePath!.file;

    ///
    var getThumbnail = await VideoCompress.getFileThumbnail(alinanDosyaVideo.path);
    print('ryyjyrj yjy5 k5e5yk yksy kuyk dyk sytkdytkdt kdtktkktkk tkdt y' + getThumbnail.toString());

    setState(() {
      galeri = 'Video yükleniyor...';

      yuklenecekDosya = File(compressVideoFilePathFile!.path);
      yuklenecekgetThumbnailDosya = File(getThumbnail.path);
    });

    // Seçilen resmi okuyun
    File alinanDosyaVideoBoyut = File(alinanDosyaVideo.path);

    /// Resmin boyutunu alın

    int boyut = await alinanDosyaVideoBoyut.length();
    int yuklenecekDosyab = await yuklenecekDosya.length();
    print('Video Boyutu alinanDosyaVideo: $boyut byte');
    print('Video Boyutu yuklenecekDosyab: $yuklenecekDosyab byte');
    // Maksimum boyut sınırlaması (örneğin, 2 MB)
    const maksimumBoyut = 40 * 1024 * 1024; // 2 MB
    print('maksimum buyuat : ' + maksimumBoyut.toString());

    if (yuklenecekDosyab > maksimumBoyut) {
      print('Video çok büyük, yeniden boyutlandırın veya işlem yapın');
      setState(() {
        galeri = 'Video Boyutu Çok Büyük!';
      });

      //Get.to(const VideoApp());

      // Resim çok büyük, yeniden boyutlandırın veya işlem yapın
      // Örnek: Resmi yeniden boyutlandırma işlemi için flutter_image_compress veya başka bir paket kullanabilirsiniz.
    } else {
      var dtNow = DateTime.now().microsecondsSinceEpoch;

      Reference referansYol = FirebaseStorage.instance
          .ref()
          .child('postVideolari')
          .child(kullanici.email.toString())
          .child('${dtNow}postVideo.mp4');
      Reference referansYolFoto = FirebaseStorage.instance
          .ref()
          .child('postVideolari')
          .child(kullanici.email.toString())
          .child('${dtNow}postFoto.jpg');

      UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
      UploadTask yuklemeGoreviThumbnail = referansYolFoto.putFile(yuklenecekgetThumbnailDosya);

      String url = await (await yuklemeGorevi).ref.getDownloadURL();
      String urlyuklemeGoreviThumbnail = await (await yuklemeGoreviThumbnail).ref.getDownloadURL();
      setState(() {
        indirmeBaglantisi = url;
        indirmeBaglantisiThumbnail = urlyuklemeGoreviThumbnail;
        getbox.write('postVideolinki', indirmeBaglantisi.toString());
        getbox.write('getThumbnail', indirmeBaglantisiThumbnail.toString());
        galeri = 'Yüklendi....';
      });
    }
  }

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

  // Rastgele benzersiz sayı üretmek için kullanılacak fonksiyon
  String generateRandomNumber() {
    Random random = Random();
    int randomNumber = random.nextInt(1000000);
    return randomNumber.toString();
  }

  metinEkle() async {
    String baslik = baslikController.text;
    String getfoto = getbox.read("postFotolinki");
    String getVideo = getbox.read("postVideolinki");
    String getThumbnail = getbox.read("getThumbnail");
    String yorumYapanEmail = puanSa.get('yorumYapanEmail');

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();
    dynamic id = map['id'];

    icerik.update({'postSayisi': FieldValue.increment(1)});
    var dtNow = DateTime.now();

    var yil = DateTime.now().year;
    var ay = DateTime.now().month;
    var gun = DateTime.now().day;
    var saat = DateTime.now().hour;
    var dakika = DateTime.now().minute;
    var postAydi = kullanici.email.toString() + dtNow.toString();

    dynamic kisim = map['isim'];
    dynamic ksoyisim = map['soyisim'];
    var fotoLinkToSave = getVideo.toString().length > 5 ? getThumbnail : getfoto;

    await FirebaseFirestore.instance
        .collection("postlar")
        .doc(postAydi.toString())
        .set({
      'id': id.toString(),
      'postAydi': postAydi,
      "email": kullanici.email.toString(),
      "kimeYorumEmail": widget.gelenKullaniciEmail.toString(),
      'postVideoLinki': getVideo.toString(),
      'isim': kisim.toString(),
      'soyisim': ksoyisim.toString(),
      'sehir': '',
      'dogum tarihi': '',
      'hakkinda': '',
      'iletisim': '',
      'metin': '',
      'baslik': baslik,
      'zaman': dtNow,
      'begen': [],
      'yorumSayisi': 0,
      'bildirim': 1,
      'begenMe': [],
      'profilresmilinki': '',
      'tarih': '$gun / ' + '$ay / ' + '$yil    ' + '$saat :' + ' $dakika ',
      'postFotolinki': fotoLinkToSave.toString(),
    });
    await FirebaseFirestore.instance
        .collection("duzenlenmisYorum")
        .doc(postAydi.toString())
        .collection("duzenlemeler")
        .doc()
        .set({
      'id': id.toString(),
      'postAydi': postAydi,
      "email": kullanici.email.toString(),
      "kimeYorumEmail": widget.gelenKullaniciEmail.toString(),
      'postVideoLinki': getVideo.toString(),
      'isim': kisim.toString(),
      'soyisim': ksoyisim.toString(),
      'sehir': '',
      'dogum tarihi': '',
      'hakkinda': '',
      'iletisim': '',
      'metin': '',
      'baslik': baslik,
      'zaman': dtNow,
      'begen': [],
      'yorumSayisi': 0,
      'bildirim': 1,
      'begenMe': [],
      'profilresmilinki': '',
      'tarih': '$gun / ' + '$ay / ' + '$yil    ' + '$saat :' + ' $dakika ',
      'postFotolinki': fotoLinkToSave.toString(),
    });

    // await FirebaseFirestore.instance
    //     .collection("Kullanicilar")
    //     .doc(widget.gelenKullaniciEmail)
    //     .collection("bireyselAkis")
    //     .doc(postAydi.toString())
    //     .update({'bildirim': FieldValue.increment(1)});

    if (widget.gelenKullaniciEmail.toString() != controllerNet.kullanici.email) {
      var icerik1 = FirebaseFirestore.instance.collection('Kullanicilar').doc(widget.gelenKullaniciEmail.toString());
      await icerik1.update({'bildirim': FieldValue.increment(1)});
      await icerik1.update({'unic': FieldValue.increment(1)});
    }
    galeri = '......';
    puanSa.put('yorumYapanEmail', '');
  }

  @override
  void initState() {
    getbox.write('postFotolinki', 'bos');
    getbox.write('postVideolinki', '');
    getbox.write('getThumbnail', '');
    getbox.write('yorumYapanEmail', '');
    controller.acilGoze = false.obs;

    super.initState();
  }

  void dispose() {
    super.dispose();
    puanSa.put('yorumYapanEmail', '');
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);

    return Positioned(
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
                getbox.write('postVideolinki', '');
                getbox.write('getThumbnail', '');
                CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
                var icerik = kullanicilar.doc(kullanici.email);
                var secim = await icerik.get();
                dynamic map = secim.data();

                dynamic kullaniciUnicSayisi = map['unic'];

                if (kullaniciUnicSayisi <= 0) {
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
                                  if (baslikController.text.isNotEmpty) {
                                    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
                                    var icerik = kullanicilar.doc(kullanici.email);
                                    var secim = await icerik.get();
                                    dynamic map = secim.data();

                                    dynamic kullaniciUnicSayisi = map['unic'];

                                    if (kullaniciUnicSayisi <= 0) {
                                    } else {
                                      unicCikar();
                                      metinEkle();
                                      galeri = '.....';

                                      getbox.write('postFotolinki', 'bos');
                                      getbox.write('postVideolinki', '');
                                      getbox.write('getThumbnail', '');
                                      controller.acilGoze = false.obs;

                                      setState(() {});
                                    }
                                  } else {
                                    setState(() {
                                      controller.acilGoze = false.obs;

                                      FocusScope.of(context).requestFocus(FocusNode());
                                    });
                                  }

                                  baslikController.clear();
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
                                          height: 35,
                                          width: 40,
                                          child: GestureDetector(
                                            onTap: () {
                                              galeridenVideoYukle();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Image.asset(
                                                'assets/images/png/camera.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: SizedBox(
                                          height: 35,
                                          width: 40,
                                          child: GestureDetector(
                                            onTap: () {
                                              galeridenYukle();
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
                                          height: 35,
                                          width: 40,
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
                                                metinEkle();
                                                galeri = '.....';
                                                setState(() {});
                                              } else {
                                                controller.acilGoze = false.obs;
                                                setState(() {});
                                              }
                                            },
                                            //keyboardType: TextInputType.text,
                                            textCapitalization: TextCapitalization.sentences,
                                            maxLength: 440,
                                            maxLines: 6,
                                            controller: baslikController,
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
                                              labelText: galeri,
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
    );
  }
}
