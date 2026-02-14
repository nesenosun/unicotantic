import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicotantic/core/services/social_service.dart';
import 'package:unicotantic/core/utils/buildDefaultTextStyle.dart';
import 'package:unicotantic/features/feed/feed_video_player.dart';
import 'package:unicotantic/features/feed/post_ayrintilari.dart';
import 'package:unicotantic/features/feed/post_olustur_panel.dart';
import 'package:unicotantic/features/profile/site.dart';

import '../../core/utils/postSabitleri.dart';
import '../../core/voice/widgets/voice_bottom_bar.dart';

enum FeedType { explore, following, friends }

class Akis extends StatefulWidget {
  final int initialIndex;
  const Akis({super.key, this.initialIndex = 0});

  @override
  State<Akis> createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  User? get kullanici => FirebaseAuth.instance.currentUser;
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
    if (kullanici == null) return buildDefaultTextStyle();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        Widget content = DefaultTabController(
          length: 3,
          initialIndex: widget.initialIndex,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              centerTitle: false,
              titleSpacing: 0,
              leadingWidth: isDesktop ? 0 : 56,
              leading: isDesktop
                  ? const SizedBox.shrink()
                  : Builder(
                      builder: (context) => IconButton(
                        icon: Image.asset(
                          "assets/images/icon/icon256.png",
                          height: 32,
                          width: 32,
                          fit: BoxFit.contain,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        tooltip: 'Menü',
                      ),
                    ),
              title: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                indicatorColor: Colors.cyanAccent,
                labelColor: Colors.cyanAccent,
                unselectedLabelColor: Colors.grey,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                labelPadding: EdgeInsets.symmetric(horizontal: 12),
                tabs: [
                  Tab(text: "Keşfet"),
                  Tab(text: "Takip"),
                  Tab(text: "Arkadaşlar"),
                ],
              ),
            ),
            drawer: isDesktop ? null : const Site(),
            floatingActionButton: FloatingActionButton(
              onPressed: _showPostPanel,
              backgroundColor: Colors.white24,
              child: Image.asset("assets/images/png/dactylo.png"),
            ),
            bottomNavigationBar: isDesktop
                ? null
                : VoiceBottomBar(currentTab: VoiceBottomBarTab.home),
            body: TabBarView(
              children: [
                FeedList(type: FeedType.explore, currentUserId: kullanici!.uid),
                FeedList(
                    type: FeedType.following, currentUserId: kullanici!.uid),
                FeedList(type: FeedType.friends, currentUserId: kullanici!.uid),
              ],
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
}

// --- Yeni FeedList Widget'ı (Future + RefreshIndicator) ---
class FeedList extends StatefulWidget {
  final FeedType type;
  final String currentUserId;

  const FeedList({
    Key? key,
    required this.type,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList>
    with AutomaticKeepAliveClientMixin {
  final _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filtreleme listeleri
  List _blockedMe = [];
  List _myBlocked = [];
  List _myMuted = [];
  List<String> _friendIds = [];
  List<String> _followingIds = [];

  @override
  bool get wantKeepAlive => true; // Sekme değişince listeyi koru

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Kullanıcı bilgilerini ve sosyal listeleri çek
      final userDoc =
          await _firestore.collection('users').doc(widget.currentUserId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _blockedMe = data['blockedBy'] ?? [];
        _myBlocked = data['blockedUsers'] ?? [];
        _myMuted = data['mutedUsers'] ?? [];
      }

      // Sosyal ID'leri çek (Parallel)
      final results = await Future.wait([
        SocialService().getFriendIds(widget.currentUserId),
        SocialService().getFollowingIds(widget.currentUserId),
      ]);

      _friendIds = results[0];
      _followingIds = results[1];

      // Kendi ID'mizi de ekleyelim (kendi postlarımızı görmek için)
      if (!_friendIds.contains(widget.currentUserId))
        _friendIds.add(widget.currentUserId);
      if (!_followingIds.contains(widget.currentUserId))
        _followingIds.add(widget.currentUserId);

      // 2. Postları çek
      await _fetchPosts();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Veriler yüklenirken hata oluştu: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchPosts() async {
    try {
      Query query = _firestore
          .collection('posts')
          .where('parentID', isNull: true)
          .orderBy("createdAt", descending: true)
          .limit(50);

      // Not: Firestore 'IN' sorgusu en fazla 10 veya 30 eleman destekler.
      // Arkadaş/Takipçi listesi uzunsa client-side filtreleme yapmak daha güvenlidir (şu anki yöntem).
      // İleride 'feeds' koleksiyonu (Fan-out) yapısına geçilebilir.

      final snapshot = await query.get();
      final allDocs = snapshot.docs;

      final filteredDocs = allDocs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final authorId = data['authorID'] ?? '';

        // Temel Filtreler
        if (_blockedMe.contains(authorId)) return false;
        if (_myBlocked.contains(authorId)) return false;
        if (_myMuted.contains(authorId)) return false;

        // Sekme Filtreleri
        if (widget.type == FeedType.friends) {
          return _friendIds.contains(authorId);
        } else if (widget.type == FeedType.following) {
          return _followingIds.contains(authorId);
        } else {
          // Keşfet: Herkes
          return true;
        }
      }).toList();

      if (mounted) {
        setState(() {
          _posts = filteredDocs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Post çekme hatası: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    // Sadece postları yenile, kullanıcı listelerini her seferinde çekmeye gerek yok
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // KeepAlive

    if (_isLoading) {
      return buildDefaultTextStyle(); // Yükleniyor animasyonu
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (_posts.isEmpty) {
      return _buildEmptyState(widget.type);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.cyanAccent,
      backgroundColor: Colors.grey[900],
      child: ListView.builder(
        key: PageStorageKey(widget.type.toString()),
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final doc = _posts[index];
          // ValueKey kullanarak performans optimizasyonu
          return PostItem(
            key: ValueKey(doc.id),
            doc: doc,
            index: index,
            allDocs: _posts,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(FeedType type) {
    String message = 'Paylaşılmış bir gönderi bulunamadı.';
    IconData icon = Icons.explore_outlined;

    if (type == FeedType.friends) {
      message =
          'Henüz arkadaşlarınızdan bir paylaşım yok.\nArkadaş ekleyerek akışınızı canlandırabilirsiniz!';
      icon = Icons.people_outline;
    } else if (type == FeedType.following) {
      message =
          'Takip ettiğiniz kişilerden henüz bir paylaşım yok.\nYeni kişileri takip ederek akışınızı canlandırabilirsiniz!';
      icon = Icons.person_add_outlined;
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        // ListView kullanıyoruz ki RefreshIndicator çalışsın (scrollable olmalı)
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.grey, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PostItem Widget'ı ---
class PostItem extends StatefulWidget {
  final DocumentSnapshot doc;
  final int index;
  final List<DocumentSnapshot> allDocs;

  const PostItem({
    Key? key,
    required this.doc,
    required this.index,
    required this.allDocs,
  }) : super(key: key);

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final docData = widget.doc.data() as Map<String, dynamic>;

    String authorID = docData['authorID'] ?? docData['email'] ?? '';
    DateTime createdAt = (docData['createdAt'] as Timestamp).toDate();
    String text = docData['text'] ?? '';
    String? mediaUrl = docData['mediaUrl'];
    String mediaType = docData['mediaType'] ?? 'image';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostAyrintilari(postID: widget.doc.id),
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
              postID: widget.doc.id,
              authorID: authorID,
              createdAt: createdAt,
              listOfDocumentSnap: widget.allDocs,
              index: widget.index,
            ),
            PostContentText(content: text),
            if (mediaUrl != null && mediaUrl != 'bos' && mediaUrl != '')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: mediaType == 'video'
                      ? FeedVideoPlayer(videoUrl: mediaUrl)
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                          ),
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            boundaryMargin: const EdgeInsets.all(0),
                            minScale: 1.0,
                            maxScale: 2.5,
                            onInteractionEnd: (details) {
                              _resetZoom();
                            },
                            child: Image.network(
                              mediaUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                      height: 200,
                                      child: Center(child: Icon(Icons.error))),
                            ),
                          ),
                        ),
                ),
              ),
            DorduncuBolumAltBar(
              postID: widget.doc.id,
              authorID: authorID,
              likeCount: docData['likeCount'] ?? 0,
              dislikeCount: docData['dislikeCount'] ?? 0,
              commentCount: docData['commentCount'] ?? 0,
            ),
          ],
        ),
      ),
    );
  }
}
