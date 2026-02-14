import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/features/feed/doluAkisAppBar.dart';
import 'package:unicotantic/features/profile/site.dart';

class AdminSayfasi extends StatefulWidget {
  const AdminSayfasi({super.key});

  @override
  State<AdminSayfasi> createState() => _AdminSayfasiState();
}

class _AdminSayfasiState extends State<AdminSayfasi> {
  bool isProcessing = false;
  String statusMessage = "";
  final String adminEmail = 'nesenosun@gmail.com';

  Future<void> deleteAllPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != adminEmail) {
      Get.snackbar('Hata', 'Bu işlem için yetkiniz yok.');
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = "Veriler siliniyor...";
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Storage Temizliği (Toplu silme öncesi)
      setState(() => statusMessage = "Medya dosyaları temizleniyor...");
      final storage = FirebaseStorage.instance;
      List<String> folders = ['postFotoları', 'postVideolari'];
      for (String folder in folders) {
        final ListResult result = await storage.ref(folder).listAll();
        for (Reference subFolder in result.prefixes) {
          final subResult = await subFolder.listAll();
          for (Reference file in subResult.items) {
            await file.delete();
          }
        }
        for (Reference file in result.items) {
          await file.delete();
        }
      }

      // 2. Firestore silme işlemleri
      setState(() => statusMessage = "Veritabanı temizleniyor...");
      await _deleteCollection(firestore.collection('postlar'));
      await _deleteCollection(firestore.collection('postaYorum'));
      await _deleteCollection(firestore.collection('duzenlenmisYorum'));
      await _deleteCollection(firestore.collection('yorumaYorum'));

      final users = await firestore.collection('users').get();
      WriteBatch batch = firestore.batch();
      int operationCount = 0;

      for (var userDoc in users.docs) {
        batch.update(userDoc.reference, {'postSayisi': 0});
        operationCount++;

        final userPosts = await userDoc.reference.collection('postlar').get();
        for (var postDoc in userPosts.docs) {
          batch.delete(postDoc.reference);
          operationCount++;

          if (operationCount >= 400) {
            await batch.commit();
            batch = firestore.batch();
            operationCount = 0;
          }
        }

        if (operationCount >= 400) {
          await batch.commit();
          batch = firestore.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      Get.snackbar('Başarılı', 'Tüm postlar ve ilgili veriler silindi.');
    } catch (e) {
      Get.snackbar('Hata', 'İşlem sırasında bir hata oluştu: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> cleanupStorage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != adminEmail) {
      Get.snackbar('Hata', 'Bu işlem için yetkiniz yok.');
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = "Depolama taranıyor, bu işlem zaman alabilir...";
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;

      // 1. Collect all valid URLs from Firestore
      Set<String> activeUrls = {};

      // From posts
      final postDocs = await firestore.collection('posts').get();
      for (var doc in postDocs.docs) {
        final data = doc.data();
        if (data['mediaUrl'] != null &&
            data['mediaUrl'] != 'bos' &&
            data['mediaUrl'] != '') {
          activeUrls.add(data['mediaUrl']);
        }
      }

      // From users (profile photos)
      final userDocs = await firestore.collection('users').get();
      for (var doc in userDocs.docs) {
        final data = doc.data();
        if (data['photoUrl'] != null &&
            data['photoUrl'] != 'bos' &&
            data['photoUrl'] != '') {
          activeUrls.add(data['photoUrl']);
        }
      }

      setState(() => statusMessage = "${activeUrls.length} aktif medya bulundu. Storage taranıyor...");

      // 2. Scan Storage Folders
      List<String> folders = ['postFotoları', 'postVideolari', 'profilePhotos'];
      int deletedCount = 0;
      int checkedCount = 0;

      for (String folder in folders) {
        final ListResult folderResult = await storage.ref(folder).listAll();

        // Subfolders (typically by user id/email)
        for (Reference subFolder in folderResult.prefixes) {
          final ListResult subFolderResult = await subFolder.listAll();
          
          for (Reference fileRef in subFolderResult.items) {
            checkedCount++;
            final String url = await fileRef.getDownloadURL();
            
            // If URL is not in Firestore, it's an orphan
            if (!activeUrls.contains(url)) {
              await fileRef.delete();
              deletedCount++;
            }
            
            setState(() => statusMessage = "$folder taranıyor... Kontrol edilen: $checkedCount, Silinen: $deletedCount");
          }
        }

        // Direct files in folder (if any)
        for (Reference fileRef in folderResult.items) {
          checkedCount++;
          final String url = await fileRef.getDownloadURL();
          if (!activeUrls.contains(url)) {
            await fileRef.delete();
            deletedCount++;
          }
          setState(() => statusMessage = "$folder taranıyor... Kontrol edilen: $checkedCount, Silinen: $deletedCount");
        }
      }

      Get.snackbar('Başarılı', 'Temizlik tamamlandı. $deletedCount yetim dosya silindi.');
    } catch (e) {
      Get.snackbar('Hata', 'Temizlik sırasında hata: $e');
    } finally {
      setState(() {
        isProcessing = false;
        statusMessage = "";
      });
    }
  }

  Future<void> _deleteCollection(CollectionReference collection) async {
    final query = await collection.get();
    if (query.docs.isEmpty) return;

    final firestore = FirebaseFirestore.instance;
    WriteBatch batch = firestore.batch();
    int count = 0;

    for (var doc in query.docs) {
      batch.delete(doc.reference);
      count++;
      if (count >= 400) {
        await batch.commit();
        batch = firestore.batch();
        count = 0;
      }
    }

    if (count > 0) {
      await batch.commit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: akisAppBar(),
      drawer: Site(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings,
                  color: Colors.cyan, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Admin Paneli',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Hoş geldin, $adminEmail',
                  style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 40),
              if (isProcessing)
                Column(
                  children: [
                    const CircularProgressIndicator(color: Colors.cyanAccent),
                    const SizedBox(height: 20),
                    Text(statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildAdminButton(
                      label: 'YETİM MEDYALARI TEMİZLE',
                      icon: Icons.cleaning_services,
                      color: Colors.cyan.shade900,
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Storage Temizliği',
                          middleText: 'Bağlantısı kopmuş tüm fotoğraf ve videolar silinecek. Devam edilsin mi?',
                          textConfirm: 'TEMİZLE',
                          textCancel: 'İPTAL',
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            Get.back();
                            cleanupStorage();
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildAdminButton(
                      label: 'TÜM POSTLARI SİL',
                      icon: Icons.delete_forever,
                      color: Colors.red.shade900,
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'DİKKAT!',
                          middleText:
                              'Tüm postlar, yorumlar ve sayaçlar kalıcı olarak silinecek. Bu işlem geri alınamaz.',
                          textConfirm: 'EVET, HEPSİNİ SİL',
                          textCancel: 'İPTAL',
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red,
                          onConfirm: () {
                            Get.back();
                            deleteAllPosts();
                          },
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
      ),
    );
  }
}
