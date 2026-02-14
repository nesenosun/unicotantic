import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/services/social_service.dart';
import '../../features/profile/ziyaretci.dart';
import '../utils/profilResmiGetir.dart';

class ArkadaslikIstekleri extends StatefulWidget {
  const ArkadaslikIstekleri({super.key});

  @override
  State<ArkadaslikIstekleri> createState() => _ArkadaslikIstekleriState();
}

class _ArkadaslikIstekleriState extends State<ArkadaslikIstekleri> {
  User? get currentUser => FirebaseAuth.instance.currentUser;
  final SocialService _socialService = SocialService();

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Arkadaşlık İstekleri',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friendRequests')
            .where('receiverId', isEqualTo: currentUser?.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child:
                    Text('Hata oluştu', style: TextStyle(color: Colors.white)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.user_add, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text('Bekleyen istek yok',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String senderId = data['senderId'];

              return ListTile(
                leading: GestureDetector(
                  onTap: () =>
                      Get.to(() => Ziyaretci(gelenKullaniciEmail: senderId)),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[900],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: profilResmiGetir(senderId),
                    ),
                  ),
                ),
                title: InkWell(
                  onTap: () =>
                      Get.to(() => Ziyaretci(gelenKullaniciEmail: senderId)),
                  child: profilIsmiGetir(senderId),
                ),
                subtitle: const Text('Sana arkadaşlık isteği gönderdi',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {
                        final user = currentUser;
                        if (user != null) {
                          _socialService.acceptFriendRequest(
                              user.uid, senderId);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        final user = currentUser;
                        if (user != null) {
                          _socialService.declineFriendRequest(
                              user.uid, senderId);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
