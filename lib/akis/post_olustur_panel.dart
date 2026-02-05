import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

class PostOlusturPanel extends StatefulWidget {
  final String? parentID;
  final String? rootID;

  const PostOlusturPanel({Key? key, this.parentID, this.rootID})
      : super(key: key);

  @override
  State<PostOlusturPanel> createState() => _PostOlusturPanelState();
}

class _PostOlusturPanelState extends State<PostOlusturPanel> {
  final kullanici = FirebaseAuth.instance.currentUser!;
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
          .child(kullanici.email!)
          .child(fileName);

      UploadTask task;
      if (kIsWeb) {
        task = ref.putData(await pickedFile.readAsBytes());
      } else {
        File file = File(pickedFile.path);
        // Video ise sıkıştırma dene (sadece mobile)
        if (type == 'video') {
          setState(() => _statusText = 'Video sıkıştırılıyor...');
          final compressVideo = await VideoCompress.compressVideo(
            pickedFile.path,
            quality: VideoQuality.LowQuality,
            includeAudio: true,
          );
          if (compressVideo != null && compressVideo.file != null) {
            file = compressVideo.file!;
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
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      await _uploadMedia(pickedFile, 'postFotoları',
          'image'); // Orijinal klasör adınız 'postFotoları' olabilir
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
    if (pickedFile != null) {
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
      // Unic Kontrolü ve Otomatik Kayıt Giderme
      DocumentSnapshot userDoc = await _firestore
          .collection('Kullanicilar')
          .doc(kullanici.email)
          .get();

      if (!userDoc.exists) {
        // Eğer kullanıcı kaydı yoksa (Google girişi hatası vb.), otomatik oluştur
        debugPrint(
            'Kullanıcı kaydı bulunamadı, otomatik oluşturuluyor: ${kullanici.email}');
        await _firestore.collection('Kullanicilar').doc(kullanici.email).set({
          'email': kullanici.email,
          'isim': kullanici.displayName ?? kullanici.email?.split('@')[0],
          'id': kullanici.uid,
          'uid': kullanici.uid,
          'kayit tarihi': FieldValue.serverTimestamp(),
          'unic': 100,
          'postSayisi': 0,
          'arkadaslar': [],
          'engelledim': [],
          'engelleyenler': [],
          'begen': [],
          'begenMe': [],
          'profilresmilinki': kullanici.photoURL ?? '',
          'profilGizli': false,
          'hakkinda': 'Merhaba! Ben de buradayım.',
        });
        // Dokümanı tekrar çek
        userDoc = await _firestore
            .collection('Kullanicilar')
            .doc(kullanici.email)
            .get();
      }

      int unic = ((userDoc.data() as Map<String, dynamic>?)?['unic'] as num?)
              ?.toInt() ??
          0;

      if (unic <= 0) {
        Get.snackbar('Hata',
            'Yetersiz Unic puanı. Paylaşım yapmak için en az 1 Unic puanınız olmalı.');
        if (mounted) setState(() => _isUploading = false);
        return;
      }

      await _firestore.collection('Kullanicilar').doc(kullanici.email).update({
        'unic': FieldValue.increment(-1),
      });

      String postID = _firestore.collection('postlar').doc().id;

      Map<String, dynamic> postData = {
        'postID': postID,
        'authorID': kullanici.uid,
        'email': kullanici.email,
        'text': _textController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'yorumSayisi': 0,
        'rootId': widget.rootID ?? postID,
        'parentID': widget.parentID,
        'childID': widget.parentID,
        'mediaType': _mediaType ?? 'text',
        'mediaUrl': _mediaUrl,
        'like': 0,
        'dislike': 0,
      };

      await _firestore.collection('postlar').doc(postID).set(postData);

      // İşlem başarılı olduktan sonra ekranı kapat
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
