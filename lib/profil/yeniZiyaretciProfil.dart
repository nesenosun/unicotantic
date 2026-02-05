import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unicotantic/models/post_model.dart';

import '../Unic/doluAkis/doluAkisAppBar.dart';
import '../Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import '../Unic/fonksiyonlar/negatifOyVer_pozitifOyVer.dart';
import '../Unic/fonksiyonlar/postSabitleri.dart';
import '../akis/feed_video_player.dart';
import '../akis/post_ayrintilari.dart';
import '../core/voice/widgets/voice_bottom_bar.dart';
import '../profil/BenDrawer.dart';
import 'full_screen_image_viewer.dart';
import 'full_screen_video_player.dart';

class YeniZiyaretciProfil extends StatefulWidget {
  final String gelenKullaniciEmail;

  YeniZiyaretciProfil({required this.gelenKullaniciEmail});

  @override
  State<YeniZiyaretciProfil> createState() => _YeniZiyaretciProfilState();
}

class _YeniZiyaretciProfilState extends State<YeniZiyaretciProfil> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  double _headerHeight = 1.0;
  final User currentUser = FirebaseAuth.instance.currentUser!;

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
    double newHeight = 1.0 - (offset / 300).clamp(0.0, 1.0);
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

  Future<void> _toggleBlock(Map<String, dynamic> visitorData) async {
    final List engelledim = visitorData['engelledim'] ?? [];
    final bool isBlocked = engelledim.contains(currentUser.email);

    if (isBlocked) {
      await FirebaseFirestore.instance.collection("Kullanicilar").doc(widget.gelenKullaniciEmail).update({
        'engelledim': FieldValue.arrayRemove([currentUser.email])
      });
      await FirebaseFirestore.instance.collection("Kullanicilar").doc(currentUser.email).update({
        'engelleyenler': FieldValue.arrayRemove([widget.gelenKullaniciEmail])
      });
    } else {
      await FirebaseFirestore.instance.collection("Kullanicilar").doc(widget.gelenKullaniciEmail).update({
        'engelledim': FieldValue.arrayUnion([currentUser.email])
      });
      await FirebaseFirestore.instance.collection("Kullanicilar").doc(currentUser.email).update({
        'engelleyenler': FieldValue.arrayUnion([widget.gelenKullaniciEmail])
      });
    }
    unicCikar();
  }

  Future<void> _toggleAdd(Map<String, dynamic> visitorData) async {
    final List begen = visitorData['begen'] ?? [];
    final bool isAdded = begen.contains(currentUser.email);

    if (isAdded) {
      await FirebaseFirestore.instance.collection("Kullanicilar").doc(currentUser.email).update({
        'arkadaslar': FieldValue.arrayRemove([widget.gelenKullaniciEmail])
      });
      await FirebaseFirestore.instance.collection("Kullanicilar").doc(widget.gelenKullaniciEmail).update({
        'begen': FieldValue.arrayRemove([currentUser.email])
      });
    } else {
      await FirebaseFirestore.instance.collection("Kullanicilar").doc(currentUser.email).update({
        'arkadaslar': FieldValue.arrayUnion([widget.gelenKullaniciEmail])
      });
      await FirebaseFirestore.instance.collection("Kullanicilar").doc(widget.gelenKullaniciEmail).update({
        'begen': FieldValue.arrayUnion([currentUser.email])
      });
    }
    unicCikar();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: akisAppBar(),
        drawer: const BenDrawer(),
        bottomNavigationBar: const VoiceBottomBar(),
        floatingActionButton: _showScrollToTop
            ? FloatingActionButton.small(
                onPressed: _scrollToTopAndRefresh,
                backgroundColor: Colors.cyanAccent,
                child: const Icon(Iconsax.arrow_up, color: Colors.black),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: firestore.collection('Kullanicilar').doc(widget.gelenKullaniciEmail).snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) return buildDefaultTextStyle();
              if (!userSnapshot.data!.exists) {
                return const Center(child: Text("Kullanıcı bulunamadı.", style: TextStyle(color: Colors.white)));
              }

              var userData = userSnapshot.data!.data() as Map<String, dynamic>;
              bool engelledim = (userData['engelledim'] ?? []).contains(currentUser.email);
              bool arkadaslarIcindemi = (userData['arkadaslar'] ?? []).contains(currentUser.email);

              return StreamBuilder<QuerySnapshot>(
                stream:
                    firestore.collection('postlar').where('email', isEqualTo: widget.gelenKullaniciEmail).snapshots(),
                builder: (context, postSnapshot) {
                  if (!postSnapshot.hasData) return buildDefaultTextStyle();

                  var docs = postSnapshot.data!.docs;
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

                  return Stack(
                    children: [
                      NestedScrollView(
                        controller: _scrollController,
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            // SliverToBoxAdapter içindeki kısım
                            SliverToBoxAdapter(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                // clamp kullanarak yüksekliğin negatif veya aşırı büyümesini engelleyelim
                                height: _headerHeight > 0.3 ? (320 * _headerHeight).clamp(0.0, 350.0) : 0,
                                child: _headerHeight > 0.3
                                    ? SingleChildScrollView(
                                        // Taşmayı önleyen ana widget
                                        physics:
                                            const NeverScrollableScrollPhysics(), // Kaydırmayı engelle (header olduğu için)
                                        child: Opacity(
                                          // Header küçüldükçe içeriği şeffaf yaparak görsel bozulmayı önle
                                          opacity: ((_headerHeight - 0.3) / 0.7).clamp(0.0, 1.0),
                                          child: ClipRect(
                                            // Kenarlardan taşan görseli keser
                                            child: _buildVisitorHeader(userData, posts.length),
                                          ),
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
                        body: engelledim
                            ? const Center(
                                child: Text("Bu kullanıcı sizi engelledi.", style: TextStyle(color: Colors.red)))
                            : TabBarView(
                                children: [
                                  _buildFeedList(posts),
                                  _buildFeedList(comments),
                                  _buildMediaGrid(media),
                                ],
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVisitorHeader(Map<String, dynamic> userData, int postCount) {
    String? photoUrl = userData['profilresmilinki'];
    List begen = userData['begen'] ?? [];
    List engelleyenler = userData['engelleyenler'] ?? [];
    bool isAdded = begen.contains(currentUser.email);
    bool isBlocked = engelleyenler.contains(currentUser.email);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
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
          Text(
            userData['isim'] ?? "Kullanıcı",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "@${userData['id'] ?? userData['email']?.split('@')[0]}",
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(postCount.toString(), "Gönderi"),
              Container(width: 1, height: 30, color: Colors.grey[800]),
              _buildStatColumn((userData['arkadaslar']?.length ?? 0).toString(), "Takipçi"),
              Container(width: 1, height: 30, color: Colors.grey[800]),
              _buildStatColumn(userData['unic']?.toString() ?? "0", "Unic"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ekle/Ekleyen Butonu
              GestureDetector(
                onTap: () => _toggleAdd(userData),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAdded ? Colors.green.withOpacity(0.2) : Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isAdded ? Colors.green : Colors.grey[800]!),
                  ),
                  child: Text(
                    isAdded ? "Ekleyen (${begen.length})" : "Ekle",
                    style: TextStyle(
                        color: isAdded ? Colors.green : Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Engelle Butonu
              GestureDetector(
                onTap: () => _toggleBlock(userData),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isBlocked ? Colors.red.withOpacity(0.2) : Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isBlocked ? Colors.red : Colors.grey[800]!),
                  ),
                  child: Text(
                    isBlocked ? "Engellendi" : "Engelle",
                    style: TextStyle(
                        color: isBlocked ? Colors.red : Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildFeedList(List<DocumentSnapshot> docs) {
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
                  begenMeList.contains(currentUser.email),
                  docs[index].reference.update,
                  begenMeList,
                  begenList.contains(currentUser.email),
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
