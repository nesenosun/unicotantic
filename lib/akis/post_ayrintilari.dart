import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicotantic/models/post_model.dart';
import 'package:iconsax/iconsax.dart';
import '../Unic/fonksiyonlar/postSabitleri.dart';
import '../akis/feed_video_player.dart';

class PostAyrintilari extends StatefulWidget {
  final String postID;
  const PostAyrintilari({Key? key, required this.postID}) : super(key: key);

  @override
  State<PostAyrintilari> createState() => _PostAyrintilariState();
}

class _PostAyrintilariState extends State<PostAyrintilari> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<List<PostModel>> _getParentChain(String postID) async {
    List<PostModel> chain = [];
    String? currentID = postID;

    while (currentID != null && currentID.isNotEmpty) {
      try {
        final doc = await _firestore.collection('postlar').doc(currentID).get();
        if (!doc.exists) break;

        final data = doc.data() as Map<String, dynamic>;
        final post = PostModel.fromMap(data);
        chain.add(post);

        // Parent ID'yi al
        currentID = data['parentID'] as String?;
        
        // Sonsuz döngüyü önle
        if (chain.length > 50) break;
      } catch (e) {
        print("Parent chain error: $e");
        break;
      }
    }

    return chain.reversed.toList(); // Root'tan başlayarak sırala
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final postDoc = await _firestore.collection('postlar').doc(widget.postID).get();
      if (!postDoc.exists) return;

      final postData = postDoc.data() as Map<String, dynamic>;
      final rootID = postData['rootID'] ?? widget.postID;

      final newCommentID = _firestore.collection('postlar').doc().id;

      await _firestore.collection('postlar').doc(newCommentID).set({
        'postID': newCommentID,
        'postAydi': newCommentID,
        'authorID': user.email,
        'email': user.email,
        'baslik': _commentController.text.trim(),
        'text': _commentController.text.trim(),
        'metin': _commentController.text.trim(),
        'mediaUrl': null,
        'postFotolinki': 'bos',
        'postVideoLinki': '',
        'mediaType': 'text',
        'createdAt': FieldValue.serverTimestamp(),
        'zaman': FieldValue.serverTimestamp(),
        'tarih': "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
        'likeCount': 0,
        'dislikeCount': 0,
        'commentCount': 0,
        'begen': [],
        'begenMe': [],
        'yorumSayisi': 0,
        'parentID': widget.postID,
        'parentId': widget.postID,
        'rootID': rootID,
        'rootId': rootID,
      });

      await _firestore.collection('postlar').doc(widget.postID).update({
        'yorumSayisi': FieldValue.increment(1),
        'commentCount': FieldValue.increment(1),
      });

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      print("Yorum gönderme hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Gönderi', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<PostModel>>(
              future: _getParentChain(widget.postID),
              builder: (context, chainSnapshot) {
                if (chainSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  );
                }

                if (!chainSnapshot.hasData || chainSnapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Gönderi bulunamadı.', style: TextStyle(color: Colors.white)),
                  );
                }

                final parentChain = chainSnapshot.data!;

                return StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('postlar').doc(widget.postID).snapshots(),
                  builder: (context, snapshot) {
                    return ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        // Parent Chain (Root'tan tıklanan post'a kadar, ama tıklanan hariç)
                        ...parentChain.take(parentChain.length - 1).map((parentPost) {
                          return FutureBuilder<DocumentSnapshot>(
                            future: _firestore.collection('postlar').doc(parentPost.postID).get(),
                            builder: (context, parentSnapshot) {
                              if (!parentSnapshot.hasData) return const SizedBox.shrink();
                              
                              var parentData = parentSnapshot.data!.data() as Map<String, dynamic>;
                              
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PostAyrintilari(postID: parentPost.postID),
                                    ),
                                  );
                                },
                                child: Opacity(
                                  opacity: 0.6,
                                  child: _buildPostCard(parentPost, parentData, isParent: true),
                                ),
                              );
                            },
                          );
                        }).toList(),

                        // Tıklanan Post (Ana Post)
                        StreamBuilder<DocumentSnapshot>(
                          stream: _firestore.collection('postlar').doc(widget.postID).snapshots(),
                          builder: (context, currentSnapshot) {
                            if (!currentSnapshot.hasData) return const SizedBox.shrink();
                            
                            var currentData = currentSnapshot.data!.data() as Map<String, dynamic>;
                            var currentPostLive = PostModel.fromMap(currentData);
                            
                            return _buildPostCard(currentPostLive, currentData, isCurrent: true);
                          },
                        ),

                        const SizedBox(height: 8),

                        // Yorumlar (Alt Yorumlar)
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('postlar')
                              .where('parentID', isEqualTo: widget.postID)
                              .snapshots(),
                          builder: (context, commentsSnapshot) {
                            if (!commentsSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            var comments = commentsSnapshot.data!.docs;

                            // Tarihe göre sırala
                            comments.sort((a, b) {
                              var aData = a.data() as Map<String, dynamic>;
                              var bData = b.data() as Map<String, dynamic>;
                              var aTime = (aData['createdAt'] as Timestamp?)?.toDate() ??
                                  (aData['zaman'] as Timestamp?)?.toDate() ??
                                  DateTime(2000);
                              var bTime = (bData['createdAt'] as Timestamp?)?.toDate() ??
                                  (bData['zaman'] as Timestamp?)?.toDate() ??
                                  DateTime(2000);
                              return aTime.compareTo(bTime);
                            });

                            if (comments.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: comments.map((doc) {
                                var commentData = doc.data() as Map<String, dynamic>;
                                PostModel comment = PostModel.fromMap(commentData);
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PostAyrintilari(postID: comment.postID),
                                      ),
                                    );
                                  },
                                  child: _buildPostCard(comment, commentData, isComment: true),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Yorum Girişi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Yorum yaz...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendComment,
                    icon: const Icon(Iconsax.send_1, color: Colors.cyanAccent),
                    iconSize: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostModel post, Map<String, dynamic> docData,
      {bool isCurrent = false, bool isParent = false, bool isComment = false}) {
    List begenList = docData['begen'] ?? [];
    List begenMeList = docData['begenMe'] ?? [];

    List<DocumentSnapshot> singleDocList = [];

    return Card(
      color: isCurrent ? Colors.grey[850] : Colors.grey[900],
      elevation: isCurrent ? 4 : 1,
      margin: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: isParent ? 12 : (isComment ? 8 : 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ustBolumKullaniciKimligi(
            post.postID,
            docData['email'] ?? post.email,
            docData['tarih'] ?? "${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}",
            singleDocList,
            0,
          ),

          ikinciBolumText(post.text),

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

          DorduncuBolumAltBar(
            docData['email'] ?? post.email,
            singleDocList,
            0,
            begenMeList.contains(user.email),
            (data) async {
              await _firestore.collection('postlar').doc(post.postID).update(data);
            },
            begenMeList,
            begenList.contains(user.email),
            begenList,
            post.postID,
            docData['yorumSayisi'] ?? post.commentCount,
          ),
        ],
      ),
    );
  }
}
