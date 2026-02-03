import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'controllerNet.dart';

final controllerNet = Get.put(ControllerNet());

Future<void> poostSahibineUnicEkle(postuAtanEmail) async {
  await FirebaseFirestore.instance
      .collection("Kullanicilar")
      .doc(postuAtanEmail.toString())
      .update({'unic': FieldValue.increment(1)});
}

Future<void> kullanicidanUnicCikar(KullaniciUnicSayisi) async {
  await FirebaseFirestore.instance
      .collection("Kullanicilar")
      .doc(controllerNet.kullanici.email)
      .update(KullaniciUnicSayisi >= 1 ? {"unic": FieldValue.increment(-1)} : {"unic": 0});
}

Future<void> postBegeneEmailEkleFonksiyonu(postAydi) async {
  await FirebaseFirestore.instance.collection("postlar").doc(postAydi.toString()).update({
    'begen': FieldValue.arrayUnion([controllerNet.kullanici.email])
  });
}

Future<void> postBegeneMEyeEmailEkleFonksiyonu(postAydi) async {
  await FirebaseFirestore.instance.collection("postlar").doc(postAydi.toString()).update({
    'begenMe': FieldValue.arrayUnion([controllerNet.kullanici.email])
  });
}

Future<void> postSahibinidenUnicCikar(email) async {
  await FirebaseFirestore.instance
      .collection("Kullanicilar")
      .doc(email.toString())
      .update({'unic': FieldValue.increment(-1)});
}

Future<void> postBegendenEmailCikarFonksiyonu(postAydi) async {
  await FirebaseFirestore.instance.collection("postlar").doc(postAydi.toString()).update({
    'begen': FieldValue.arrayRemove([controllerNet.kullanici.email])
  });
}

Future<void> postBegenMedenEmailCikarFonksiyonu(postAydi) async {
  await FirebaseFirestore.instance.collection("postlar").doc(postAydi.toString()).update({
    'begenMe': FieldValue.arrayRemove([controllerNet.kullanici.email])
  });
}

Future<dynamic> postuKimlerBegenmisFonksiyonu(postAydi) async {
  CollectionReference kullanicilar = controllerNet.firestore.collection('postlar');
  var icerik = kullanicilar.doc(postAydi.toString());
  var secim = await icerik.get();
  dynamic map = secim.data();

  dynamic postuKimlerBegenmis = map['begen'];
  print(postuKimlerBegenmis.toString());
  return postuKimlerBegenmis;
}

Future<dynamic> KullaniciUnicSayisiGetirFonksiyonu() async {
  CollectionReference kullanicilar = controllerNet.firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(controllerNet.kullanici.email);
  var secim = await icerik.get();
  dynamic map = secim.data();

  dynamic unic = map['unic'];
  return unic;
}
