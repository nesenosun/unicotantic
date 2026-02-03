// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:hive_flutter/hive_flutter.dart';
//
// class UygulamaAyarlari extends GetxController {
//   final kullanici = FirebaseAuth.instance.currentUser!;
//   final _firestore = FirebaseFirestore.instance;
//   final puanSa = Hive.box('unicotantic');
//
//   uygulamaAyarlari() async {
//     CollectionReference kullanicilar = _firestore.collection('uygulamaAyarları');
//     var icerik = kullanicilar.doc('guncellemeler');
//     var secim = await icerik.get();
//     dynamic map = secim.data();
//
//     dynamic ayar = map['ayar'];
//     print(ayar);
//     await puanSa.put('ayar', ayar);
//   }
// }
