import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/Unic/bildirimler/bildirim.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:unicotantic/Unic/fonksiyonlar/reklamAnasayfa.dart';
import 'package:unicotantic/Unic/fonksiyonlar/reklamGoster.dart';
import 'package:unicotantic/login/auth_kontrol.dart';
import 'package:unicotantic/profil/profilBilgilerim.dart';
import 'package:unicotantic/Unic/yapayZeka/unica_chat_page.dart';

AppBar akisAppBar() {
  final kullanici = FirebaseAuth.instance.currentUser!;
  late final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference kullanicilar = firestore.collection('Kullanicilar');

  var icerik = kullanicilar.doc(kullanici.email);
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 60,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
        bottom: Radius.circular(20),
      ),
    ),
    actions: <Widget>[
      doluBenDrawerAcilir(),
      unicaAIGit(),
      unicSayisalGosterim(icerik),
      ikinciBolumUnicYazisi(),
      bildirimGosterim(icerik),
      profileGit(icerik),
    ],
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  );
}

Expanded unicaAIGit() {
  return Expanded(
    flex: 1,
    child: Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        color: Colors.black26,
        child: GestureDetector(
          onTap: () => Get.to(const UnicaChatPage()),
          child: const Center(
            child: Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 20),
          ),
        ),
      ),
    ),
  );
}

Expanded doluBenDrawerAcilir() {
  return Expanded(
    flex: 2,
    child: Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        color: Colors.black26,
        child: Center(
          child: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Image.asset('assets/images/icon/icon256.png'),
              //onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ),
    ),
  );
}

Expanded unicSayisalGosterim(DocumentReference<Object?> icerik) {
  return Expanded(
    flex: 2,
    child: GestureDetector(
      onTap: () async {
        final kullanici = FirebaseAuth.instance.currentUser!;
        final _firestore = FirebaseFirestore.instance;

        CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
        var icerik = kullanicilar.doc(kullanici.email);
        var secim = await icerik.get();
        dynamic map = secim.data();

        dynamic unic = map['unic'];
        if (unic <= 20) {
          Get.off(ReklamGoster());
        }
      },
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
                    dynamic unicSayisi = asyncSnapshot.data.data()['unic'];
                    return unicSayisi >= 21
                        ? Text(
                            unicSayisi.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'R',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                unicSayisi.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          );
                  } else {
                    /// yükleniyor bölümü
                    return buildDefaultTextStyle();
                  }
                }
              }),
        ),
      ),
    ),
  );
}

Expanded ikinciBolumUnicYazisi() {
  return Expanded(
      flex: 3,
      child: Card(
        color: Colors.black26,
        child: GestureDetector(
          onTap: () => Get.to(const AuthKontrol()),
          onLongPress: () {
            Get.to(const AuthKontrol());
          },
          child: Center(child: Image.asset('assets/images/png/akis.png')),
        ),
      ));
}

Expanded bildirimGosterim(DocumentReference<Object?> icerik) {
  return Expanded(
    flex: 1,
    child: GestureDetector(
      onTap: () async {
        final kullanici = FirebaseAuth.instance.currentUser!;
        final _firestore = FirebaseFirestore.instance;

        CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
        var icerik = kullanicilar.doc(kullanici.email);
        var secim = await icerik.get();
        dynamic map = secim.data();

        dynamic bildirim = map['bildirim'];

        Get.to(Bildirim());
        icerik.update({'bildirim': 0});
      },
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
                    dynamic bildirim = asyncSnapshot.data.data()['bildirim'];
                    return bildirim <= 0
                        ? Text(
                            bildirim.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        : Text(
                            bildirim.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 18),
                          );
                  } else {
                    /// yükleniyor bölümü
                    return buildDefaultTextStyle();
                  }
                }
              }),
        ),
      ),
    ),
  );
}

Expanded anasayfaMenuButonu() {
  return Expanded(
    flex: 2,
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
  );
}

Expanded profileGit(DocumentReference<Object?> icerik) {
  return Expanded(
    flex: 2,
    child: Center(
      child: Builder(
        builder: (context) => GestureDetector(
          child: SizedBox(
            child: StreamBuilder<DocumentSnapshot>(
                stream: icerik.snapshots(),
                builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                  if (asyncSnapshot.hasError) {
                    return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                  } else {
                    if (asyncSnapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50.0),
                            bottomRight: Radius.circular(10.0),
                            topRight: Radius.circular(50.0),
                            bottomLeft: Radius.circular(10.0),
                          ),
                          child: Image.network(
                            '${asyncSnapshot.data.data()['profilresmilinki']}',
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    } else {
                      /// yükleniyor bölümü
                      return buildDefaultTextStyle();
                    }
                  }
                }),
          ),
          onTap: () => Get.to(ProfilBilgilerim()),
        ),
      ),
    ),
  );
}
