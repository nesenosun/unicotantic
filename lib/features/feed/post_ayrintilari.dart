import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unicotantic/core/models/post_model.dart';
import 'package:unicotantic/core/services/social_service.dart';

import '../../core/utils/postSabitleri.dart';
import '../../core/voice/widgets/voice_bottom_bar.dart';
import '../profile/site.dart';
import 'feed_video_player.dart';

class PostAyrintilari extends StatefulWidget {
  final String postID;
  const PostAyrintilari({Key? key, required this.postID}) : super(key: key);

  @override
  State<PostAyrintilari> createState() => _PostAyrintilariState();
}

class _PostAyrintilariState extends State<PostAyrintilari> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  final _socialService = SocialService();
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
        final doc = await _firestore.collection('posts').doc(currentID).get();
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
      final postDoc = await _firestore.collection('posts').doc(widget.postID).get();
      if (!postDoc.exists) return;

      final postData = postDoc.data() as Map<String, dynamic>;
      final rootID = postData['rootID'] ?? widget.postID;

      final newCommentID = _firestore.collection('posts').doc().id;
      final commentText = _commentController.text.trim();

      // 1. Yeni Yorumu Oluştur
      await _firestore.collection('posts').doc(newCommentID).set({
        'postID': newCommentID,
        'authorID': user.uid,
        'email': user.email,
        'text': commentText,
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'dislikeCount': 0,
        'commentCount': 0,
        'mediaUrl': null,
        'mediaType': 'text',
        'parentID': widget.postID,
        'rootID': rootID,
      });

      // 2. Ana Postun Yorum Sayısını Artır
      await _firestore.collection('posts').doc(widget.postID).update({
        'commentCount': FieldValue.increment(1),
      });

      // 3. Bildirim Gönder (SocialService Kullanımı)
      final postOwnerId = postData['authorID']; // Email yerine UID
      if (postOwnerId != null && postOwnerId != user.uid) {
        await _socialService.createNotification(
          targetId: postOwnerId,
          fromId: user.uid,
          type: 'comment',
          postId: widget.postID,
          commentId: newCommentID,
          content: commentText,
        );
      }

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      print("Yorum gönderme hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        Widget content = Scaffold(
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
          bottomNavigationBar: isDesktop ? null : VoiceBottomBar(currentTab: VoiceBottomBarTab.home),
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
                      stream: _firestore.collection('users').doc(user.uid).snapshots(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData) return const SizedBox.shrink();

                        final userData = userSnap.data!.data() as Map<String, dynamic>?;
                        final List myBlocked = userData?['blockedUsers'] ?? [];
                        final List blockedMe = userData?['blockedBy'] ?? [];

                        return StreamBuilder<DocumentSnapshot>(
                          stream: _firestore.collection('posts').doc(widget.postID).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();

                            final postData = snapshot.data!.data() as Map<String, dynamic>;
                            final authorId = postData['authorID'] ?? '';

                            // Engelleme Kontrolü
                            if (myBlocked.contains(authorId) || blockedMe.contains(authorId)) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Iconsax.user_minus, color: Colors.redAccent, size: 60),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Bu gönderi kısıtlanmıştır.',
                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Engellediğiniz veya sizi engelleyen kullanıcıların içeriklerini göremezsiniz.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView(
                              padding: const EdgeInsets.only(bottom: 16),
                              children: [
                                // Parent Chain
                                ...parentChain.take(parentChain.length - 1).map((parentPost) {
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: _firestore.collection('posts').doc(parentPost.postID).get(),
                                    builder: (context, parentSnapshot) {
                                      if (!parentSnapshot.hasData) return const SizedBox.shrink();

                                      // var parentData = parentSnapshot.data!.data() as Map<String, dynamic>;

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
                                          child:
                                              _buildPostCard(parentPost, parentSnapshot.data!, // Snapshot gönderiliyor
                                                  isParent: true),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),

                                // Tıklanan Post (Ana Post)
                                StreamBuilder<DocumentSnapshot>(
                                  stream: _firestore.collection('posts').doc(widget.postID).snapshots(),
                                  builder: (context, currentSnapshot) {
                                    if (!currentSnapshot.hasData) return const SizedBox.shrink();

                                    var currentDataMap = currentSnapshot.data!.data() as Map<String, dynamic>;
                                    var currentPostLive = PostModel.fromMap(currentDataMap);

                                    return _buildPostCard(
                                        currentPostLive, currentSnapshot.data!, // Snapshot gönderiliyor
                                        isCurrent: true);
                                  },
                                ),

                                const SizedBox(height: 8),

                                StreamBuilder<QuerySnapshot>(
                                  stream: _firestore
                                      .collection('posts')
                                      .where('parentID', isEqualTo: widget.postID)
                                      .snapshots(),
                                  builder: (context, commentsSnapshot) {
                                    if (!commentsSnapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }

                                    var comments = commentsSnapshot.data!.docs.toList();

                                    comments.sort((a, b) {
                                      var aData = a.data() as Map<String, dynamic>;
                                      var bData = b.data() as Map<String, dynamic>;
                                      var aTime = aData['createdAt'] as Timestamp?;
                                      var bTime = bData['createdAt'] as Timestamp?;
                                      if (aTime == null || bTime == null) return 0;
                                      return aTime.compareTo(bTime);
                                    });

                                    if (comments.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return Column(
                                      children: comments.asMap().entries.map((entry) {
                                        int index = entry.key;
                                        var doc = entry.value;
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
                                          child: _buildPostCard(comment, doc, // Snapshot gönderiliyor
                                              isComment: true,
                                              commentDocs: comments,
                                              commentIndex: index),
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

        if (isDesktop) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Row(
              children: [
                const Expanded(flex: 1, child: Site()),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
                        right: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
                      ),
                    ),
                    child: content,
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox()),
              ],
            ),
          );
        }

        return content;
      },
    );
  }

  // Güncellenen Widget Build Fonksiyonu
  Widget _buildPostCard(PostModel post, DocumentSnapshot snapshot,
      {bool isCurrent = false,
      bool isParent = false,
      bool isComment = false,
      List<DocumentSnapshot>? commentDocs,
      int? commentIndex}) {
    // Güvenli liste oluşturma
    // Eğer comment değilse, tek elemanlı bir liste oluşturup veriyoruz.
    // Böylece PostHeader içindeki listOfDocumentSnap[index] hata vermez.
    final safeDocs = isComment ? (commentDocs ?? []) : [snapshot];
    final safeIndex = isComment ? (commentIndex ?? 0) : 0;

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
          PostHeader(
            postID: post.postID,
            authorID: post.authorID,
            createdAt: post.createdAt,
            listOfDocumentSnap: safeDocs,
            index: safeIndex,
          ),
          PostContentText(content: post.text),
          if (post.mediaUrl != null && post.mediaUrl != 'bos' && post.mediaUrl != '')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: post.mediaType == 'video'
                    ? FeedVideoPlayer(videoUrl: post.mediaUrl!)
                    : Image.network(
                        post.mediaUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(height: 200, child: Center(child: Icon(Icons.error))),
                      ),
              ),
            ),
          DorduncuBolumAltBar(
            postID: post.postID,
            authorID: post.authorID,
            likeCount: post.likeCount,
            dislikeCount: post.dislikeCount,
            commentCount: post.commentCount,
          ),
        ],
      ),
    );
  }
}
