import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/services/social_service.dart';
import '../../core/utils/profilResmiGetir.dart';
import 'site.dart';
import 'ziyaretci.dart';

class ArkadaslarPage extends StatefulWidget {
  final String? userId;
  const ArkadaslarPage({super.key, this.userId});

  @override
  State<ArkadaslarPage> createState() => _ArkadaslarPageState();
}

class _ArkadaslarPageState extends State<ArkadaslarPage> {
  User? get currentUser => FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SocialService _socialService = SocialService();
  String? get targetUid => widget.userId ?? currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body:
            Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        Widget content = Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
                widget.userId == null
                    ? 'arkadaslar_baslik'.tr
                    : 'arkadaslari_baslik'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 18)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: FutureBuilder<String>(
            future: _socialService.getFriendshipStatus(
                currentUser!.uid, targetUid!),
            builder: (context, statusSnapshot) {
              bool isFriend = statusSnapshot.data == 'friends';
              bool isMe =
                  widget.userId == null || widget.userId == currentUser!.uid;

              if (!isMe && !isFriend) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.lock, size: 64, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      Text('liste_gizli'.tr,
                          style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('friends')
                    .doc(targetUid)
                    .collection('userFriends')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return const Center(
                        child: Text('Hata oluştu',
                            style: TextStyle(color: Colors.white)));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.cyanAccent));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.user, size: 64, color: Colors.grey[700]),
                          const SizedBox(height: 16),
                          Text('arkadas_yok'.tr,
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
                      String friendId = data['friendId'];

                      return ListTile(
                        onTap: () => Get.to(
                            () => Ziyaretci(gelenKullaniciEmail: friendId)),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[900],
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: profilResmiGetir(friendId),
                          ),
                        ),
                        title: profilIsmiGetir(friendId),
                        subtitle: Text('arkadas_alt'.tr,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                        trailing:
                            const Icon(Icons.chevron_right, color: Colors.grey),
                      );
                    },
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
