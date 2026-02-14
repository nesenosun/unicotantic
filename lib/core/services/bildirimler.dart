import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'arkadaslik_istekleri.dart';

import '../../features/feed/post_ayrintilari.dart';
import '../../core/voice/widgets/voice_bottom_bar.dart';
import '../../features/profile/site.dart';
import '../utils/profilResmiGetir.dart';

class Bildirimler extends StatefulWidget {
  const Bildirimler({super.key});

  @override
  State<Bildirimler> createState() => _BildirimlerState();
}

class _BildirimlerState extends State<Bildirimler> {
  User? get user => FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _resetNotificationCount();
  }

  Future<void> _resetNotificationCount() async {
    final localUser = user;
    if (localUser != null) {
      await _firestore.collection('users').doc(localUser.uid).update({'notificationCount': 0});
    }
  }

  @override
  Widget build(BuildContext context) {
    final localUser = user;
    if (localUser == null) {
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
            title: const Text('Bildirimler', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          bottomNavigationBar: isDesktop ? null : const VoiceBottomBar(currentTab: VoiceBottomBarTab.bildirim),
          body: Column(
            children: [
              // Arkadaşlık İstekleri Butonu
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('friendRequests')
                    .where('receiverId', isEqualTo: localUser.uid)
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  int requestCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return ListTile(
                    onTap: () => Get.to(() => const ArkadaslikIstekleri()),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.user_add, color: Colors.cyanAccent, size: 24),
                    ),
                    title: const Text('Arkadaşlık İstekleri',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (requestCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                            child: Text(requestCount.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  );
                },
              ),
              const Divider(color: Colors.grey, height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('firebasedenofication')
                      .doc(localUser.uid)
                      .collection('notifications')
                      .orderBy('timestamp', descending: true)
                      .limit(50)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Bir hata oluştu', style: TextStyle(color: Colors.white)));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.notification, size: 64, color: Colors.grey[700]),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz bildiriminiz yok',
                              style: TextStyle(color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (context, index) => Divider(color: Colors.grey[900], height: 1),
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        var data = doc.data() as Map<String, dynamic>;
                        return _buildNotificationItem(doc.id, data);
                      },
                    );
                  },
                ),
              ),
            ],
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

  Widget _buildNotificationItem(String docId, Map<String, dynamic> data) {
    String type = data['type'] ?? 'info';
    String senderId = data['fromId'] ?? data['senderId'] ?? '';
    String postID = data['postId'] ?? '';
    String? commentId = data['commentId'];
    Timestamp? timestamp = data['timestamp'] as Timestamp?;
    bool isRead = data['isRead'] ?? false;

    IconData icon;
    Color iconColor;
    String actionText;

    if (type == 'like') {
      icon = Iconsax.heart5;
      iconColor = Colors.red;
      actionText = 'gönderini beğendi';
    } else if (type == 'comment' || type == 'yorum') {
      icon = Iconsax.message_text5;
      iconColor = Colors.cyanAccent;
      actionText = 'gönderine yorum yaptı';
    } else if (type == 'follow' || type == 'takip') {
      icon = Iconsax.user_add;
      iconColor = Colors.green;
      actionText = 'seni takip etmeye başladı';
    } else if (type == 'arkadas_istek') {
      icon = Iconsax.user_add;
      iconColor = Colors.cyanAccent;
      actionText = 'sana arkadaşlık isteği gönderdi';
    } else if (type == 'arkadas_onay') {
      icon = Iconsax.user_tick;
      iconColor = Colors.green;
      actionText = 'arkadaşlık isteğini kabul etti';
    } else {
      icon = Iconsax.info_circle;
      iconColor = Colors.white70;
      actionText = 'sana bir bildirim gönderdi';
    }

    return ListTile(
      onTap: () async {
        if (!isRead) {
          await _firestore
              .collection('firebasedenofication')
              .doc(user?.uid)
              .collection('notifications')
              .doc(docId)
              .update({'isRead': true});
        }
        if (postID.isNotEmpty) {
          String targetPostId = (commentId != null && (type == 'comment' || type == 'yorum')) ? commentId : postID;
          Get.to(() => PostAyrintilari(postID: targetPostId));
        } else if (type == 'arkadas_istek') {
          Get.to(() => const ArkadaslikIstekleri());
        }
      },
      tileColor: isRead ? Colors.black : Colors.cyanAccent.withOpacity(0.05),
      leading: Stack(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: senderId.isNotEmpty ? profilResmiGetir(senderId) : const Icon(Icons.person, color: Colors.white),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
          ),
        ],
      ),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 14),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: senderId.isNotEmpty
                  ? profilIsmiGetir(senderId)
                  : const Text('Bir kullanıcı', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const TextSpan(text: ' '),
            TextSpan(text: actionText),
          ],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['content'] != null)
            Text(
              data['content'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          const SizedBox(height: 4),
          Text(
            timestamp != null ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate()) : '',
            style: TextStyle(color: Colors.grey[700], fontSize: 11),
          ),
        ],
      ),
      trailing: !isRead
          ? Container(
              width: 8, height: 8, decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle))
          : null,
    );
  }
}
