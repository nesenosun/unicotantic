import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/services/social_service.dart';
import '../../core/utils/profilResmiGetir.dart';
import 'site.dart';
import 'ziyaretci.dart';

class SessizeAlinanlarPage extends StatefulWidget {
  const SessizeAlinanlarPage({super.key});

  @override
  State<SessizeAlinanlarPage> createState() => _SessizeAlinanlarPageState();
}

class _SessizeAlinanlarPageState extends State<SessizeAlinanlarPage> {
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
            title: const Text('Sessize Alınanlar', style: TextStyle(color: Colors.white, fontSize: 18)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return const Center(child: Text('Hata oluştu', style: TextStyle(color: Colors.white)));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Veri bulunamadı', style: TextStyle(color: Colors.white)));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final List mutedUsers = data['mutedUsers'] ?? [];

              if (mutedUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.volume_low, size: 64, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      Text('Sessize alınan kimse yok', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: mutedUsers.length,
                itemBuilder: (context, index) {
                  String mutedUserId = mutedUsers[index];

                  return ListTile(
                    onTap: () => Get.to(() => Ziyaretci(gelenKullaniciEmail: mutedUserId)),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: profilResmiGetir(mutedUserId),
                      ),
                    ),
                    title: profilIsmiGetir(mutedUserId),
                    subtitle: const Text('Sessize alındı', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: TextButton(
                      onPressed: () async {
                        await _socialService.unmuteUser(currentUser!.uid, mutedUserId);
                        Get.snackbar('Bilgi', 'Kullanıcının sesi açıldı.');
                      },
                      child: const Text('Sesi Aç', style: TextStyle(color: Colors.cyanAccent)),
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
