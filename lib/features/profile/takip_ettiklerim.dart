import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/services/social_service.dart';
import '../../core/utils/profilResmiGetir.dart';
import 'site.dart';
import 'ziyaretci.dart';

class TakipEttiklerimPage extends StatefulWidget {
  const TakipEttiklerimPage({super.key});

  @override
  State<TakipEttiklerimPage> createState() => _TakipEttiklerimPageState();
}

class _TakipEttiklerimPageState extends State<TakipEttiklerimPage> {
  User? get currentUser => FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SocialService _socialService = SocialService();

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        Widget content = Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Takip Ettiklerim', style: TextStyle(color: Colors.white, fontSize: 18)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('following').doc(currentUser!.uid).collection('userFollowing').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return const Center(child: Text('Hata oluştu', style: TextStyle(color: Colors.white)));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.people, size: 64, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      Text('Henüz kimseyi takip etmiyorsun', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  String followedUserId = doc.id;

                  return ListTile(
                    onTap: () => Get.to(() => Ziyaretci(gelenKullaniciEmail: followedUserId)),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: profilResmiGetir(followedUserId),
                      ),
                    ),
                    title: profilIsmiGetir(followedUserId),
                    subtitle: const Text('Takip ediliyor', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Iconsax.user_minus, color: Colors.redAccent),
                      onPressed: () async {
                        await _socialService.unfollowUser(currentUser!.uid, followedUserId);
                        Get.snackbar('Bilgi', 'Takipten çıkarıldı');
                      },
                    ),
                  );
                },
              );
            },
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
                        left: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
                        right: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
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
