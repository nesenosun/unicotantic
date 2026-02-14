import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PostOlusturPanel extends StatefulWidget {
  final String? parentID;
  final String? rootID;

  const PostOlusturPanel({Key? key, this.parentID, this.rootID})
      : super(key: key);

  @override
  State<PostOlusturPanel> createState() => _PostOlusturPanelState();
}

class _PostOlusturPanelState extends State<PostOlusturPanel> {
  User? get kullanici => FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _textController = TextEditingController();

  String? _mediaUrl;
  String? _mediaType;
  bool _isUploading = false;
  String? _statusText;

  // Medya yükleme fonksiyonu (Genel)
  Future<void> _uploadMedia(
      XFile pickedFile, String folder, String type) async {
    setState(() {
      _isUploading = true;
      _statusText = 'Medya yükleniyor...';
    });

    try {
      String fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${type == 'video' ? 'post.mp4' : 'post.jpg'}';
      Reference ref = FirebaseStorage.instance
          .ref()
          .child(folder)
          .child(kullanici?.email ?? 'unknown')
          .child(fileName);

      UploadTask task;
      if (kIsWeb) {
        task = ref.putData(await pickedFile.readAsBytes());
      } else {
        File file = File(pickedFile.path);
        int fileSizeInBytes = await file.length();
        double fileSizeInMb = fileSizeInBytes / (1024 * 1024);

        if (type == 'video') {
          if (fileSizeInMb > 30) {
            setState(() => _statusText = 'Video optimize ediliyor...');
            final compressVideo = await VideoCompress.compressVideo(
              pickedFile.path,
              quality: VideoQuality.LowQuality,
              includeAudio: true,
            );
            if (compressVideo != null && compressVideo.file != null) {
              file = compressVideo.file!;
            }
          } else {
            setState(() => _statusText = 'Video hazırlanıyor...');
          }
        } else if (type == 'image' && fileSizeInMb > 1) {
          setState(() => _statusText = 'Fotoğraf optimize ediliyor...');
          final String targetPath =
              '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: 50,
            format: CompressFormat.jpeg,
          );
          if (compressedFile != null) {
            file = File(compressedFile.path);
          }
        }
        task = ref.putFile(file);
      }

      final snapshot = await task;
      String url = await snapshot.ref.getDownloadURL();

      setState(() {
        _mediaUrl = url;
        _mediaType = type;
        _isUploading = false;
        _statusText = null;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusText = 'Hata: $e';
      });
      Get.snackbar('Hata', 'Yükleme başarısız oldu: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!kIsWeb) {
        final file = File(pickedFile.path);
        final fileSizeInBytes = await file.length();
        final fileSizeInMb = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMb > 10) {
          Get.snackbar(
            'Hata',
            'Fotoğraf boyutu 10 MB\'dan büyük olamaz. Mevcut boyut: ${fileSizeInMb.toStringAsFixed(1)} MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }
      await _uploadMedia(pickedFile, 'postFotoları', 'image');
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 120),
    );

    if (pickedFile != null) {
      if (!kIsWeb) {
        final file = File(pickedFile.path);
        final fileSizeInBytes = await file.length();
        final fileSizeInMb = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMb > 50) {
          Get.snackbar(
            'Hata',
            'Video boyutu 50 MB\'dan büyük olamaz. Mevcut boyut: ${fileSizeInMb.toStringAsFixed(1)} MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Süre kontrolü (VideoCompress ile daha kesin sonuç alınabilir ama picker da kısıtlıyor)
        final info = await VideoCompress.getMediaInfo(pickedFile.path);
        if (info.duration != null && info.duration! > 120000) {
          // 120000 ms = 2 dk
          Get.snackbar(
            'Hata',
            'Video süresi 2 dakikadan uzun olamaz.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return;
        }
      }
      await _uploadMedia(pickedFile, 'postVideolari', 'video');
    }
  }

  Future<void> _submitPost() async {
    if (_textController.text.trim().isEmpty && _mediaUrl == null) {
      Get.snackbar('Hata', 'İçerik boş olamaz.');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final localKullanici = kullanici;
      if (localKullanici == null) return;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(localKullanici.uid).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(localKullanici.uid).set({
          'uid': localKullanici.uid,
          'username': localKullanici.email?.split('@')[0] ?? "user",
          'email': localKullanici.email,
          'photoUrl': localKullanici.photoURL ?? '',
          'bio': '',
          'followerCount': 0,
          'followingCount': 0,
          'postCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'unicBalance': 100,
        });
        userDoc =
            await _firestore.collection('users').doc(localKullanici.uid).get();
      }

      int unicBalance =
          (userDoc.data() as Map<String, dynamic>?)?['unicBalance'] ?? 0;

      if (unicBalance <= 0) {
        Get.snackbar('Hata', 'Yetersiz Unic puanı.');
        if (mounted) setState(() => _isUploading = false);
        return;
      }

      await _firestore.collection('users').doc(localKullanici.uid).update({
        'unicBalance': FieldValue.increment(-1),
        'postCount': FieldValue.increment(1),
      });

      String postID = _firestore.collection('posts').doc().id;

      Map<String, dynamic> postData = {
        'postID': postID,
        'authorID': localKullanici.uid,
        'email': localKullanici.email,
        'text': _textController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'dislikeCount': 0,
        'commentCount': 0,
        'mediaUrl': _mediaUrl,
        'mediaType': _mediaType ?? 'text',
        'parentID': widget.parentID,
        'rootID': widget.rootID ?? postID,
      };

      await _firestore.collection('posts').doc(postID).set(postData);

      Get.back();
      Get.snackbar('Başarılı', 'Postunuz paylaşıldı.');
    } catch (e) {
      debugPrint('Post Paylaşma Hatası Detayı: $e');
      if (mounted) setState(() => _isUploading = false);
      Get.snackbar('Hata', 'Paylaşım sırasında bir teknik sorun oluştu: $e',
          duration: const Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kullanici == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20),
      decoration: const BoxDecoration(
          color: Color(0xFF15202B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back()),
                ElevatedButton(
                  onPressed: _isUploading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Postla',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (_statusText != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_statusText!,
                    style: const TextStyle(color: Colors.cyan, fontSize: 12)),
              ),
            TextField(
              controller: _textController,
              autofocus: true,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  hintText: 'Neler oluyor?',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none),
            ),
            if (_mediaUrl != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _mediaType == 'image'
                        ? Image.network(_mediaUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover)
                        : Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[800],
                            child: const Center(
                                child: Icon(Icons.videocam,
                                    color: Colors.white, size: 50))),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() {
                                _mediaUrl = null;
                                _mediaType = null;
                              })),
                    ),
                  ),
                ],
              ),
            const Divider(color: Colors.grey),
            Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.image_outlined, color: Colors.cyan),
                    onPressed: _isUploading ? null : _pickImage),
                IconButton(
                    icon:
                        const Icon(Icons.videocam_outlined, color: Colors.cyan),
                    onPressed: _isUploading ? null : _pickVideo),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
