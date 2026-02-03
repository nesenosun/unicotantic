import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:unicotantic/profil/BenDrawer.dart';
import 'package:unicotantic/profil/arkadaslarProfil.dart';

class DavetEdilenler extends StatefulWidget {
  String gelenKullaniciEmail;

  DavetEdilenler({required this.gelenKullaniciEmail});

  @override
  State<DavetEdilenler> createState() => _DavetEdilenlerState();
}

class _DavetEdilenlerState extends State<DavetEdilenler> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference kullanicilar = _firestore.collection('uyeler');
    var kullaniciBilgileriSorgu = kullanicilar.doc(widget.gelenKullaniciEmail.toString());

    return SafeArea(
      child: Scaffold(
        appBar: akisAppBar(),
        drawer: const BenDrawer(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.indigoAccent,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        BoxShadow(color: Colors.red.withOpacity(.15), offset: Offset(2.0, 2.0), blurRadius: 10),
                      ]),
                  'Davet Edilenler',
                  textAlign: TextAlign.center),
            ),
            Container(
              child: Flexible(
                child: StreamBuilder<DocumentSnapshot>(
                    stream: kullaniciBilgileriSorgu.snapshots(),
                    builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      if (asyncSnapshot.hasError) {
                        return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                      } else {
                        if (asyncSnapshot.hasData) {
                          dynamic ekledigiUyeler = asyncSnapshot.data.data()['ekledigiUyeler'];
                          // dynamic ekledigiUyelerUzunluk = asyncSnapshot.data.data()['ekledigiUyeler'].length;

                          // for (dynamic key in ekledigiUyeler) {
                          //   print('key değeri : ' + key.toString());

                          // }

                          return Container(
                            child: ListView.builder(
                                itemCount: ekledigiUyeler.length,
                                itemBuilder: (context, index) {
                                  dynamic arkadaslarEmail = ekledigiUyeler[index];

                                  return Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        child: ArkadaslarProfil(
                                          gelenKullaniciEmail: arkadaslarEmail.toString(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
