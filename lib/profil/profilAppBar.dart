import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/Unic/fonksiyonlar/reklamAnasayfa.dart';
import 'package:unicotantic/profil/kullanici_profil_sayfasi.dart';
import 'package:unicotantic/profil/profil_fotograf_degistir.dart';

import '../Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import '../login/auth_kontrol.dart';

AppBar ProilAppBar() {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');

  var icerik = kullanicilar.doc(kullanici.email);
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 150,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
        bottom: Radius.circular(20),
      ),
    ),
    actions: <Widget>[
      Flexible(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(flex: 1, child: ProfilFotografiDegistir()),
                  Expanded(
                    flex: 2,
                    child: StreamBuilder<DocumentSnapshot>(
                        stream: icerik.snapshots(),
                        builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                          if (asyncSnapshot.hasError) {
                            return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                          } else {
                            if (asyncSnapshot.hasData) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: buildCard2(
                                              context,
                                              '${asyncSnapshot.data.data()['isim']}' +
                                                  ' ' +
                                                  '${asyncSnapshot.data.data()['soyisim']}')),
                                      Expanded(child: buildCard2(context, '${asyncSnapshot.data.data()['sehir']}')),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  buildCard2(context, '${asyncSnapshot.data.data()['email']}'),
                                  const SizedBox(height: 2),
                                  buildCard2(context, '${asyncSnapshot.data.data()['iletisim']}'),
                                ],
                              );
                            } else {
                              /// yükleniyor bölümü
                              return buildDefaultTextStyle();
                            }
                          }
                        }),
                  ),
                ],
              ),
              SizedBox(height: 5),
              StreamBuilder<DocumentSnapshot>(
                  stream: icerik.snapshots(),
                  builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                    if (asyncSnapshot.hasError) {
                      return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                    } else {
                      if (asyncSnapshot.hasData) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildCard(context, '${asyncSnapshot.data.data()['hakkinda']}'),
                              const SizedBox(height: 5),
                            ],
                          ),
                        );
                      } else {
                        /// yükleniyor bölümü
                        return buildDefaultTextStyle();
                      }
                    }
                  }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.off(KullaniciProfilSayfasi()),
                      child: Card(
                        color: Colors.deepPurpleAccent,
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
                        //Get.to(ProfilYorumBolumu());
                      },
                      child: Card(
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
                ],
              ),
            ],
          ),
        ),
      ),
    ],
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  );
}

Card buildCard(BuildContext context, yazi) {
  return Card(
    elevation: 5,
    margin: const EdgeInsets.symmetric(horizontal: 5),
    color: Colors.black54,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            yazi,
            style: const TextStyle(
                fontFamily: 'Montserrat', fontSize: 15, color: Colors.greenAccent, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Card buildCard2(BuildContext context, yazi) {
  return Card(
    elevation: 5,
    margin: const EdgeInsets.symmetric(horizontal: 5),
    color: Colors.black26,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            yazi,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                shadows: [
                  BoxShadow(color: Colors.red.withOpacity(.15), offset: Offset(2.0, 2.0), blurRadius: 10),
                ]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Expanded kucukMenuBolumu(DocumentReference<Object?> icerik) {
  return Expanded(
    flex: 1,
    child: Card(
      color: Colors.black26,
      child: Center(
        child: Builder(
          builder: (context) => GestureDetector(
            child: SizedBox(
              height: 120,
              width: 120,
              child: StreamBuilder<DocumentSnapshot>(
                  stream: icerik.snapshots(),
                  builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                    if (asyncSnapshot.hasError) {
                      return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                    } else {
                      if (asyncSnapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.network(
                            '${asyncSnapshot.data.data()['profilresmilinki']}',
                            fit: BoxFit.contain,
                          ),
                        );
                      } else {
                        /// yükleniyor bölümü
                        return yuklemeDefaultAnimation();
                      }
                    }
                  }),
            ),
            onTap: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
    ),
  );
}

Expanded ikinciBolumUnicYazisi() {
  return Expanded(
      flex: 2,
      child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Card(
            color: Colors.black26,
            child: GestureDetector(
              onTap: () => Get.to(const AuthKontrol()),
              onLongPress: () {
                Get.to(const AuthKontrol());
              },
              child: Image.asset('assets/images/png/akis.png'),
            ),
          )));
}

Expanded unicSayisalGosterim(DocumentReference<Object?> icerik) {
  return Expanded(
    flex: 1,
    child: Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        color: Colors.black26,
        child: Center(
          child: StreamBuilder<DocumentSnapshot>(
              stream: icerik.snapshots(),
              builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                if (asyncSnapshot.hasError) {
                  return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                } else {
                  if (asyncSnapshot.hasData) {
                    return Text('${asyncSnapshot.data.data()['unic']}');
                  } else {
                    /// yükleniyor bölümü
                    return yuklemeDefaultAnimation();
                  }
                }
              }),
        ),
      ),
    ),
  );
}

DefaultTextStyle yuklemeDefaultAnimation() {
  return DefaultTextStyle(
    textAlign: TextAlign.center,
    style: const TextStyle(
        backgroundColor: Colors.black54,
        color: Colors.greenAccent,
        fontSize: 12.0,
        fontFamily: 'Chivo',
        fontWeight: FontWeight.bold),
    child: AnimatedTextKit(
      pause: const Duration(seconds: 3),
      stopPauseOnTap: true,
      isRepeatingAnimation: false,
      animatedTexts: [
        TypewriterAnimatedText(
          curve: Curves.decelerate,
          "..........",
          textAlign: TextAlign.center,
          speed: const Duration(milliseconds: 200),
        ),
      ],
    ),
  );
}

Expanded anasayfaMenuButonu() {
  return Expanded(
    flex: 1,
    child: Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        color: Colors.black26,
        child: GestureDetector(
          onTap: () {
            Get.to(const ReklamAnaSayfa());
          },
          child: Center(
            child: Image.asset('assets/images/png/anasayfa.png'),
          ),
        ),
      ),
    ),
  );
}
