import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../core/utils/encryption_service.dart';
import '../../core/utils/profilResmiGetir.dart';
import '../profile/ziyaretci.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  const ChatScreen({super.key, required this.peerId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late String chatId;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    chatId = currentUserId.compareTo(widget.peerId) < 0
        ? '${currentUserId}_${widget.peerId}'
        : '${widget.peerId}_$currentUserId';
    _markAsRead();
    _messageController.addListener(() {
      setState(() {
        _charCount = _messageController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markAsRead() async {
    final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    if (chatDoc.exists) {
      final data = chatDoc.data() as Map<String, dynamic>;
      if (data['lastSenderId'] != currentUserId && data['isRead'] == false) {
        await FirebaseFirestore.instance.collection('chats').doc(chatId).update({'isRead': true});
      }
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_messageController.text.length > 400) return;

    final String text = _messageController.text.trim();
    _messageController.clear();

    final Timestamp now = Timestamp.now();

    // Mesajı şifrele
    final String encryptedText = EncryptionService.encrypt(text);

    // 1. Mesajı ekle
    await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUserId,
      'receiverId': widget.peerId,
      'text': encryptedText, // Şifreli metin
      'timestamp': now,
    });

    // 2. Chat özetini güncelle ve gizleme listesinden çıkar (Yeni mesaj gelince tekrar görünsün)
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'lastMessage': encryptedText, // Özet de şifreli
      'lastTimestamp': now,
      'participants': [currentUserId, widget.peerId],
      'lastSenderId': currentUserId,
      'isRead': false,
      'hiddenFor': FieldValue.arrayRemove([currentUserId, widget.peerId]), // İki taraf için de tekrar görünür yap
    }, SetOptions(merge: true));

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => Get.to(() => Ziyaretci(gelenKullaniciEmail: widget.peerId)),
          child: Row(
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: profilResmiGetir(widget.peerId),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: profilIsmiGetir(widget.peerId)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                }

                final messages = snapshot.data!.docs;

                // Ekran açıkken yeni mesaj gelirse oku olarak işaretle
                if (messages.isNotEmpty) {
                  _markAsRead();
                }

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final bool isMe = data['senderId'] == currentUserId;
                    final Timestamp? timestamp = data['timestamp'] as Timestamp?;

                    // Mesajı çöz
                    final String decryptedText = EncryptionService.decrypt(data['text'] ?? '');

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.cyanAccent.withOpacity(0.2) : Colors.grey[900],
                          borderRadius: BorderRadius.circular(15).copyWith(
                            bottomRight: isMe ? Radius.zero : null,
                            bottomLeft: !isMe ? Radius.zero : null,
                          ),
                          border: isMe ? Border.all(color: Colors.cyanAccent.withOpacity(0.3)) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              decryptedText,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timestamp != null ? DateFormat('HH:mm').format(timestamp.toDate()) : '',
                              style: TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.grey[900],
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_charCount > 350)
              Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 4),
                child: Text(
                  '${400 - _charCount}',
                  style: TextStyle(
                    color: _charCount >= 400 ? Colors.red : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 400,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yaz...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      counterText: "",
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Iconsax.send_1, color: Colors.cyanAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
