import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:unicotantic/profil/BenDrawer.dart';
import 'package:unicotantic/profil/arkadaslarProfil.dart';

class Arkadaslar extends StatefulWidget {
  String gelenKullaniciEmail;

  Arkadaslar({required this.gelenKullaniciEmail});

  @override
  State<Arkadaslar> createState() => _ArkadaslarState();
}

class _ArkadaslarState extends State<Arkadaslar> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var kullaniciBilgileriSorgu = kullanicilar.doc(kullanici.email);

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
                  'Arkadaşlar',
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
                          dynamic arkadaslar = asyncSnapshot.data.data()['arkadaslar'];

                          for (dynamic key in arkadaslar) {
                            print('key değeri : ' + key.toString());
                          }

                          return Container(
                            child: ListView.builder(
                                itemCount: arkadaslar.length,
                                itemBuilder: (context, index) {
                                  dynamic arkadaslarEmail = arkadaslar[index];

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
