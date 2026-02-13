import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unicotantic/core/services/bildirimler.dart';
import 'package:unicotantic/features/chat/chat_list_page.dart';
import 'package:unicotantic/features/profile/kullanici_profili.dart';
import 'package:unicotantic/features/search/search_page.dart';

import '../../../features/feed/akis.dart';

enum VoiceBottomBarTab {
  home,
  search,
  chat,
  bildirim,
  profile,
  none,
}

class VoiceBottomBar extends StatelessWidget {
  final VoiceBottomBarTab currentTab;

  const VoiceBottomBar({
    super.key,
    this.currentTab = VoiceBottomBarTab.none,
  });

  void _navigateTo(VoiceBottomBarTab tab) {
    if (tab == currentTab) return;

    if (tab == VoiceBottomBarTab.home) {
      Get.offAll(() => const Akis(), transition: Transition.fadeIn);
    } else if (tab == VoiceBottomBarTab.search) {
      Get.to(() => const SearchPage(), transition: Transition.fadeIn);
    } else if (tab == VoiceBottomBarTab.chat) {
      Get.to(() => const ChatListPage(), transition: Transition.fadeIn);
    } else if (tab == VoiceBottomBarTab.bildirim) {
      Get.to(() => const Bildirimler(), transition: Transition.fadeIn);
    } else if (tab == VoiceBottomBarTab.profile) {
      Get.to(() => const KullaniciProfili(), transition: Transition.fadeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Anasayfa
              IconButton(
                onPressed: () => _navigateTo(VoiceBottomBarTab.home),
                icon: Icon(
                  Iconsax.home,
                  color: currentTab == VoiceBottomBarTab.home ? Colors.cyanAccent : Colors.grey,
                  size: 26,
                ),
              ),

              // 2. Arama (Search)
              IconButton(
                onPressed: () => _navigateTo(VoiceBottomBarTab.search),
                icon: Icon(
                  Iconsax.search_normal,
                  color: currentTab == VoiceBottomBarTab.search ? Colors.cyanAccent : Colors.grey,
                  size: 26,
                ),
              ),

              // 3. Mesajlar (Chat)
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('chats').where('participants', arrayContains: user.uid).snapshots(),
                builder: (context, snapshot) {
                  bool hasUnread = false;
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['lastSenderId'] != user.uid && data['isRead'] == false) {
                        hasUnread = true;
                        break;
                      }
                    }
                  }

                  return IconButton(
                    onPressed: () => _navigateTo(VoiceBottomBarTab.chat),
                    icon: Icon(
                      Iconsax.message,
                      color: currentTab == VoiceBottomBarTab.chat
                          ? Colors.cyanAccent
                          : (hasUnread ? Colors.greenAccent : Colors.grey),
                      size: 26,
                    ),
                  );
                },
              ),

              // 4. Bildirimler
              StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('users').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  int notificationCount = 0;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    notificationCount = (snapshot.data!.data() as Map<String, dynamic>)['notificationCount'] ?? 0;
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _navigateTo(VoiceBottomBarTab.bildirim),
                        icon: Icon(
                          Iconsax.notification,
                          color: currentTab == VoiceBottomBarTab.bildirim ? Colors.cyanAccent : Colors.grey,
                          size: 26,
                        ),
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 10,
                                minHeight: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // 5. Profil
              IconButton(
                onPressed: () => _navigateTo(VoiceBottomBarTab.profile),
                icon: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: currentTab == VoiceBottomBarTab.profile ? Colors.cyanAccent : Colors.transparent,
                          width: 2)),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(user.photoURL ?? ""),
                    backgroundColor: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
