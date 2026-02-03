import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';
import 'package:unicotantic/profil/BenDrawer.dart';

import '../Unic/fonksiyonlar/akisPostlar.dart';
import '../Unic/fonksiyonlar/postSabitleri.dart';
import 'metin_gir.dart';

class PostuGor extends StatefulWidget {
  final String postAydi;
  const PostuGor({super.key, required this.postAydi});

  @override
  State<PostuGor> createState() => _PostuGorState();
}

class _PostuGorState extends State<PostuGor> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final puanSa = Hive.box('unicotantic');

  @override
  Widget build(BuildContext context) {
    var collection = FirebaseFirestore.instance.collection('postlar');
    // Cevaplar için yorumlar koleksiyonunu kullanmak daha doğru olabilir,
    // ancak mevcut yapıda postlar üzerinden gidiliyorsa rootId kontrolü yapılır.
    var query = FirebaseFirestore.instance
        .collection('yorumlar')
        .where('postAydi', isEqualTo: widget.postAydi)
        .where('parentId', isNull: true)
        .orderBy('zaman', descending: true);

    return Scaffold(
      appBar: akisAppBar(),
      drawer: const BenDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              StreamBuilder<DocumentSnapshot>(
                  stream: collection.doc(widget.postAydi).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.data!.exists) return const Center(child: Text("Post bulunamadı"));
                    var data = snapshot.data!;

                    return Card(
                      child: Column(
                        children: [
                          const Center(
                              child: Text("Üst Post",
                                  style: TextStyle(color: Colors.cyan, fontSize: 11, fontWeight: FontWeight.bold))),
                          ustBolumKullaniciKimligi(
                              data.get('postAydi'), data.get('email'), data.get('tarih'), [data], 0),
                          ikinciBolumText(data.get('baslik')),
                          ucuncuBolumVideoFotograf(data.get('postVideoLinki'), data.get('postFotolinki')),
                          DorduncuBolumAltBar(
                              data.get('email'),
                              [data],
                              0,
                              data.get('begenMe').contains(kullanici.email),
                              data.reference.update,
                              data.get('begenMe'),
                              data.get('begen').contains(kullanici.email),
                              data.get('begen'),
                              data.get('postAydi'),
                              data.get('yorumSayisi')),
                        ],
                      ),
                    );
                  }),
              const Divider(color: Colors.cyan, thickness: 0.5),
              const Center(
                  child: Text("Cevaplar",
                      style: TextStyle(color: Colors.cyan, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(child: akisPostlar(query)),
            ],
          ),
          const MetinGir(),
        ],
      ),
    );
  }
}
