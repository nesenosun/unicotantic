import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unicotantic/core/services/bildirimler.dart';
import 'package:unicotantic/core/utils/buildDefaultTextStyle.dart';
import 'package:unicotantic/features/auth/splash.dart';
import 'package:unicotantic/features/chat/chat_list_page.dart';
import 'package:unicotantic/features/feed/akis.dart';
import 'package:unicotantic/features/profile/arkadaslar.dart';
import 'package:unicotantic/features/profile/ayarlar.dart';
import 'package:unicotantic/features/profile/engellenenler.dart';
import 'package:unicotantic/features/profile/kullanici_profili.dart';
import 'package:unicotantic/features/profile/sessize_alinanlar.dart';
import 'package:unicotantic/features/profile/takip_ettiklerim.dart';

class Site extends StatefulWidget {
  const Site({Key? key}) : super(key: key);

  @override
  State<Site> createState() => _SiteState();
}

class _SiteState extends State<Site> {
  final User kullanici = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const Splash());
    } catch (e) {
      Get.snackbar('Hata', 'Çıkış yapılamadı.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Sabit genişlik
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('users').doc(kullanici.uid).snapshots(),
                builder: (context, userSnapshot) {
                  int notificationCount = 0;
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    notificationCount = userData['notificationCount'] ?? 0;
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        _buildDrawerTile(
                          title: 'AKIŞ',
                          icon: Iconsax.home_2,
                          onTap: () => Get.to(() => const Akis()),
                        ),
                        _buildDrawerTile(
                          title: 'Profilim',
                          icon: Iconsax.user,
                          onTap: () => Get.to(() => const KullaniciProfili()),
                        ),
                        // Mesajlar Butonu (Yeni)
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('chats')
                              .where('participants', arrayContains: kullanici.uid)
                              .snapshots(),
                          builder: (context, chatSnapshot) {
                            bool hasUnread = false;
                            if (chatSnapshot.hasData) {
                              for (var doc in chatSnapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                if (data['lastSenderId'] != kullanici.uid && data['isRead'] == false) {
                                  hasUnread = true;
                                  break;
                                }
                              }
                            }
                            return _buildDrawerTile(
                              title: 'Mesajlar',
                              icon: Iconsax.message,
                              color: hasUnread ? Colors.greenAccent : Colors.white70,
                              onTap: () => Get.to(() => const ChatListPage()),
                            );
                          },
                        ),
                        _buildDrawerTile(
                          title: 'Bildirimler',
                          icon: Iconsax.notification,
                          badgeCount: notificationCount,
                          onTap: () => Get.to(() => const Bildirimler()),
                        ),
                        _buildDrawerTile(
                          title: 'Arkadaşlar',
                          icon: Iconsax.people,
                          onTap: () => Get.to(() => const ArkadaslarPage()),
                        ),
                        _buildDrawerTile(
                          title: 'Takip Ettiklerim',
                          icon: Iconsax.people,
                          onTap: () => Get.to(() => const TakipEttiklerimPage()),
                        ),
                        _buildDrawerTile(
                          title: 'Sessize Alınanlar',
                          icon: Iconsax.volume_cross,
                          onTap: () => Get.to(() => const SessizeAlinanlarPage()),
                        ),
                        _buildDrawerTile(
                          title: 'Engellenenler',
                          icon: Iconsax.user_minus,
                          onTap: () => Get.to(() => const EngellenenlerPage()),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Colors.white10),
                        ),
                        _buildDrawerTile(
                          title: 'Ayarlar',
                          icon: Iconsax.setting_2,
                          onTap: () => Get.to(() => const Ayarlar()),
                        ),
                        _buildDrawerTile(
                          title: 'Oturumu Kapat',
                          icon: Iconsax.logout,
                          color: Colors.redAccent,
                          onTap: _signOut,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(kullanici.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: Center(child: buildDefaultTextStyle()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String? photoUrl = data['photoUrl'] ?? data['profilresmilinki'];
        final String name = data['name'] ?? data['displayName'] ?? 'Kullanıcı';
        final String email = data['email'] ?? '';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyanAccent.withOpacity(0.1),
                Colors.black,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ClipOval(
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? Image.network(photoUrl, fit: BoxFit.cover)
                      : const Icon(Iconsax.user, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white70,
    int badgeCount = 0,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          Text(
            'v1.0 @nesenosun',
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
