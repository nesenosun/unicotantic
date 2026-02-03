import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/Unic/fonksiyonlar/profilResmiGetir.dart';
import 'package:unicotantic/profil/yeniZiyaretciProfil.dart';

import '../duzenlemeler/postuDuzenle.dart';
import 'altButonlar.dart';
import 'buildDefaultTextStyle.dart';

StreamBuilder<QuerySnapshot<Object?>> akisPostlar(
  Query<Object?> postlarSorgu, {
  List<dynamic>? excludedEmails,
}) {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final puanSa = Hive.box('unicotantic');

  return StreamBuilder<QuerySnapshot>(
    stream: postlarSorgu.snapshots(),
    builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
      if (asyncSnapshot.hasError) {
        return Center(child: Text('Hata: ${asyncSnapshot.error}'));
      }
      if (!asyncSnapshot.hasData) {
        return buildDefaultTextStyle();
      }

      List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;

      if (excludedEmails != null && excludedEmails.isNotEmpty) {
        listOfDocumentSnap = listOfDocumentSnap.where((doc) {
          try {
            return !excludedEmails.contains(doc.get('email'));
          } catch (e) {
            return true;
          }
        }).toList();
      }

      if (listOfDocumentSnap.isEmpty) {
        return const Center(child: Text('Henüz bir veri yok.'));
      }

      return ListView.builder(
        itemCount: listOfDocumentSnap.length,
        itemBuilder: (context, index) {
          var doc = listOfDocumentSnap[index];
          var data = doc.data() as Map<String, dynamic>;
          
          var begenKontrol = data['begen'] ?? [];
          var email = data['email'] ?? '';
          var id = data['id'] ?? '';
          var tarih = data['tarih'] ?? '';
          var baslik = data['baslik'] ?? '';
          var begenMeKontrol = data['begenMe'] ?? [];
          var mapYorum = data['mapYorum'] ?? [];
          var yorumSayisi = data['yorumSayisi'] ?? 0;
          var postFotolinki = data['postFotolinki'] ?? 'bos';
          var postVideoLinki = data['postVideoLinki'] ?? '';
          var postAydi = data['postAydi'] ?? '';
          var update = doc.reference.update;
          var bakBegenKontrol = begenKontrol.contains(kullanici.email);
          var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);

          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: GestureDetector(
                            onTap: () => Get.to(YeniZiyaretciProfil(gelenKullaniciEmail: email)),
                            child: profilResmiGetir(email.toString()),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            profilIsmiGetir(email),
                            const SizedBox(width: 3),
                            profilSoyisimGetir(email),
                          ],
                        ),
                        Row(
                          children: [
                            Text('@${id.toString().length > 10 ? id.toString().substring(0, 10) : id} ', 
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                            profilUnicGetir(email),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (kullanici.email == email.toString())
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              puanSa.put('postAydi', postAydi.toString());
                              Get.to(PostuDuzenle());
                            },
                            icon: const Icon(Icons.edit, size: 15, color: Colors.greenAccent),
                          ),
                          IconButton(
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Gönderiyi Sil",
                                middleText: "Bu gönderiyi silmek istediğinizden emin misiniz?",
                                backgroundColor: Colors.grey[900],
                                titleStyle: const TextStyle(color: Colors.white),
                                middleTextStyle: const TextStyle(color: Colors.white70),
                                textConfirm: "Sil",
                                textCancel: "Vazgeç",
                                confirmTextColor: Colors.white,
                                onConfirm: () async {
                                  try {
                                    await listOfDocumentSnap[index].reference.delete();
                                    Get.back();
                                    Get.snackbar("Başarılı", "Gönderi silindi",
                                        colorText: Colors.white,
                                        backgroundColor: Colors.green);
                                  } catch (e) {
                                    Get.snackbar("Hata", "Silme işlemi başarısız: $e",
                                        colorText: Colors.white,
                                        backgroundColor: Colors.red);
                                  }
                                },
                              );
                            },
                            icon: const Icon(Icons.delete, size: 15, color: Colors.redAccent),
                          ),
                        ],
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(baslik, style: const TextStyle(fontSize: 14, color: Colors.green)),
                ),
                if (postFotolinki != 'bos') Image.network(postFotolinki, fit: BoxFit.fill),
                altButonlar(
                  bakBegenKontrol,
                  listOfDocumentSnap,
                  index,
                  email,
                  postAydi,
                  begenMeKontrol,
                  mapYorum,
                  yorumSayisi,
                  bakBegenMeKontrol,
                  update,
                  begenKontrol,
                ),
              ],
            ),
          );
        },
      );
    }
  );
}
