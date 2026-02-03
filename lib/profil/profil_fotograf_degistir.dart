import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilFotografiDegistir extends StatefulWidget {
  const ProfilFotografiDegistir({Key? key}) : super(key: key);

  @override
  State<ProfilFotografiDegistir> createState() => _ProfilFotografiDegistirState();
}

class _ProfilFotografiDegistirState extends State<ProfilFotografiDegistir> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
  String? indirmeBaglantisi;
  GetStorage getbox = GetStorage();

  kameradanYukle() async {
    // ignore: deprecated_member_use
    var alinanDosya = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      yuklenecekDosya = File(alinanDosya!.path);
    });

    Reference referansYol = FirebaseStorage.instance
        .ref()
        .child('profilresimleri')
        .child(kullanici.email.toString())
        .child('profilResmi.png');
    UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
    String url = await (await yuklemeGorevi).ref.getDownloadURL();
    setState(() {
      indirmeBaglantisi = url;
      getbox.write('profilresmilinki', indirmeBaglantisi.toString());
    });
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
        .child('profilresimleri')
        .child('${DateTime.now().second}profilResmi.png');
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
  Widget build(BuildContext context) {
    final kullanici = FirebaseAuth.instance.currentUser!;
    final _firestore = FirebaseFirestore.instance;

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');

    var icerik = kullanicilar.doc(kullanici.email);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              galeridenYukle();
            });
          },
          child: SizedBox(
            height: 100,
            width: 100,
            child: StreamBuilder<DocumentSnapshot>(
                stream: icerik.snapshots(),
                builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                  if (asyncSnapshot.hasError) {
                    return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                  } else {
                    if (asyncSnapshot.hasData) {
                      return Image.network(
                        '${asyncSnapshot.data.data()['profilresmilinki']}',
                        fit: BoxFit.fill,
                      );
                    } else {
                      /// yükleniyor bölümü
                      return DefaultTextStyle(
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            backgroundColor: Colors.black54,
                            color: Colors.greenAccent,
                            fontSize: 25.0,
                            fontFamily: 'Chivo',
                            fontWeight: FontWeight.bold),
                        child: AnimatedTextKit(
                          pause: const Duration(seconds: 3),
                          stopPauseOnTap: true,
                          isRepeatingAnimation: false,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              curve: Curves.decelerate,
                              "..........Unic Otantic",
                              textAlign: TextAlign.center,
                              speed: const Duration(milliseconds: 200),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                }),
          ),
        ),
      ],
    );
  }
}
