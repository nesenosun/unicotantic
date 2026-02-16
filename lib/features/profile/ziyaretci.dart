import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unicotantic/core/models/post_model.dart';

import '../../core/services/social_service.dart';
import '../../core/utils/buildDefaultTextStyle.dart';
import '../../core/utils/postSabitleri.dart';
import '../../core/voice/widgets/voice_bottom_bar.dart';
import '../chat/chat_screen.dart';
import '../feed/feed_video_player.dart';
import '../feed/post_ayrintilari.dart';
import 'full_screen_image_viewer.dart';
import 'full_screen_video_player.dart';
import 'kullanici_profili.dart';
import 'site.dart';
import 'arkadaslar.dart';
import 'takipciler.dart';
import 'takip_ettiklerim.dart';

class Ziyaretci extends StatefulWidget {
  final String gelenKullaniciEmail;

  Ziyaretci({required this.gelenKullaniciEmail});

  @override
  State<Ziyaretci> createState() => _ZiyaretciState();
}

class _ZiyaretciState extends State<Ziyaretci> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  double _headerHeight = 1.0;
  User? get currentUser => FirebaseAuth.instance.currentUser;
  final SocialService _socialService = SocialService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    final user = currentUser;
    if (user != null &&
        (widget.gelenKullaniciEmail == user.email ||
            widget.gelenKullaniciEmail == user.uid)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.off(() => const KullaniciProfili());
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final user = currentUser;

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
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('profil'.tr,
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
            drawer: isDesktop ? null : const Site(),
            bottomNavigationBar: isDesktop ? null : VoiceBottomBar(),
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
              child: StreamBuilder<DocumentSnapshot>(
                stream: firestore
                    .collection('users')
                    .doc(widget.gelenKullaniciEmail)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return buildDefaultTextStyle();
                  if (!userSnapshot.data!.exists) {
                    return Center(
                      child: Text("kullanici_bulunamadi".tr,
                          style: const TextStyle(color: Colors.white)),
                    );
                  }

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData == null) return buildDefaultTextStyle();

                  bool beniEngelledi =
                      (userData['blockedUsers'] ?? []).contains(user.uid);
                  bool benEngelledim =
                      (userData['blockedBy'] ?? []).contains(user.uid);

                  return StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection('posts')
                        .where('authorID',
                            isEqualTo: widget.gelenKullaniciEmail)
                        .snapshots(),
                    builder: (context, postSnapshot) {
                      if (!postSnapshot.hasData) return buildDefaultTextStyle();

                      var docs = postSnapshot.data!.docs;

                      final posts = docs.where((d) {
                        var data = d.data() as Map<String, dynamic>;
                        return data['parentID'] == null;
                      }).toList();

                      final comments = docs.where((d) {
                        var data = d.data() as Map<String, dynamic>;
                        return data['parentID'] != null;
                      }).toList();

                      final mediaPosts = docs.where((d) {
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
                                duration: const Duration(milliseconds: 200),
                                height: _headerHeight > 0.3
                                    ? (320 * _headerHeight).clamp(0.0, 350.0)
                                    : 0,
                                child: _headerHeight > 0.3
                                    ? SingleChildScrollView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        child: Opacity(
                                          opacity: ((_headerHeight - 0.3) / 0.7)
                                              .clamp(0.0, 1.0),
                                          child: _buildVisitorHeader(
                                              userData, posts.length, user.uid),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _SliverAppBarDelegate(
                                TabBar(
                                  indicatorColor: Colors.cyanAccent,
                                  labelColor: Colors.cyanAccent,
                                  unselectedLabelColor: Colors.grey,
                                  tabs: [
                                    Tab(text: "gonderiler".tr),
                                    Tab(text: "yorumlar".tr),
                                    Tab(text: "medya".tr),
                                  ],
                                ),
                              ),
                            ),
                          ];
                        },
                        body: (beniEngelledi || benEngelledim)
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Iconsax.user_minus,
                                        color: Colors.redAccent, size: 50),
                                    const SizedBox(height: 16),
                                    Text(
                                      beniEngelledi
                                          ? "engellendi_mesaji".tr
                                          : "engelledin_mesaji".tr,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                            : TabBarView(
                                children: [
                                  _buildPostList(posts),
                                  _buildPostList(comments),
                                  _buildMediaGrid(mediaPosts),
                                ],
                              ),
                      );
                    },
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

  Widget _buildVisitorHeader(
      Map<String, dynamic> userData, int postCount, String currentUserId) {
    String? photoUrl = userData['photoUrl'];
    int postCountVal = userData['postCount'] ?? postCount;
    int friendCount = userData['friendCount'] ?? 0;

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
          FutureBuilder<String>(
            future: _socialService.getFriendshipStatus(
                currentUserId, userData['uid'] ?? widget.gelenKullaniciEmail),
            builder: (context, statusSnapshot) {
              String status = statusSnapshot.data ?? 'none';
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (status == 'friends')
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Iconsax.user_tick,
                          color: Colors.cyanAccent, size: 20),
                    ),
                  Text(
                    userData['name'] ?? userData['displayName'] ?? "Kullanıcı",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FutureBuilder<Map<String, bool>>(
                    future: Future.wait<bool>([
                      _socialService.isMuted(currentUserId,
                          userData['uid'] ?? widget.gelenKullaniciEmail),
                      _socialService.isBlocked(currentUserId,
                          userData['uid'] ?? widget.gelenKullaniciEmail),
                      _socialService.isFollowing(currentUserId,
                          userData['uid'] ?? widget.gelenKullaniciEmail),
                    ]).then((results) => {
                          'isMuted': results[0],
                          'isBlocked': results[1],
                          'isFollowing': results[2],
                        }),
                    builder: (context, socialSnap) {
                      bool isMutedStatus = socialSnap.data?['isMuted'] ?? false;
                      bool isBlockedStatus =
                          socialSnap.data?['isBlocked'] ?? false;
                      bool isFollowingStatus =
                          socialSnap.data?['isFollowing'] ?? false;

                      return PopupMenuButton<String>(
                        onSelected: (value) async {
                          final targetUid =
                              userData['uid'] ?? widget.gelenKullaniciEmail;
                          if (value == 'unfollow') {
                            await _socialService.unfollowUser(
                                currentUserId, targetUid);
                            Get.snackbar('bilgi'.tr, 'takibi_biraktin'.tr);
                            setState(() {});
                          } else if (value == 'remove_friend') {
                            _showRemoveFriendDialog(targetUid, currentUserId);
                          } else if (value == 'mute') {
                            if (isMutedStatus) {
                              await _socialService.unmuteUser(
                                  currentUserId, targetUid);
                              Get.snackbar('bilgi'.tr, 'ses_acildi'.tr);
                            } else {
                              await _socialService.muteUser(
                                  currentUserId, targetUid);
                              Get.snackbar('bilgi'.tr, 'sessize_alindi'.tr);
                            }
                            setState(() {});
                          } else if (value == 'block') {
                            if (isBlockedStatus) {
                              await _socialService.unblockUser(
                                  currentUserId, targetUid);
                              Get.snackbar('bilgi'.tr, 'engel_kaldirildi'.tr);
                            } else {
                              await _socialService.blockUser(
                                  currentUserId, targetUid);
                              Get.snackbar(
                                  'bilgi'.tr, 'kullanici_engellendi'.tr);
                            }
                            setState(() {});
                          }
                        },
                        color: Colors.grey[900],
                        icon: SizedBox(
                            height: 25,
                            width: 25,
                            child:
                                Image.asset("assets/images/png/settings.png")),
                        itemBuilder: (context) => [
                          if (isFollowingStatus)
                            PopupMenuItem<String>(
                              value: 'unfollow',
                              child: Row(
                                children: [
                                  const Icon(Iconsax.user_minus,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text('takibi_birak'.tr,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          if (status == 'friends')
                            PopupMenuItem<String>(
                              value: 'remove_friend',
                              child: Row(
                                children: [
                                  const Icon(Iconsax.user_remove,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text('arkadastan_cikar'.tr,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'mute',
                            child: Row(
                              children: [
                                Icon(
                                    isMutedStatus
                                        ? Iconsax.volume_high
                                        : Iconsax.volume_cross,
                                    color: Colors.white,
                                    size: 20),
                                const SizedBox(width: 10),
                                Text(
                                    isMutedStatus
                                        ? 'sesi_ac'.tr
                                        : 'sessize_al'.tr,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'block',
                            child: Row(
                              children: [
                                Icon(
                                    isBlockedStatus
                                        ? Iconsax.user_tick
                                        : Iconsax.user_minus,
                                    color: isBlockedStatus
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20),
                                const SizedBox(width: 10),
                                Text(
                                    isBlockedStatus
                                        ? 'engeli_kaldir'.tr
                                        : 'engelle'.tr,
                                    style: TextStyle(
                                        color: isBlockedStatus
                                            ? Colors.green
                                            : Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "@${userData['username'] ?? (userData['email'] ?? widget.gelenKullaniciEmail).split('@')[0]}",
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${userData['unicBalance'] ?? 0} Unic",
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
              _buildStatColumn(postCountVal.toString(), "gonderi".tr),
              _buildStatColumn(friendCount.toString(), "arkadaşlar".tr,
                  onTap: () {
                Get.to(() => ArkadaslarPage(
                    userId: userData['uid'] ?? widget.gelenKullaniciEmail));
              }),
              _buildStatColumn(
                  (userData['followerCount'] ?? 0).toString(), "takipci".tr,
                  onTap: () {
                Get.to(() => TakipcilerPage(
                    userId: userData['uid'] ?? widget.gelenKullaniciEmail));
              }),
              _buildStatColumn(
                  (userData['followingCount'] ?? 0).toString(), "takip".tr,
                  onTap: () {
                Get.to(() => TakipEttiklerimPage(
                    userId: userData['uid'] ?? widget.gelenKullaniciEmail));
              }),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              _socialService.getFriendshipStatus(
                  currentUserId, userData['uid'] ?? widget.gelenKullaniciEmail),
              _socialService.isFollowing(
                  currentUserId, userData['uid'] ?? widget.gelenKullaniciEmail),
            ]),
            builder: (context, snapshot) {
              final friendshipStatus =
                  snapshot.data != null ? snapshot.data![0].toString() : 'none';
              final isFollowingStatus =
                  snapshot.data != null ? snapshot.data![1] as bool : false;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (friendshipStatus == 'friends')
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: IconButton(
                        onPressed: () => Get.to(() => ChatScreen(
                            peerId:
                                userData['uid'] ?? widget.gelenKullaniciEmail)),
                        icon: const Icon(Iconsax.message,
                            color: Colors.cyanAccent, size: 28),
                        tooltip: 'mesaj_gonder'.tr,
                      ),
                    ),
                  if (friendshipStatus != 'friends')
                    _buildFriendshipButton(
                        friendshipStatus,
                        userData['uid'] ?? widget.gelenKullaniciEmail,
                        currentUserId),
                  if (friendshipStatus != 'friends') const SizedBox(width: 12),
                  if (!isFollowingStatus)
                    _buildFollowButton(
                        isFollowingStatus,
                        userData['uid'] ?? widget.gelenKullaniciEmail,
                        currentUserId),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper metodlar
  Widget _buildFollowButton(
      bool isFollowing, String otherUserId, String currentUserId) {
    return GestureDetector(
      onTap: () async {
        if (isFollowing) {
          await _socialService.unfollowUser(currentUserId, otherUserId);
          Get.snackbar('bilgi'.tr, 'takibi_biraktin'.tr);
        } else {
          await _socialService.followUser(currentUserId, otherUserId);
          Get.snackbar('bilgi'.tr, 'takip_etmeye_basladin'.tr);
        }
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isFollowing ? Colors.transparent : Colors.cyanAccent,
          borderRadius: BorderRadius.circular(20),
          border: isFollowing
              ? Border.all(color: Colors.cyanAccent.withOpacity(0.5))
              : null,
        ),
        child: Text(
          isFollowing ? "takibi_birak".tr : "takip_et".tr,
          style: TextStyle(
            color: isFollowing ? Colors.cyanAccent : Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFriendshipButton(
      String status, String otherUserId, String currentUserId) {
    String text = "arkadas_ekle".tr;
    Color bgColor = Colors.grey[900]!;
    Color textColor = Colors.white;
    VoidCallback? onTap;

    if (status == 'friends') {
      return const SizedBox.shrink();
    } else if (status == 'request_sent') {
      text = "istek_gonderildi".tr;
      bgColor = Colors.orange.withOpacity(0.2);
      textColor = Colors.orange;
      onTap =
          () => _socialService.declineFriendRequest(otherUserId, currentUserId);
    } else if (status == 'request_received') {
      text = "istegi_onayla".tr;
      bgColor = Colors.cyanAccent.withOpacity(0.2);
      textColor = Colors.cyanAccent;
      onTap =
          () => _socialService.acceptFriendRequest(currentUserId, otherUserId);
    } else {
      text = "arkadas_ekle".tr;
      onTap =
          () => _socialService.sendFriendRequest(currentUserId, otherUserId);
    }

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withOpacity(0.5)),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showRemoveFriendDialog(String friendId, String currentUserId) {
    Get.defaultDialog(
      title: "arkadasi_cikar_baslik".tr,
      middleText: "arkadasi_cikar_icerik".tr,
      backgroundColor: Colors.grey[900],
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: "cikar".tr,
      textCancel: "vazgec".tr,
      onConfirm: () {
        _socialService.removeFriend(currentUserId, friendId);
        Get.back();
        setState(() {});
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

  Widget _buildPostList(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return Center(
        child: Text("henuz_bir_sey_yok".tr,
            style: const TextStyle(color: Colors.grey)),
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
      return Center(
        child: Text("medya_yok".tr, style: const TextStyle(color: Colors.grey)),
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
