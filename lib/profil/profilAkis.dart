import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicotantic/profil/baskaAkisaMetinGirYeni.dart';
import 'package:unicotantic/profil/bireyselAkis.dart';

import '../Unic/doluAkis/doluAkisAppBar.dart';
import '../Unic/fonksiyonlar/kullaniciProfilUstBar.dart';
import 'BenDrawer.dart';
import 'ayarlar.dart';
import 'profilBilgilerim.dart';
import 'profilYorumBolumu.dart';
import 'profil_fotograf_degistir.dart';

///////////////////////////////////
class ProfilAkis extends StatefulWidget {
  const ProfilAkis({super.key});

  @override
  State<ProfilAkis> createState() => _ProfilAkisState();
}

class _ProfilAkisState extends State<ProfilAkis> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
  ProfilFotografiDegistir getir = const ProfilFotografiDegistir();
  String? indirmeBaglantisi;
  bool postlar = true;

  final getbox = GetStorage();
  GetStorage box = GetStorage();
  dynamic puanSa = Hive.box('unicotantic');
  String galeri = '';
  bool kapat = true;

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

  galeridenYukle() async {
    // ignore: deprecated_member_use
    var alinanDosya = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      yuklenecekDosya = File(alinanDosya!.path);
    });

    Reference referansYol = FirebaseStorage.instance
        .ref()
        .child('profilresimleri')
        .child(kullanici.email.toString())
        .child('${DateTime.now().minute}profilResmi.png');
    UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
    String url = await (await yuklemeGorevi).ref.getDownloadURL();
    setState(() {
      indirmeBaglantisi = url;
      getbox.write('profilresmilinki', indirmeBaglantisi.toString());

      FirebaseFirestore.instance.collection('Kullanicilar').doc(kullanici.email.toString()).update({
        'profilresmilinki': indirmeBaglantisi.toString(),
      });

      FirebaseFirestore.instance.collection('Yazilar').doc(kullanici.email.toString()).update({
        'profilresmilinki': indirmeBaglantisi.toString(),
      });
    });
  }

  @override
  void initState() {
    //firebaseIndirHiveYukleFonksiyonu();
    // TODO: implement initState
    super.initState();
  }

  Future<void> ekleyenKisiDondur() async {
    CollectionReference uyeler = _firestore.collection('uyeler');
    var icerik = uyeler.doc(kullanici.email.toString());
    var secim = await icerik.get();
    dynamic map = secim.data();
    dynamic ekleyenKisi = map['ekleyenKisi'];
    return ekleyenKisi;
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var kullaniciBilgileriSorgu = kullanicilar.doc(kullanici.email);

    return SafeArea(
      child: Scaffold(
        appBar: akisAppBar(),
        drawer: const BenDrawer(),
        body: Center(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
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
                                Container(child: kullaniciProfilUstBar(kullaniciBilgileriSorgu)),
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
                                          Get.to(ProfilYorumBolumu());
                                        },
                                        child: Card(
                                          color: Colors.black38,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Yorumlar',
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
                                              'Akışım',
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
                                        'Akışım',
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  Container(child: BireyselAkis()),
                ],
              ),
              BaskaAkisaMetinGirYeni(gelenKullaniciEmail: kullanici.email.toString()),
            ],
          ),
        ),
      ),
    );
  }

  ///
}
