import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'altButonlar.dart';

///
Future<void> pozitifOyVer(List<DocumentSnapshot<Object?>> listOfDocumentSnap, int index, bakBegenKontrol,
    Future<void> update(Map<Object, Object?> data), email) async {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(kullanici.email);
  var secim = await icerik.get();
  dynamic map = secim.data();

  dynamic unic = map['unic'];

  if (unic <= 0) {
  } else {
    if (email.toString() != kullanici.email) {
      if (bakBegenKontrol) {
        update({
          'begen': FieldValue.arrayRemove([kullanici.email])
        });
        update({'unic': FieldValue.increment(-1)});

        await FirebaseFirestore.instance
            .collection("Kullanicilar")
            .doc(email.toString())
            .update({"unic": FieldValue.increment(-1)});
      } else {
        unicCikar();

        update({
          'begen': FieldValue.arrayUnion([kullanici.email]),
        });
        update({'unic': FieldValue.increment(1)});

        await FirebaseFirestore.instance
            .collection("Kullanicilar")
            .doc(email.toString())
            .update({"unic": FieldValue.increment(1)});
      }
    }
  }
}

///

///

Future<void> negatifOyVer(email, bakBegenMeKontrol, Future<void> update(Map<Object, Object?> data)) async {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(kullanici.email);
  var secim = await icerik.get();
  dynamic map = secim.data();

  dynamic unic = map['unic'];

  if (unic <= 0) {
  } else {
    if (email != kullanici.email) {
      if (bakBegenMeKontrol) {
        update({
          'begenMe': FieldValue.arrayRemove([kullanici.email])
        });
        update({'unic': FieldValue.increment(1)});

        await FirebaseFirestore.instance
            .collection("Kullanicilar")
            .doc(email.toString())
            .update({"unic": FieldValue.increment(1)});
      } else {
        unicCikar();
        update({
          'begenMe': FieldValue.arrayUnion([kullanici.email])
        });
        update({'unic': FieldValue.increment(-1)});

        await FirebaseFirestore.instance
            .collection("Kullanicilar")
            .doc(email.toString())
            .update({"unic": FieldValue.increment(-1)});
      }
    }
  }
}

Future<dynamic> unicCikar() async {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
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

fieldIcerikEkleSil() async {
  await FirebaseFirestore.instance.collection("postaYorum").doc(puanSa.get('postAydi')).update({
    'mapYorum': '',
    'isim': '',
    'dogum tarihi': '',
    'hakkinda': '',
    'iletisim': '',
    'soyisim': '',
    'sehir': '',
  });
  await FirebaseFirestore.instance
      .collection("postlar")
      .doc(puanSa.get('postAydi'))
      .update({'postVideoLinki': FieldValue.delete()}).whenComplete(() {
    print('Field Deleted');
  });
}
