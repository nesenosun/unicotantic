import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/akis/post_ayrintilari.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Unic/doluAkis/doluAkisAppBar.dart';
import '../Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import '../models/post_model.dart';
import '../profil/BenDrawer.dart';

class DoluAkis extends StatefulWidget {
  const DoluAkis({super.key});

  @override
  State<DoluAkis> createState() => _DoluAkisState();
}

class _DoluAkisState extends State<DoluAkis> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  final puanSa = Hive.box('unicotantic');

  Future<void> _launchGooglePlay() async {
    const url = 'https://play.google.com/store/apps/details?id=com.unicotantic.unicotantic';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Google Play Store açarken hata oluştu.';
    }
  }

  @override
  void initState() {
    super.initState();
    puanSa.put('yorumYapanEmail', '');
  }

  @override
  Widget build(BuildContext context) {
    dynamic guncellemeYayinlandi = puanSa.get('guncellemeYayinlandi') ?? 0;
    dynamic uygulamaSurumu = puanSa.get('uygulamaSurumu') ?? 0;

    Query postlarSorgu = _firestore
        .collection('postlar')
        .where('parentID', isNull: true)
        .orderBy("createdAt", descending: true)
        .limit(100);

    var kullaniciBilgileri = _firestore.collection('Kullanicilar').doc(kullanici.email);

    return Scaffold(
      appBar: akisAppBar(),
      drawer: const BenDrawer(),
      body: Center(
        child: Column(
          children: [
            if (guncellemeYayinlandi > uygulamaSurumu) googlePlayLink(),
            StreamBuilder<DocumentSnapshot>(
              stream: kullaniciBilgileri.snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasError) return const Text('Hata');
                if (!userSnapshot.hasData) return buildDefaultTextStyle();

                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                final List engelleyenler = userData?['engelleyenler'] ?? [];

                return StreamBuilder<QuerySnapshot>(
                  stream: postlarSorgu.snapshots(),
                  builder: (context, postsSnapshot) {
                    if (postsSnapshot.hasError) return const Text('Hata');
                    if (!postsSnapshot.hasData) return buildDefaultTextStyle();

                    final posts = postsSnapshot.data!.docs;

                    return Flexible(
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = PostModel.fromSnapshot(posts[index]);

                          if (engelleyenler.contains(post.authorID)) {
                            return const SizedBox.shrink();
                          }

                          return GestureDetector(
                            onTap: () => Get.to(PostAyrintilari(postID: post.postID)),
                            child: Card(
                              color: Colors.grey[900],
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          post.authorID,
                                          style: const TextStyle(
                                            color: Colors.cyan,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          "${post.createdAt.day}/${post.createdAt.month} ${post.createdAt.hour}:${post.createdAt.minute}",
                                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const Divider(color: Colors.grey),
                                    const SizedBox(height: 8),
                                    Text(
                                      post.text,
                                      style: const TextStyle(color: Colors.white, fontSize: 15),
                                    ),
                                    const SizedBox(height: 12),
                                    if (post.mediaUrl != null && post.mediaUrl != 'bos' && post.mediaUrl != '')
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: post.mediaType == 'image'
                                            ? Image.network(post.mediaUrl!)
                                            : Container(
                                                height: 200,
                                                color: Colors.grey[800],
                                                child: const Center(
                                                  child: Icon(Icons.videocam, color: Colors.white),
                                                ),
                                              ),
                                      ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _simpleStat(Icons.thumb_up, post.likeCount),
                                        _simpleStat(Icons.thumb_down, post.dislikeCount),
                                        _simpleStat(Icons.comment, post.commentCount),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleStat(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Text(count.toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Center googlePlayLink() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            const Text(
              'Yeni sürüme güncelleyin',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _launchGooglePlay,
              child: SizedBox(
                height: 50,
                width: 120,
                child: Image.asset("assets/images/png/googlePlay.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
