import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class InternetController extends GetxController {
  User? get kullanici => FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;
  
  late final postlar = _firestore.collection('postlar');
  late final kullanicilar = _firestore.collection('users');

  Future<void> uygulamaAyarlari() async {
    if (kullanici == null) return;
    
    CollectionReference ayarRef = _firestore.collection('uygulamaAyarları');
    var icerik = ayarRef.doc('guncellemeler');
    var secim = await icerik.get();
    dynamic map = secim.data();

    if (map != null && map['ayar'] != null) {
      dynamic ayar = map['ayar'];
      if (kDebugMode) {
        print(ayar);
      }
    }
  }
}
