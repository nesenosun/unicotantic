import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicotantic/Unic/fonksiyonlar/profilResmiGetir.dart';

import '../../profil/profil_duzenle.dart';
import 'buildDefaultTextStyle.dart';

StreamBuilder<DocumentSnapshot<Object?>> kullaniciProfilUstBar(DocumentReference<Object?> kullaniciBilgileriSorgu) {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  CollectionReference uyeler = _firestore.collection('uyeler');
  uyeler.doc(kullanici.email.toString());
  var kullaniciBilgileriSorgu = kullanicilar.doc(kullanici.email);
  return StreamBuilder<DocumentSnapshot>(
      stream: kullaniciBilgileriSorgu.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData) {
            var uid = asyncSnapshot.data.data()['uid'];
            var profilGizli = asyncSnapshot.data.data()['profilGizli'];
            var username = asyncSnapshot.data.data()['username'];
            var id = asyncSnapshot.data.data()['id'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 140,
                        child: Stack(children: [
                          GestureDetector(
                            onTap: () {
                              galeridenProfilFotoYukleme();
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
                                Get.to(const ProfilDuzenle());
                              },
                              child: SizedBox(
                                child: Image.asset('assets/images/png/arti.png'),
                                height: 35,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 80,
                            top: 0,
                            child: GestureDetector(
                              onTap: () async {},
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: IconButton(
                                    onPressed: () async {
                                      if (profilGizli == false) {
                                        await FirebaseFirestore.instance
                                            .collection("Kullanicilar")
                                            .doc(kullanici.email)
                                            .update({'profilGizli': true});
                                      } else {
                                        await FirebaseFirestore.instance
                                            .collection("Kullanicilar")
                                            .doc(kullanici.email)
                                            .update({'profilGizli': false});
                                      }
                                    },
                                    icon: Icon(
                                      Icons.lock,
                                      size: 30,
                                      color: profilGizli == true ? Colors.red : Colors.white70,
                                    )),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: 120,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: id == '.....'
                                  ? Text(
                                      style: textStyleM(),
                                      '@' + uid.toString().substring(5, 15),
                                      textAlign: TextAlign.center)
                                  : Text(style: textStyleM(), '@' + id.toString(), textAlign: TextAlign.center),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            profilIsmiGetir(kullanici.email),
                            profilIletisimGetir(kullanici.email),
                            profilEmailGetir(kullanici.email),
                            profilHakkinda(kullanici.email),
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
      });
}

TextStyle textStyleM() {
  return TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 11,
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      shadows: [
        BoxShadow(color: Colors.red.withOpacity(.15), offset: Offset(2.0, 2.0), blurRadius: 10),
      ]);
}

void galeridenProfilFotoYukleme() async {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  final puanSa = Hive.box('unicotantic');
  late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
  String? indirmeBaglantisi;
  GetStorage getbox = GetStorage();
  String galeri = '';
  // ignore: deprecated_member_use
  var alinanDosya = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 30);

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

    FirebaseFirestore.instance.collection('Kullanicilar').doc(kullanici.email.toString()).update({
      'profilresmilinki': indirmeBaglantisi.toString(),
    });
    galeri = '';
  }
}
