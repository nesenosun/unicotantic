import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';
import 'package:unicotantic/profil/BenDrawer.dart';

class AdminSayfasi extends StatefulWidget {
  const AdminSayfasi({super.key});

  @override
  State<AdminSayfasi> createState() => _AdminSayfasiState();
}

class _AdminSayfasiState extends State<AdminSayfasi> {
  bool isDeleting = false;
  final String adminEmail = 'nesenosun@gmail.com';

  Future<void> deleteAllPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != adminEmail) {
      Get.snackbar('Hata', 'Bu işlem için yetkiniz yok.');
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Delete top-level collections
      await _deleteCollection(firestore.collection('postlar'));
      await _deleteCollection(firestore.collection('postaYorum'));
      await _deleteCollection(firestore.collection('duzenlenmisYorum'));
      await _deleteCollection(firestore.collection('yorumaYorum'));

      // 2. Clear user-specific data
      final users = await firestore.collection('Kullanicilar').get();
      WriteBatch batch = firestore.batch();
      int operationCount = 0;

      for (var userDoc in users.docs) {
        // Reset post count
        batch.update(userDoc.reference, {'postSayisi': 0});
        operationCount++;

        // Clear subcollection 'postlar'
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
        isDeleting = false;
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
      drawer: const BenDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, color: Colors.cyan, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Admin Paneli',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Hoş geldin, $adminEmail', style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 40),
            if (isDeleting)
              const Column(
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 20),
                  Text('Veriler siliniyor, lütfen bekleyin...', style: TextStyle(color: Colors.white70)),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'DİKKAT!',
                    middleText: 'Tüm postlar, yorumlar ve sayaçlar kalıcı olarak silinecek. Bu işlem geri alınamaz.',
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
                icon: const Icon(Icons.delete_forever),
                label: const Text('TÜM POSTLARI SİL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
