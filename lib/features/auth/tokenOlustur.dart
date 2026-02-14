import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/features/feed/anasayfa.dart';

class TokenOlustur extends StatefulWidget {
  const TokenOlustur({super.key});

  @override
  State<TokenOlustur> createState() => _TokenOlusturState();
}

class _TokenOlusturState extends State<TokenOlustur> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  final puanSa = Hive.box('unicotantic');

  Future<void> saveTokenToFirestore() async {
    //uidEkle();
    final String? token =
        await getTokenFromSomewhere(); // Burada cihazdan tokenı alma kodunu çağırman gerekiyor
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(kullanici.email)
          .set({'token': token.toString(), 'uid': kullanici.uid.toString()},
              SetOptions(merge: true));
    }

    CollectionReference kullanicilar =
        _firestore.collection('uygulamaAyarları');
    var icerik = kullanicilar.doc('guncellemeler');
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic ayar = map['ayar'];
    dynamic guncellemeYayinlandi = map['guncellemeYayinlandi'];
    dynamic yeniAyarlar = map['yeniAyarlar'];

    debugPrint(ayar.toString());

    puanSa.put('ayar', ayar);
    puanSa.put('guncellemeYayinlandi', guncellemeYayinlandi);
    puanSa.put('yeniAyarlar', yeniAyarlar.toString());
  }

  Future<String?> getTokenFromSomewhere() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Firebase Messaging token'ı al
    String? token = await messaging.getToken();

    // Firebase Messaging token'ı varsa, geri dön
    if (token != null) {
      return token;
    }
    debugPrint('Token alındı');

    // Firebase Messaging token'ı yoksa, hata mesajı göster ve null geri dön
    debugPrint('Firebase Messaging tokenı alınamadı');
    return null;
  }

  @override
  void initState() {
    super.initState();
    saveTokenToFirestore();
    Future.delayed(const Duration(seconds: 2), () {
      Get.to(Anasayfa());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/gif/lemat.gif"),
              fit: BoxFit.cover),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 200,
              ),
              SizedBox(
                height: 150,
                width: 150,
                child: Image.asset(
                  "assets/images/icon/icon256.png",
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///
}
