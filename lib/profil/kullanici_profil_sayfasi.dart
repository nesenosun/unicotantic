import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unicotantic/login/splash.dart';
import 'package:unicotantic/models/post_model.dart';
import 'package:unicotantic/profil/ayarlar.dart';

import '../Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import '../Unic/fonksiyonlar/postSabitleri.dart';
import '../akis/feed_video_player.dart';
import '../akis/post_ayrintilari.dart';
import '../core/voice/widgets/voice_bottom_bar.dart';
import 'full_screen_image_viewer.dart';
import 'full_screen_video_player.dart';

class KullaniciProfilSayfasi extends StatefulWidget {
  const KullaniciProfilSayfasi({super.key});

  @override
  State<KullaniciProfilSayfasi> createState() => _KullaniciProfilSayfasiState();
}

class _KullaniciProfilSayfasiState extends State<KullaniciProfilSayfasi> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  double _headerHeight = 1.0; // 1.0 = full, 0.0 = collapsed

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
    // Show FAB after scrolling 200 pixels
    if (_scrollController.offset > 200 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 200 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }

    // Collapse header based on scroll
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
    setState(() {}); // Refresh
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final firestore = FirebaseFirestore.instance;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: const VoiceBottomBar(currentTab: VoiceBottomBarTab.profile),
        floatingActionButton: _showScrollToTop
            ? FloatingActionButton.small(
                onPressed: _scrollToTopAndRefresh,
                backgroundColor: Colors.cyanAccent,
                child: const Icon(Iconsax.arrow_up, color: Colors.black),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('postlar').where('email', isEqualTo: user.email).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return buildDefaultTextStyle();

              var docs = snapshot.data!.docs;

              docs.sort((a, b) {
                var aData = a.data() as Map<String, dynamic>;
                var bData = b.data() as Map<String, dynamic>;
                var aTime = (aData['createdAt'] as Timestamp?)?.toDate() ??
                    (aData['zaman'] as Timestamp?)?.toDate() ??
                    DateTime(2000);
                var bTime = (bData['createdAt'] as Timestamp?)?.toDate() ??
                    (bData['zaman'] as Timestamp?)?.toDate() ??
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
                return post.mediaUrl != null && post.mediaUrl!.isNotEmpty && post.mediaUrl != 'bos';
              }).toList();

              return NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    // SliverToBoxAdapter içindeki AnimatedContainer kısmını bununla değiştirin:
                    SliverToBoxAdapter(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150), // Daha akıcı bir geçiş
                        height: _headerHeight > 0.3 ? (280 * _headerHeight).clamp(0.0, 300.0) : 0,
                        curve: Curves.easeInOut,
                        child: _headerHeight > 0.3
                            ? SingleChildScrollView(
                                // İçeriğin daralırken taşmasını engeller
                                physics: const NeverScrollableScrollPhysics(),
                                child: Opacity(
                                  // Yükseklik azaldıkça içeriği yavaşça şeffaf yapalım ki daha şık dursun
                                  opacity: ((_headerHeight - 0.3) / 0.7).clamp(0.0, 1.0),
                                  child: _buildHeader(user, firestore, posts.length),
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
  }

  Widget _buildHeader(User user, FirebaseFirestore firestore, int postCount) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('Kullanicilar').doc(user.email).snapshots(),
      builder: (context, snapshot) {
        String? photoUrl;
        if (snapshot.hasData) {
          var data = snapshot.data!.data() as Map<String, dynamic>?;
          photoUrl = data?['profilresmilinki'];
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
                    user.displayName ?? "Kullanıcı",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        signOutFromApp();
                      },
                      child: SizedBox(height: 30, width: 30, child: Image.asset("assets/images/png/ayarlar.png"))),
                ],
              ),
              Text(
                "@${user.email?.split('@')[0]}",
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(postCount.toString(), "Gönderi"),
                  Container(width: 1, height: 30, color: Colors.grey[800]),
                  _buildStatColumn("0", "Takipçi"),
                  Container(width: 1, height: 30, color: Colors.grey[800]),
                  _buildStatColumn("0", "Takip"),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Get.to(Ayarlar());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: const Text(
                    "Profili Düzenle",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
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

        List begenList = docData['begen'] ?? [];
        List begenMeList = docData['begenMe'] ?? [];

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
                ustBolumKullaniciKimligi(
                  post.postID,
                  docData['email'] ?? post.email,
                  docData['tarih'] ?? "${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}",
                  docs,
                  index,
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
                  docs,
                  index,
                  begenMeList.contains(user.email),
                  docs[index].reference.update,
                  begenMeList,
                  begenList.contains(user.email),
                  begenList,
                  post.postID,
                  docData['yorumSayisi'] ?? post.commentCount,
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
                  builder: (context) => FullScreenImageViewer(imageUrl: post.mediaUrl!),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenVideoPlayer(videoUrl: post.mediaUrl!),
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
      // 1. Google oturumunu kapat (Hesap seçme ekranının tekrar gelmesi için)
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();

      // 2. Firebase oturumunu kapat
      await FirebaseAuth.instance.signOut();

      if (kDebugMode) {
        Get.off(Splash());
        print("Oturum başarıyla kapatıldı.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Çıkış yapılırken hata oluştu: $e");
      }
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
