import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Added for current user
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicotantic/core/services/like_service.dart';
import 'package:unicotantic/core/utils/videoPlayrFlick.dart';

import '../../features/feed/post_ayrintilari.dart';
import '../../features/profile/ziyaretci.dart';
import 'profilResmiGetir.dart';

final kullanici = FirebaseAuth.instance.currentUser!;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

// --- 1. Bölüm: Kullanıcı Bilgisi ve Menü ---
class PostHeader extends StatelessWidget {
  final String postID;
  final String authorID;
  final DateTime createdAt;
  final List<DocumentSnapshot> listOfDocumentSnap;
  final int index;

  const PostHeader({
    Key? key,
    required this.postID,
    required this.authorID,
    required this.createdAt,
    required this.listOfDocumentSnap,
    required this.index,
  }) : super(key: key);

  Future<void> _deletePost() async {
    Get.defaultDialog(
      title: "Gönderiyi Sil",
      middleText: "Bu gönderiyi silmek istediğinizden emin misiniz?",
      backgroundColor: Colors.grey[900],
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: "Sil",
      textCancel: "Vazgeç",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back(); // Dialogu kapat
        try {
          // 1. Medyayı sil (varsa)
          final data =
              listOfDocumentSnap[index].data() as Map<String, dynamic>?;
          final String? mediaUrl = data?['mediaUrl'];

          if (mediaUrl != null && mediaUrl != 'bos' && mediaUrl.isNotEmpty) {
            try {
              await FirebaseStorage.instance.refFromURL(mediaUrl).delete();
            } catch (e) {
              debugPrint("Storage silme hatası: $e");
            }
          }

          // 2. Firestore dokümanını sil
          await listOfDocumentSnap[index].reference.delete();

          Get.snackbar("Başarılı", "Gönderi silindi",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        } catch (e) {
          Get.snackbar(
            "Hata",
            "Silme işlemi başarısız: $e",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner =
        (kullanici.uid == authorID || kullanici.email == authorID);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sol Taraf: Avatar ve İsim
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Get.to(() => Ziyaretci(gelenKullaniciEmail: authorID)),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                      ),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: profilResmiGetir(authorID),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İsim (StreamBuilder) - Taşma kontrolü eklendi
                        SizedBox(
                          child: profilIsmiGetir(authorID),
                        ),
                        // Unic Bilgisi
                        profilUnicGetir(authorID),
                        // Tarih
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            "${createdAt.day}/${createdAt.month}/${createdAt.year}",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Sağ Taraf: Menü Butonu (Sadece Sahibi İçin)
            if (isOwner)
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.red),
                onPressed: _deletePost,
                tooltip: 'Seçenekler',
              ),
          ],
        ),
      ),
    );
  }
}

// --- 2. Bölüm: Metin İçeriği ---
class PostContentText extends StatelessWidget {
  final String content;

  const PostContentText({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Text(
        content,
        textAlign: TextAlign.start,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.normal,
          fontSize: 15,
          color: Colors.white70, // Okunabilirlik için biraz açıldı
        ),
      ),
    );
  }
}

// --- 3. Bölüm: Medya (Video / Fotoğraf) ---
class PostMedia extends StatefulWidget {
  final String videoUrl;
  final String photoUrl;

  const PostMedia({
    Key? key,
    required this.videoUrl,
    required this.photoUrl,
  }) : super(key: key);

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {
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
    // Eğer medya yoksa boş dön
    if ((widget.videoUrl.isEmpty || widget.videoUrl == 'bos') &&
        (widget.photoUrl.isEmpty || widget.photoUrl == 'bos')) {
      return const SizedBox.shrink();
    }

    final bool isVideo = widget.videoUrl.isNotEmpty && widget.videoUrl != 'bos';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: GestureDetector(
          onTap: () {
            Get.to(() => VideoFotoGosterSayfasi(
                  gelenVideolink: widget.videoUrl,
                  gelenFotolink: widget.photoUrl,
                ));
          },
          child: isVideo ? _buildVideoThumbnail() : _buildPhoto(),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Arkaplan resmi (Thumbnail)
        AspectRatio(
          aspectRatio: 16 / 9, // Varsayılan video oranı
          child: Image.network(
            widget.photoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.black),
          ),
        ),
        // Play İkonu
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _buildPhoto() {
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(0),
      minScale: 1.0,
      maxScale: 2.5,
      onInteractionEnd: (details) {
        _resetZoom();
      },
      child: Image.network(
        widget.photoUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey[900],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[800],
            child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white54)),
          );
        },
      ),
    );
  }
}

// --- 4. Bölüm: Etkileşim Barı (Like, Dislike, Comment) ---
class DorduncuBolumAltBar extends StatefulWidget {
  final String postID;
  final String authorID;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;

  const DorduncuBolumAltBar({
    Key? key,
    required this.postID,
    required this.authorID,
    required this.likeCount,
    required this.dislikeCount,
    required this.commentCount,
  }) : super(key: key);

  @override
  State<DorduncuBolumAltBar> createState() => _DorduncuBolumAltBarState();
}

class _DorduncuBolumAltBarState extends State<DorduncuBolumAltBar> {
  late int _likeCount;
  late int _dislikeCount;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isLoading = false; // Çift tıklamayı önlemek için

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likeCount;
    _dislikeCount = widget.dislikeCount;
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    try {
      final status = await LikeService.getLikeStatus(widget.postID);
      if (mounted) {
        setState(() {
          _isLiked = status['isLiked'] ?? false;
          _isDisliked = status['isDisliked'] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Like durumu çekilemedi: $e");
    }
  }

  Future<void> _handleLike() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final bool oldDisliked = _isDisliked;
      final newLikeState = await LikeService.toggleLike(widget.postID);

      if (mounted) {
        setState(() {
          _isLiked = newLikeState;
          _likeCount += newLikeState ? 1 : -1;

          if (newLikeState && oldDisliked) {
            _isDisliked = false;
            _dislikeCount--;
          }
        });
      }
    } catch (e) {
      Get.snackbar("Hata", "Beğeni işlemi başarısız",
          backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDislike() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final bool oldLiked = _isLiked;
      final newDislikeState = await LikeService.toggleDislike(widget.postID);

      if (mounted) {
        setState(() {
          _isDisliked = newDislikeState;
          _dislikeCount += newDislikeState ? 1 : -1;

          if (newDislikeState && oldLiked) {
            _isLiked = false;
            _likeCount--;
          }
        });
      }
    } catch (e) {
      Get.snackbar("Hata", "Dislike işlemi başarısız",
          backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol Taraf: Beğeni Butonları
          Row(
            children: [
              _buildInteractionButton(
                icon: _isDisliked
                    ? CupertinoIcons.heart_slash_fill
                    : CupertinoIcons.heart_slash,
                count: _dislikeCount,
                color: _isDisliked ? Colors.red : Colors.white70,
                onTap: _handleDislike,
              ),
              const SizedBox(width: 20),
              _buildInteractionButton(
                icon:
                    _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                count: _likeCount,
                color: _isLiked ? Colors.cyanAccent : Colors.white70,
                onTap: _handleLike,
              ),
            ],
          ),
          // Sağ Taraf: Yorum Butonu
          _buildInteractionButton(
            icon: CupertinoIcons.chat_bubble_text,
            count: widget.commentCount,
            color: widget.commentCount > 0 ? Colors.blueAccent : Colors.white70,
            onTap: () => Get.to(() => PostAyrintilari(postID: widget.postID)),
            isEnd: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
    bool isEnd = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
