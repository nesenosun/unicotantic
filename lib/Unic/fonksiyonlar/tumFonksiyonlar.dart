import 'package:cloud_firestore/cloud_firestore.dart';

import 'altButonlar.dart';
import 'negatifOyVer_pozitifOyVer.dart';

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
        await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
          'engelledim': FieldValue.arrayRemove([email.toString()])
        }).whenComplete(() {});
        await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
          "engelleyenler": FieldValue.arrayRemove([kullanici.email.toString()])
        });
      } else {
        await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
          'engelledim': FieldValue.arrayUnion([email.toString()])
        }).whenComplete(() {});
        await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
          "engelleyenler": FieldValue.arrayUnion([kullanici.email.toString()])
        });
      }
    }
  }
}
