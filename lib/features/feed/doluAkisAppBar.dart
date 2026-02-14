import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/core/utils/buildDefaultTextStyle.dart';
import 'package:unicotantic/core/utils/reklamAnasayfa.dart';
import 'package:unicotantic/core/utils/reklamGoster.dart';
import 'package:unicotantic/features/ai/unica_chat_page.dart';
import 'package:unicotantic/features/auth/auth_kontrol.dart';
import 'package:unicotantic/features/profile/kullanici_profili.dart';

AppBar akisAppBar({PreferredSizeWidget? bottom}) {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference kullanicilar = firestore.collection('users');

  var icerik = kullanicilar.doc(kullanici.uid);
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
      ikinciBolumUnicYazisi(),
      unicaAIGit(),
    ],
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    bottom: bottom,
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
            ),
          ),
        ),
      ),
    ),
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

Expanded unicSayisalGosterim(DocumentReference<Object?> icerik) {
  return Expanded(
    flex: 2,
    child: GestureDetector(
      onTap: () async {
        final kullanici = FirebaseAuth.instance.currentUser!;
        final _firestore = FirebaseFirestore.instance;

        CollectionReference kullanicilar = _firestore.collection('users');
        var icerik = kullanicilar.doc(kullanici.email);
        var secim = await icerik.get();
        dynamic map = secim.data();

        dynamic unic = map['unicBalance'] ?? 0;
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
                  return Text(
                    "77",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  );
                } else if (asyncSnapshot.hasData) {
                  dynamic unicSayisi = asyncSnapshot.data.data()['unicBalance'] ?? "0";
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

        CollectionReference kullanicilar = _firestore.collection('users');
        var icerik = kullanicilar.doc(kullanici.email);
        var secim = await icerik.get();
        dynamic map = secim.data();

        dynamic bildirim = map['bildirim'];

        //Get.to(Bildirim());
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
          onTap: () => Get.to(KullaniciProfili()),
        ),
      ),
    ),
  );
}
