import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grock/grock.dart';
import 'package:unicotantic/Unic/fonksiyonlar/controllerNet.dart';
import 'package:unicotantic/Unic/fonksiyonlar/negatifOyVer_pozitifOyVer.dart';

import 'package:unicotantic/Unic/fonksiyonlar/altButonlar.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:unicotantic/profil/yeniZiyaretciProfil.dart';

///////////////////////////////////
class ArkadaslarProfil extends StatefulWidget {
  String gelenKullaniciEmail;

  ArkadaslarProfil({required this.gelenKullaniciEmail});

  @override
  State<ArkadaslarProfil> createState() => _ArkadaslarProfilState();
}

class _ArkadaslarProfilState extends State<ArkadaslarProfil> {
  final controllerNet = Get.put(ControllerNet());

  bool kapat = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference kullaniciSorgu =
        controllerNet.firestore.collection('Kullanicilar');

    var kullaniciBilgileri =
        kullaniciSorgu.doc(widget.gelenKullaniciEmail.toString());

    return Container(
      child: StreamBuilder<DocumentSnapshot>(
          stream: kullaniciBilgileri.snapshots(),
          builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
            if (kullaniciBilgileri.isEmpty) {
              return Center();
            } else {
              if (asyncSnapshot.hasError) {
                return const Center(
                    child: Text('Bir hata oluştu tekrar deneyin..'));
              } else {
                if (asyncSnapshot.hasData) {
                  var ziyaretciProfilResmiLinki =
                      asyncSnapshot.data.data()['profilresmilinki'];
                  var isim = asyncSnapshot.data.data()['isim'];
                  var soyisim = asyncSnapshot.data.data()['soyisim'];
                  var iletisim = asyncSnapshot.data.data()['iletisim'];
                  var unic = asyncSnapshot.data.data()['unic'];
                  var id = asyncSnapshot.data.data()['id'];
                  var email = asyncSnapshot.data.data()['email'];

                  return Column(
                    children: [
                      Container(
                        //height: 50,
                        child: GestureDetector(
                          onTap: () {
                            if (email.toString() == '') {
                            } else {
                              Get.to(YeniZiyaretciProfil(
                                  gelenKullaniciEmail: email));
                            }

                            print(email +
                                '                    ttttttttttttt  tttttt  tttttt   ttttttttt  ttttttt');
                          },
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white70,
                                  radius: 40,
                                  child: ClipOval(
                                    child: Image.network(
                                      ziyaretciProfilResmiLinki.toString(),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text(
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 12,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  BoxShadow(
                                                      color: Colors.red
                                                          .withOpacity(.15),
                                                      offset: Offset(2.0, 2.0),
                                                      blurRadius: 10),
                                                ]),
                                            '@' +
                                                id.toString() +
                                                '   ' +
                                                'unic: ' +
                                                unic.toString(),
                                            textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text(
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 12,
                                                color: Colors.greenAccent,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  BoxShadow(
                                                      color: Colors.red
                                                          .withOpacity(.15),
                                                      offset: Offset(2.0, 2.0),
                                                      blurRadius: 10),
                                                ]),
                                            isim.toString() +
                                                ' ' +
                                                soyisim.toString(),
                                            textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 13,
                                                color: Colors.greenAccent,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  BoxShadow(
                                                      color: Colors.red
                                                          .withOpacity(.15),
                                                      offset: Offset(2.0, 2.0),
                                                      blurRadius: 10),
                                                ]),
                                            iletisim.toString(),
                                            textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  /// yükleniyor bölümü
                  return buildDefaultTextStyle();
                }
              }
            }
          }),
    );
  }

  Future<void> engelleFonksiyonu(email) async {
    final _firestore = FirebaseFirestore.instance;
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic unic = map['unic'];
    dynamic engelledim = map['engelledim'];
    unicCikar();

    if (unic <= 0) {
    } else {
      if (email != kullanici.email) {
        if (engelledim.contains(email)) {
          await FirebaseFirestore.instance
              .collection("Kullanicilar")
              .doc(kullanici.email)
              .update({
            'engelledim': FieldValue.arrayRemove([email.toString()])
          }).whenComplete(() {
            print('kullanıcı engellendi');
          });
          await FirebaseFirestore.instance
              .collection("Kullanicilar")
              .doc(email.toString())
              .update({
            "engelleyenler":
                FieldValue.arrayRemove([kullanici.email.toString()])
          });
        } else {
          await FirebaseFirestore.instance
              .collection("Kullanicilar")
              .doc(kullanici.email)
              .update({
            'engelledim': FieldValue.arrayUnion([email.toString()])
          }).whenComplete(() {
            print('kullanıcı engellendi');
          });
          await FirebaseFirestore.instance
              .collection("Kullanicilar")
              .doc(email.toString())
              .update({
            "engelleyenler": FieldValue.arrayUnion([kullanici.email.toString()])
          });
        }
      }
    }
  }

  ///

  ///
}
