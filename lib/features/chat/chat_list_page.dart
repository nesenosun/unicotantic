import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../core/utils/encryption_service.dart';
import '../../core/utils/profilResmiGetir.dart';
import '../../core/voice/widgets/voice_bottom_bar.dart';
import '../profile/site.dart';
import 'chat_screen.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        Widget content = DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: const Text('Mesajlar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              bottom: const TabBar(
                indicatorColor: Colors.cyanAccent,
                labelColor: Colors.cyanAccent,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Sohbetler'),
                  Tab(text: 'Arkadaşlar'),
                ],
              ),
            ),
            bottomNavigationBar: isDesktop ? null : const VoiceBottomBar(currentTab: VoiceBottomBarTab.chat),
            body: const TabBarView(
              children: [
                ActiveChatsList(),
                FriendsToChatList(),
              ],
            ),
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

class ActiveChatsList extends StatelessWidget {
  const ActiveChatsList({super.key});

  Future<void> _hideChatForMe(String chatId, String currentUserId) async {
    bool confirm = await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Sohbeti Sil', style: TextStyle(color: Colors.white)),
            content: const Text(
                'Bu sohbet listenizden kaldırılacaktır. Diğer kullanıcı mesajları görmeye devam edecektir. Emin misiniz?',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('Vazgeç')),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'hiddenFor': FieldValue.arrayUnion([currentUserId])
      });
      Get.snackbar('Bilgi', 'Sohbet listenizden kaldırıldı');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastTimestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        final allChats = snapshot.data!.docs;
        final chats = allChats.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final List hiddenFor = data['hiddenFor'] ?? [];
          return !hiddenFor.contains(currentUserId);
        }).toList();

        if (chats.isEmpty) {
          return const Center(
            child: Text('Henüz mesajın yok.', style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final data = chats[index].data() as Map<String, dynamic>;
            final List participants = data['participants'] ?? [];
            final String peerId = participants.firstWhere((id) => id != currentUserId, orElse: () => "");

            if (peerId.isEmpty) return const SizedBox.shrink();

            final Timestamp? timestamp = data['lastTimestamp'] as Timestamp?;
            final String time = timestamp != null ? DateFormat('HH:mm').format(timestamp.toDate()) : "";

            final String lastMsg = EncryptionService.decrypt(data['lastMessage'] ?? '');

            return ListTile(
              onTap: () => Get.to(() => ChatScreen(peerId: peerId)),
              leading: CircleAvatar(
                backgroundColor: Colors.grey[900],
                radius: 25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: profilResmiGetir(peerId),
                ),
              ),
              title: Row(
                children: [
                  Expanded(child: profilIsmiGetir(peerId)),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              subtitle: Text(
                lastMsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                icon: const Icon(Iconsax.trash, color: Colors.white24, size: 20),
                onPressed: () => _hideChatForMe(chats[index].id, currentUserId),
              ),
            );
          },
        );
      },
    );
  }
}

class FriendsToChatList extends StatelessWidget {
  const FriendsToChatList({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friends')
          .doc(currentUserId)
          .collection('userFriends')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        final friends = snapshot.data!.docs;

        if (friends.isEmpty) {
          return const Center(
            child: Text('Mesajlaşmak için önce arkadaş ekle.', style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final data = friends[index].data() as Map<String, dynamic>;
            final String friendId = data['friendId'];

            return ListTile(
              onTap: () => Get.to(() => ChatScreen(peerId: friendId)),
              leading: CircleAvatar(
                backgroundColor: Colors.grey[900],
                radius: 25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: profilResmiGetir(friendId),
                ),
              ),
              title: profilIsmiGetir(friendId),
              subtitle: const Text('Yeni mesaj gönder', style: TextStyle(color: Colors.cyanAccent, fontSize: 12)),
              trailing: const Icon(Iconsax.message, color: Colors.cyanAccent, size: 20),
            );
          },
        );
      },
    );
  }
}
