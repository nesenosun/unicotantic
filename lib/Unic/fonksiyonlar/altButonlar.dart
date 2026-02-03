import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../doluAkis/doluYorumOku.dart';
import 'negatifOyVer_pozitifOyVer.dart';

final kullanici = FirebaseAuth.instance.currentUser!;
final _firestore = FirebaseFirestore.instance;

final puanSa = Hive.box('unicotantic');

SizedBox altButonlar(
    bakBegenKontrol,
    List<DocumentSnapshot<Object?>> listOfDocumentSnap,
    int index,
    email,
    postAydi,
    begenMeKontrol,
    yorumMeKontrol,
    yorumSayisi,
    containsBegenme,
    Future<void> update(Map<Object, Object?> data),
    begenKontrol) {
  return SizedBox(
    child: Card(
      shape: bakBegenKontrol
          ? Border(bottom: BorderSide(color: Colors.cyan, width: 5))
          : Border(bottom: BorderSide(color: Colors.white, width: 5)),
      elevation: 0,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                  child: kullanici.email == email.toString()
                      ? IconButton(
                          onPressed: () async {
                            puanSa.put('postAydi', postAydi.toString());
                            puanSa.put('email', email.toString());
                            // await FirebaseFirestore.instance.collection("postlar").doc(puanSa.get('postAydi')).update({
                            //   'mapYorum': '',
                            //   'isim': '',
                            //   'dogum tarihi': '',
                            //   'hakkinda': '',
                            //   'iletisim': '',
                            //   'soyisim': '',
                            //   'sehir': '',
                            // });
                            // await FirebaseFirestore.instance
                            //     .collection("postlar")
                            //     .doc(puanSa.get('postAydi'))
                            //     .update({'postVideoLinki': FieldValue.delete()}).whenComplete(() {
                            //   print('Field Deleted');
                            // });

                            await listOfDocumentSnap[index].reference.delete();
                          },
                          icon: const Icon(
                            Icons.delete,
                            size: 23,
                            color: Colors.red,
                          ))
                      : Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2))),
              Text(' ${begenMeKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
              IconButton(
                  onPressed: () async {
                    await negatifOyVer(email, containsBegenme, update);
                    print(listOfDocumentSnap[index].reference.toString());
                  },
                  icon: Icon(
                    Icons.heart_broken,
                    size: 25,
                    color: containsBegenme ? Colors.red : Colors.white70,
                  )),
              Text('${begenKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
              IconButton(
                  onPressed: () async {
                    await pozitifOyVer(listOfDocumentSnap, index, bakBegenKontrol, update, email);
                  },
                  icon: Icon(
                    Icons.thumb_up_alt_rounded,
                    size: 25,
                    color: bakBegenKontrol ? Colors.cyan : Colors.white70,
                  )),
              Text('${yorumSayisi}',
                  style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold)),
              IconButton(
                  onPressed: () async {
                    puanSa.put('postAydi', postAydi.toString());
                    puanSa.put('email', email.toString());
                    print(postAydi.toString());
                    Get.to(DoluYorumOku(
                      gelenKullaniciEmail: email.toString(),
                      postAydi: postAydi.toString(),
                    ));
                  },
                  icon: Icon(
                    Icons.mode_comment_sharp,
                    size: 25,
                    color: yorumSayisi <= 0 ? Colors.white70 : Colors.cyanAccent,
                  )),
            ],
          ),
        ],
      ),
    ),
  );
}
