import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';
import 'package:unicotantic/models/post_model.dart';
import 'package:unicotantic/profil/BenDrawer.dart';

import 'metin_gir.dart';

class PostAyrintilari extends StatefulWidget {
  final String postID;
  const PostAyrintilari({Key? key, required this.postID}) : super(key: key);

  @override
  State<PostAyrintilari> createState() => _PostAyrintilariState();
}

class _PostAyrintilariState extends State<PostAyrintilari> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: akisAppBar(),
      drawer: const BenDrawer(),
      body: Stack(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('postlar').doc(widget.postID).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Post bulunamadı.', style: TextStyle(color: Colors.white)));
              }

              PostModel currentPost = PostModel.fromSnapshot(snapshot.data!);

              return ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  // Parent Post (Eğer varsa)
                  if (currentPost.parentID != null && currentPost.parentID!.isNotEmpty)
                    StreamBuilder<DocumentSnapshot>(
                      stream: _firestore.collection('postlar').doc(currentPost.parentID).snapshots(),
                      builder: (context, parentSnap) {
                        if (!parentSnap.hasData || !parentSnap.data!.exists) return const SizedBox.shrink();
                        PostModel parentPost = PostModel.fromSnapshot(parentSnap.data!);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16, top: 8),
                              child: Text('Üst Post',
                                  style: TextStyle(color: Colors.cyan, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            _buildPostCard(parentPost, isParent: true),
                            const Divider(color: Colors.cyan, height: 1),
                          ],
                        );
                      },
                    ),

                  // Ana Post
                  _buildPostCard(currentPost, isCurrent: true),

                  const Divider(color: Colors.cyan, thickness: 2),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Cevaplar',
                        style: TextStyle(color: Colors.cyan, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),

                  // Cevaplar (Children)
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('postlar')
                        .where('parentID', isEqualTo: widget.postID)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, childrenSnap) {
                      if (!childrenSnap.hasData) return const Center(child: CircularProgressIndicator());
                      if (childrenSnap.data!.docs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('Henüz cevap yok.', style: TextStyle(color: Colors.white60)),
                          ),
                        );
                      }

                      return Column(
                        children: childrenSnap.data!.docs.map((doc) {
                          PostModel childPost = PostModel.fromSnapshot(doc);
                          return _buildPostCard(childPost);
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          // Yanıt girişi için metin_gir widget'ı
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('postlar').doc(widget.postID).snapshots(),
            builder: (context, snap) {
              if (!snap.hasData || !snap.data!.exists) return const SizedBox.shrink();
              PostModel post = PostModel.fromSnapshot(snap.data!);
              return MetinGir(
                parentID: widget.postID,
                rootID: post.rootID,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostModel post, {bool isCurrent = false, bool isParent = false}) {
    return Card(
      color: Colors.grey[900],
      elevation: isCurrent ? 4 : 1,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: isParent ? 12 : 8),
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
                  style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 12),
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
                        child: const Center(child: Icon(Icons.videocam, color: Colors.white)),
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
}
