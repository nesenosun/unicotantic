import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:unicotantic/akis/feed_video_player.dart';
import 'package:unicotantic/akis/post_olustur_panel.dart';
import 'package:unicotantic/models/post_model.dart';

import '../Unic/doluAkis/doluAkisAppBar.dart';
import '../Unic/fonksiyonlar/postSabitleri.dart';

class FeedSayfasi extends StatefulWidget {
  const FeedSayfasi({super.key});

  @override
  State<FeedSayfasi> createState() => _FeedSayfasiState();
}

class _FeedSayfasiState extends State<FeedSayfasi> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  void _showPostPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PostOlusturPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Query postlarSorgu = _firestore
        .collection('postlar')
        .where('parentID', isNull: true)
        .orderBy("createdAt", descending: true)
        .limit(20);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: akisAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPostPanel,
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('Kullanicilar').doc(kullanici.email).snapshots(),
        builder: (context, userSnap) {
          if (!userSnap.hasData) return buildDefaultTextStyle();

          final userData = userSnap.data!.data() as Map<String, dynamic>?;
          final List engelleyenler = userData?['engelleyenler'] ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: postlarSorgu.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              if (!snapshot.hasData) return buildDefaultTextStyle();

              List<DocumentSnapshot> docs = snapshot.data!.docs;
              if (docs.isEmpty)
                return const Center(child: Text('Henüz post yok.', style: TextStyle(color: Colors.white)));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var docData = docs[index].data() as Map<String, dynamic>;
                  var post = PostModel.fromMap(docData);

                  if (engelleyenler.contains(post.authorID)) return const SizedBox.shrink();

                  // Firestore'daki gerçek begen ve begenMe listelerini alıyoruz
                  List begenList = docData['begen'] ?? [];
                  List begenMeList = docData['begenMe'] ?? [];

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst Bölüm: Kullanıcı Bilgileri ve Silme Menüsü
                        ustBolumKullaniciKimligi(
                            post.postID,
                            docData['email'] ?? post.email,
                            docData['tarih'] ?? "${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}",
                            docs,
                            index),

                        // Orta Bölüm: Metin İçeriği
                        ikinciBolumText(post.text),

                        // Medya Bölümü
                        if (post.mediaUrl != null && post.mediaUrl != 'bos' && post.mediaUrl != '')
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: post.mediaType == 'video'
                                  ? FeedVideoPlayer(videoUrl: post.mediaUrl!)
                                  : Image.network(post.mediaUrl!, fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),

                        // Alt Bölüm: Firestore alan isimlerine (begen, begenMe) göre eşleşme
                        DorduncuBolumAltBar(
                            docData['email'] ?? post.email,
                            docs,
                            index,
                            begenMeList.contains(kullanici.email),
                            docs[index].reference.update,
                            begenMeList,
                            begenList.contains(kullanici.email),
                            begenList,
                            post.postID,
                            docData['yorumSayisi'] ?? post.commentCount),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
