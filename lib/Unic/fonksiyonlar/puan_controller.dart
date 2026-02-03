import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PuanC extends GetxController {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  final puanSa = Hive.box('unicotantic');

  Future<int> unicSayisi() async {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic unic = map['unic'];

    return unic;
  }

  Future<int> yorumSayisi() async {
    final ytr = FirebaseFirestore.instance
        .collection("postlar")
        .doc(puanSa.get('postAydi'))
        .collection("yorumlar")
        .get()
        .then((querySnapshot) {
      int dokumenSayisi = querySnapshot.size;
      puanSa.put('dokumenSayisi', dokumenSayisi.toString());
      print("Alt koleksiyondaki döküman sayısı: $dokumenSayisi");
      return dokumenSayisi;
    });
    return ytr;
  }

  Future<dynamic> unicEkle() async {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic unic = map['unic'];

    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update({'unic': FieldValue.increment(10)});
    return unic;
  }

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

  RxInt gizle = 0.obs;
  increment() => gizle++;

  int gPuan = 0;
  var galeri = '.....'.obs;

  var acilGoze = false.obs;
  RxBool gonderiKapat = true.obs;
  void ac() {
    acilGoze = true.obs;
  }

  var top = 150.obs;
  var left = 80.obs;

  rutbeD() {
    if (gPuan <= 50) {
      puanSa.put('durum', 'Acemi');
    } else if (gPuan <= 100) {
      puanSa.put('durum', 'Çırak');
    } else if (gPuan <= 200) {
      puanSa.put('durum', 'Kalfa');
    } else if (gPuan <= 300) {
      puanSa.put('durum', 'Usta');
    } else if (gPuan <= 400) {
      puanSa.put('durum', 'Doctor');
    } else if (gPuan <= 500) {
      puanSa.put('durum', 'Prof');
    } else if (gPuan <= 600) {
      puanSa.put('durum', 'Master');
    }
  }

  void hiveOlustur() {
    puanSa.put('gpuan', 0);
    puanSa.put('durum', 'Acem');
  }

  Future<void> kullaniciOlustur() async {
    puanSa.put('kullanici', kullanici.email.toString());
    puanSa.put('olumsaati', 72);

    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("Kullanicilar").doc(FirebaseAuth.instance.currentUser!.email).get();
    if (snapshot.exists) {
      //documentId already exists
    } else {
      FirebaseFirestore.instance
          .collection("Kullanicilar")
          .doc(FirebaseAuth.instance.currentUser!.email.toString())
          .set({
        "email": FirebaseAuth.instance.currentUser!.email.toString(),
        "sifre": '',
        'isim': FirebaseAuth.instance.currentUser!.displayName.toString(),
        'kayit tarihi': DateTime.now(),
        "start_date": DateTime.now(),
        "end_date": DateTime.now().add(const Duration(hours: 72)).toString(),
        "olumsaati": 72,
        'sehir': '',
        'puan': '',
        'dogum tarihi': '',
        'hakkinda': '',
        'iletisim': '',
        'unic': '',
        'metin': '',
        'profilresmilinki': FirebaseAuth.instance.currentUser!.photoURL.toString(),
      });
    }
  }

  void hiveYukle() {
    gPuan = puanSa.get('gpuan', defaultValue: 0);
    puanSa.get('durum', defaultValue: 'Acemi'.tr);
  }

  void hiveUpdate() {
    puanSa.put('gpuan', gPuan++);
  }

  void dogruCevap() {
    puanSa.put('gpuan', gPuan++);
    rutbeD();
    //Get.off(Menu());
  }
}
