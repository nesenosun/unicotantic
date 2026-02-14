import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unicotantic/core/models/post_model.dart';
import 'package:unicotantic/features/auth/splash.dart';
import 'package:unicotantic/features/profile/arkadaslar.dart';
import 'package:unicotantic/features/profile/ayarlar.dart';
import 'package:unicotantic/features/profile/takip_ettiklerim.dart';
import 'package:unicotantic/features/profile/takipciler.dart';

import '../../core/utils/buildDefaultTextStyle.dart';
import '../../core/utils/postSabitleri.dart';
import '../../core/voice/widgets/voice_bottom_bar.dart';
import '../feed/feed_video_player.dart';
import '../feed/post_ayrintilari.dart';
import 'full_screen_image_viewer.dart';
import 'full_screen_video_player.dart';
import 'site.dart';

class KullaniciProfili extends StatefulWidget {
  const KullaniciProfili({super.key});

  @override
  State<KullaniciProfili> createState() => _KullaniciProfiliState();
}

class _KullaniciProfiliState extends State<KullaniciProfili> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  double _headerHeight = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 200 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }

    double offset = _scrollController.offset;
    double newHeight = 1.2 - (offset / 250).clamp(0.0, 1.0);
    if (newHeight != _headerHeight) {
      setState(() => _headerHeight = newHeight);
    }
  }

  void _scrollToTopAndRefresh() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        Widget content = DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.black,
            bottomNavigationBar: isDesktop
                ? null
                : VoiceBottomBar(currentTab: VoiceBottomBarTab.profile),
            floatingActionButton: _showScrollToTop
                ? FloatingActionButton.small(
                    onPressed: _scrollToTopAndRefresh,
                    backgroundColor: Colors.cyanAccent,
                    child: const Icon(Iconsax.arrow_up, color: Colors.black),
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            body: SafeArea(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('posts')
                    .where('authorID', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return buildDefaultTextStyle();

                  var docs = snapshot.data!.docs;

                  docs.sort((a, b) {
                    var aData = a.data() as Map<String, dynamic>;
                    var bData = b.data() as Map<String, dynamic>;
                    var aTime = (aData['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime(2000);
                    var bTime = (bData['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime(2000);
                    return bTime.compareTo(aTime);
                  });

                  final posts = docs.where((d) {
                    var data = d.data() as Map<String, dynamic>;
                    return data['parentID'] == null;
                  }).toList();

                  final comments = docs.where((d) {
                    var data = d.data() as Map<String, dynamic>;
                    return data['parentID'] != null;
                  }).toList();

                  final media = docs.where((d) {
                    var data = d.data() as Map<String, dynamic>;
                    var post = PostModel.fromMap(data);
                    return post.mediaUrl != null &&
                        post.mediaUrl!.isNotEmpty &&
                        post.mediaUrl != 'bos';
                  }).toList();

                  return NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: _headerHeight > 0.3
                                ? (280 * _headerHeight).clamp(0.0, 300.0)
                                : 0,
                            curve: Curves.easeInOut,
                            child: _headerHeight > 0.3
                                ? SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Opacity(
                                      opacity: ((_headerHeight - 0.3) / 0.7)
                                          .clamp(0.0, 1.0),
                                      child: _buildHeader(
                                          user, firestore, posts.length),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverAppBarDelegate(
                            const TabBar(
                              indicatorColor: Colors.cyanAccent,
                              labelColor: Colors.cyanAccent,
                              unselectedLabelColor: Colors.grey,
                              tabs: [
                                Tab(text: "Gönderiler"),
                                Tab(text: "Yorumlar"),
                                Tab(text: "Medya"),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: [
                        _buildFeedList(posts, user),
                        _buildFeedList(comments, user),
                        _buildMediaGrid(media),
                      ],
                    ),
                  );
                },
              ),
            ),
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
                        left: BorderSide(
                            color: Colors.white.withOpacity(0.05), width: 1),
                        right: BorderSide(
                            color: Colors.white.withOpacity(0.05), width: 1),
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

  Widget _buildHeader(User user, FirebaseFirestore firestore, int postCount) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String? photoUrl;
        String? friendCount = "0";
        String? followerCount = "0";
        String? followingCount = "0";
        String? postCountStr = postCount.toString();
        Map<String, dynamic>? data;

        if (snapshot.hasData) {
          data = snapshot.data!.data() as Map<String, dynamic>?;
          photoUrl = data?['photoUrl'];
          friendCount = (data?['friendCount'] ?? 0).toString();
          followerCount = (data?['followerCount'] ?? 0).toString();
          followingCount = (data?['followingCount'] ?? 0).toString();
          postCountStr = (data?['postCount'] ?? postCount).toString();
        }

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: photoUrl == null || photoUrl.isEmpty
                    ? const Icon(Iconsax.user, color: Colors.white, size: 40)
                    : CircleAvatar(
                        backgroundImage: NetworkImage(photoUrl),
                        backgroundColor: Colors.black,
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data?['name'] ?? user.displayName ?? "Kullanıcı",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Get.to(() => Ayarlar());
                      } else if (value == 'logout') {
                        signOutFromApp();
                      }
                    },
                    color: Colors.grey[900],
                    icon: SizedBox(
                        height: 30,
                        width: 30,
                        child: Image.asset("assets/images/png/settings.png")),
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Iconsax.edit, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text('Profili Düzenle',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Iconsax.logout, color: Colors.red, size: 20),
                            SizedBox(width: 10),
                            Text('Çıkış Yap',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "@${data?['username'] ?? user.email?.split('@')[0]}",
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${data?['unicBalance'] ?? 0} unic",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(postCountStr, "Gönderi"),
                  Container(width: 1, height: 30, color: Colors.grey[800]),
                  _buildStatColumn(friendCount, "Arkadaşlar",
                      onTap: () => Get.to(() => const ArkadaslarPage())),
                  Container(width: 1, height: 30, color: Colors.grey[800]),
                  _buildStatColumn(followerCount, "Takipçi",
                      onTap: () => Get.to(() => const TakipcilerPage())),
                  Container(width: 1, height: 30, color: Colors.grey[800]),
                  _buildStatColumn(followingCount, "Takip",
                      onTap: () => Get.to(() => const TakipEttiklerimPage())),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedList(List<DocumentSnapshot> docs, User user) {
    if (docs.isEmpty) {
      return const Center(
        child: Text("Henüz bir şey yok.", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var docData = docs[index].data() as Map<String, dynamic>;
        var post = PostModel.fromMap(docData);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostAyrintilari(postID: post.postID),
              ),
            );
          },
          child: Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostHeader(
                  postID: post.postID,
                  authorID: post.authorID,
                  createdAt: post.createdAt,
                  listOfDocumentSnap: docs,
                  index: index,
                ),
                PostContentText(content: post.text),
                if (post.mediaUrl != null &&
                    post.mediaUrl != 'bos' &&
                    post.mediaUrl != '')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: post.mediaType == 'video'
                          ? FeedVideoPlayer(videoUrl: post.mediaUrl!)
                          : Image.network(
                              post.mediaUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                      height: 200,
                                      child: Center(child: Icon(Icons.error))),
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
          ),
        );
      },
    );
  }

  Widget _buildMediaGrid(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Center(
        child: Text("Medya yok.", style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var data = docs[index].data() as Map<String, dynamic>;
        var post = PostModel.fromMap(data);

        return GestureDetector(
          onTap: () {
            if (post.mediaType == 'image') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FullScreenImageViewer(imageUrl: post.mediaUrl!),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FullScreenVideoPlayer(videoUrl: post.mediaUrl!),
                ),
              );
            }
          },
          child: post.mediaType == 'image'
              ? Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(post.mediaUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Iconsax.play, color: Colors.white, size: 30),
                  ),
                ),
        );
      },
    );
  }

  Future<void> signOutFromApp() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      debugPrint("Oturum başarıyla kapatıldı.");
      Get.off(Splash());
    } catch (e) {
      debugPrint("Çıkış yapılırken hata oluştu: $e");
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
