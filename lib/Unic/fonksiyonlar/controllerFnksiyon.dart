import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'controllerNet.dart';

class ControllerFonksiyon extends GetxController {
  final controllerNet = Get.put(ControllerNet());
  RxInt postlar = 0.obs;

  Future<dynamic> unicCikart() async {
    CollectionReference kullanicilar = controllerNet.firestore.collection('Kullanicilar');
    var kullanicilarIcerik = kullanicilar.doc(controllerNet.kullanici.email);
    var kullanicilarIcerikSorgu = await kullanicilarIcerik.get();
    dynamic kullanicilarIcerikSorguMap = kullanicilarIcerikSorgu.data();

    dynamic unic = kullanicilarIcerikSorguMap['unic'];

    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(controllerNet.kullanici.email)
        .update(unic >= 1 ? {"unic": FieldValue.increment(-1)} : {"unic": 0});
    return unic;
  }
}
