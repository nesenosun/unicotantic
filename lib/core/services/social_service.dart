import 'package:cloud_firestore/cloud_firestore.dart';

class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- TAKİP SİSTEMİ ---

  Future<void> followUser(String followerUid, String followedUid) async {
    WriteBatch batch = _firestore.batch();

    // 1. Takipçiler koleksiyonuna ekle
    batch.set(
      _firestore
          .collection('followers')
          .doc(followedUid)
          .collection('userFollowers')
          .doc(followerUid),
      {'timestamp': FieldValue.serverTimestamp()},
    );

    // 2. Takip edilenler koleksiyonuna ekle
    batch.set(
      _firestore
          .collection('following')
          .doc(followerUid)
          .collection('userFollowing')
          .doc(followedUid),
      {'timestamp': FieldValue.serverTimestamp()},
    );

    // 3. Sayaçları güncelle
    batch.update(_firestore.collection('users').doc(followedUid), {
      'followerCount': FieldValue.increment(1),
    });
    batch.update(_firestore.collection('users').doc(followerUid), {
      'followingCount': FieldValue.increment(1),
    });

    await batch.commit();

    // Bildirim gönder
    await createNotification(
      targetId: followedUid,
      fromId: followerUid,
      type: 'follow',
      content: 'Seni takip etmeye başladı',
    );
  }

  Future<void> unfollowUser(String followerUid, String followedUid) async {
    WriteBatch batch = _firestore.batch();

    batch.delete(_firestore
        .collection('followers')
        .doc(followedUid)
        .collection('userFollowers')
        .doc(followerUid));
    batch.delete(_firestore
        .collection('following')
        .doc(followerUid)
        .collection('userFollowing')
        .doc(followedUid));

    batch.update(_firestore.collection('users').doc(followedUid), {
      'followerCount': FieldValue.increment(-1),
    });
    batch.update(_firestore.collection('users').doc(followerUid), {
      'followingCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  Future<List<String>> getFollowingIds(String userId) async {
    final snapshot = await _firestore
        .collection('following')
        .doc(userId)
        .collection('userFollowing')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // --- BEĞENİ VE DİSLİKE SİSTEMİ ---

  Future<void> toggleLike(String uid, String postId) async {
    final likeRef = _firestore.collection('likes').doc('${postId}_$uid');
    final dislikeRef = _firestore.collection('dislikes').doc('${postId}_$uid');
    final postRef = _firestore.collection('posts').doc(postId);

    final likeDoc = await likeRef.get();
    final dislikeDoc = await dislikeRef.get();

    WriteBatch batch = _firestore.batch();

    if (likeDoc.exists) {
      // Zaten beğenilmişse, beğeniyi kaldır
      batch.delete(likeRef);
      batch.update(postRef, {'likeCount': FieldValue.increment(-1)});
    } else {
      // Beğenilmemişse, beğeniyi ekle
      batch.set(likeRef, {
        'uid': uid,
        'postId': postId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      batch.update(postRef, {'likeCount': FieldValue.increment(1)});

      // Eğer dislike varsa onu kaldır
      if (dislikeDoc.exists) {
        batch.delete(dislikeRef);
        batch.update(postRef, {'dislikeCount': FieldValue.increment(-1)});
      }
    }

    await batch.commit();
  }

  Future<void> toggleDislike(String uid, String postId) async {
    final dislikeRef = _firestore.collection('dislikes').doc('${postId}_$uid');
    final likeRef = _firestore.collection('likes').doc('${postId}_$uid');
    final postRef = _firestore.collection('posts').doc(postId);

    final dislikeDoc = await dislikeRef.get();
    final likeDoc = await likeRef.get();

    WriteBatch batch = _firestore.batch();

    if (dislikeDoc.exists) {
      // Zaten dislike atılmışsa, kaldır
      batch.delete(dislikeRef);
      batch.update(postRef, {'dislikeCount': FieldValue.increment(-1)});
    } else {
      // Dislike atılmamışsa, ekle
      batch.set(dislikeRef, {
        'uid': uid,
        'postId': postId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      batch.update(postRef, {'dislikeCount': FieldValue.increment(1)});

      // Eğer beğeni varsa onu kaldır
      if (likeDoc.exists) {
        batch.delete(likeRef);
        batch.update(postRef, {'likeCount': FieldValue.increment(-1)});
      }
    }

    await batch.commit();
  }

  // --- YER İMLERİ ---

  Future<void> bookmarkPost(String uid, String postId) async {
    await _firestore
        .collection('bookmarks')
        .doc(uid)
        .collection('userBookmarks')
        .doc(postId)
        .set({
      'postId': postId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- BİLDİRİMLER ---

  Future<void> createNotification({
    required String targetId,
    required String fromId,
    required String type, // 'like', 'comment', 'follow', 'arkadas_istek'
    String? postId,
    String? commentId,
    String? content,
  }) async {
    // Kendi kendine bildirim gönderme
    if (targetId == fromId) return;

    // Engelleme kontrolü (Bildirim alan veya gönderen tarafında engel var mı?)
    final targetDoc = await _firestore.collection('users').doc(targetId).get();
    final fromDoc = await _firestore.collection('users').doc(fromId).get();

    if (targetDoc.exists && fromDoc.exists) {
      final targetBlockedList =
          (targetDoc.data() as Map<String, dynamic>)['blockedUsers'] ?? [];
      final fromBlockedList =
          (fromDoc.data() as Map<String, dynamic>)['blockedUsers'] ?? [];

      if (targetBlockedList.contains(fromId) ||
          fromBlockedList.contains(targetId)) {
        return; // Engelli durumda bildirim gitmez
      }
    }

    await _firestore
        .collection('firebasedenofication')
        .doc(targetId)
        .collection('notifications')
        .add({
      'fromId': fromId,
      'type': type,
      'postId': postId,
      'commentId': commentId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Kullanıcının bildirim sayısını artır
    await _firestore.collection('users').doc(targetId).update({
      'notificationCount': FieldValue.increment(1),
    });
  }

  // --- ARKADAŞLIK SİSTEMİ ---

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    // Kendi kendine istek gönderemez
    if (senderId == receiverId) return;

    final requestRef =
        _firestore.collection('friendRequests').doc('${senderId}_$receiverId');

    // Zaten varsa kontrolü (Batch olmadan hızlı check)
    final doc = await requestRef.get();
    if (doc.exists) return;

    await requestRef.set({
      'senderId': senderId,
      'receiverId': receiverId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Bildirim gönder
    await createNotification(
      targetId: receiverId,
      fromId: senderId,
      type: 'arkadas_istek',
      content: 'sana arkadaşlık isteği gönderdi',
    );
  }

  Future<void> acceptFriendRequest(String userId, String requesterId) async {
    WriteBatch batch = _firestore.batch();

    // 1. İstek dokümanını sil
    batch.delete(
        _firestore.collection('friendRequests').doc('${requesterId}_$userId'));

    // 2. Karşılıklı arkadaşlık kayıtlarını ekle
    batch.set(
      _firestore
          .collection('friends')
          .doc(userId)
          .collection('userFriends')
          .doc(requesterId),
      {'friendId': requesterId, 'timestamp': FieldValue.serverTimestamp()},
    );
    batch.set(
      _firestore
          .collection('friends')
          .doc(requesterId)
          .collection('userFriends')
          .doc(userId),
      {'friendId': userId, 'timestamp': FieldValue.serverTimestamp()},
    );

    // 3. Sayaçları güncelle
    batch.update(_firestore.collection('users').doc(userId), {
      'friendCount': FieldValue.increment(1),
    });
    batch.update(_firestore.collection('users').doc(requesterId), {
      'friendCount': FieldValue.increment(1),
    });

    await batch.commit();

    // Bildirim gönder (Onay bildirmı)
    await createNotification(
      targetId: requesterId,
      fromId: userId,
      type: 'arkadas_onay',
      content: 'arkadaşlık isteğini kabul etti',
    );
  }

  Future<void> declineFriendRequest(String userId, String requesterId) async {
    await _firestore
        .collection('friendRequests')
        .doc('${requesterId}_$userId')
        .delete();
  }

  Future<void> removeFriend(String userId, String friendId) async {
    WriteBatch batch = _firestore.batch();

    batch.delete(_firestore
        .collection('friends')
        .doc(userId)
        .collection('userFriends')
        .doc(friendId));
    batch.delete(_firestore
        .collection('friends')
        .doc(friendId)
        .collection('userFriends')
        .doc(userId));

    // Sayaçları güncelle
    batch.update(_firestore.collection('users').doc(userId), {
      'friendCount': FieldValue.increment(-1),
    });
    batch.update(_firestore.collection('users').doc(friendId), {
      'friendCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  Future<String> getFriendshipStatus(String userId, String otherId) async {
    if (userId == otherId) return 'self';

    // 1. Arkadaş mı?
    final friendSnap = await _firestore
        .collection('friends')
        .doc(userId)
        .collection('userFriends')
        .doc(otherId)
        .get();
    if (friendSnap.exists) return 'friends';

    // 2. İstek gönderilmiş mi? (Ben gönderdim)
    final sentRequestSnap = await _firestore
        .collection('friendRequests')
        .doc('${userId}_$otherId')
        .get();
    if (sentRequestSnap.exists) return 'request_sent';

    // 3. İstek gelmiş mi? (O gönderdi)
    final receivedRequestSnap = await _firestore
        .collection('friendRequests')
        .doc('${otherId}_$userId')
        .get();
    if (receivedRequestSnap.exists) return 'request_received';

    return 'none';
  }

  Future<List<String>> getFriendIds(String userId) async {
    final snapshot = await _firestore
        .collection('friends')
        .doc(userId)
        .collection('userFriends')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // --- RAPORLAMA ---

  // --- ENGELLEME VE SESSİZE ALMA ---

  Future<void> blockUser(String blockerUid, String blockedUid) async {
    WriteBatch batch = _firestore.batch();

    // 1. Engelleyenin 'blockedUsers' listesine ekle
    batch.update(_firestore.collection('users').doc(blockerUid), {
      'blockedUsers': FieldValue.arrayUnion([blockedUid])
    });

    // 2. Engellenen kişinin 'blockedBy' listesine engelleyeni ekle
    batch.update(_firestore.collection('users').doc(blockedUid), {
      'blockedBy': FieldValue.arrayUnion([blockerUid])
    });

    // 3. Karşılıklı takibi kaldır
    batch.delete(_firestore
        .collection('followers')
        .doc(blockedUid)
        .collection('userFollowers')
        .doc(blockerUid));
    batch.delete(_firestore
        .collection('following')
        .doc(blockerUid)
        .collection('userFollowing')
        .doc(blockedUid));

    batch.delete(_firestore
        .collection('followers')
        .doc(blockerUid)
        .collection('userFollowers')
        .doc(blockedUid));
    batch.delete(_firestore
        .collection('following')
        .doc(blockedUid)
        .collection('userFollowing')
        .doc(blockerUid));

    // 4. Karşılıklı arkadaşlığı kaldır
    batch.delete(_firestore
        .collection('friends')
        .doc(blockerUid)
        .collection('userFriends')
        .doc(blockedUid));
    batch.delete(_firestore
        .collection('friends')
        .doc(blockedUid)
        .collection('userFriends')
        .doc(blockerUid));

    // 5. Sayaçları güncelle (Eğer takip/arkadaş iseler azalması lazım ama batch ile güvenli)
    // Not: Tam doğruluk için önce check gerekebilir ama basitleştirmek için sadece block odağındayız.
    // Ancak en azından sayaçları bozmamak için burada azaltmak riskli olabilir (eğer takip etmiyorlarsa -1 olur).
    // Bu yüzden şimdilik sadece ilişkileri koparıyoruz. Sayaçlar bir sonraki profil yüklemesinde zaten dinamik hesaplanabilirse iyi olur.

    await batch.commit();
  }

  Future<void> unblockUser(String blockerUid, String blockedUid) async {
    WriteBatch batch = _firestore.batch();

    batch.update(_firestore.collection('users').doc(blockerUid), {
      'blockedUsers': FieldValue.arrayRemove([blockedUid])
    });

    batch.update(_firestore.collection('users').doc(blockedUid), {
      'blockedBy': FieldValue.arrayRemove([blockerUid])
    });

    await batch.commit();
  }

  Future<void> muteUser(String blockerUid, String mutedUid) async {
    await _firestore.collection('users').doc(blockerUid).update({
      'mutedUsers': FieldValue.arrayUnion([mutedUid])
    });
  }

  Future<void> unmuteUser(String blockerUid, String mutedUid) async {
    await _firestore.collection('users').doc(blockerUid).update({
      'mutedUsers': FieldValue.arrayRemove([mutedUid])
    });
  }

  Future<bool> isMuted(String blockerUid, String mutedUid) async {
    final doc = await _firestore.collection('users').doc(blockerUid).get();
    if (doc.exists) {
      final List mutedList =
          (doc.data() as Map<String, dynamic>)['mutedUsers'] ?? [];
      return mutedList.contains(mutedUid);
    }
    return false;
  }

  Future<bool> isBlocked(String blockerUid, String targetUid) async {
    final doc = await _firestore.collection('users').doc(blockerUid).get();
    if (doc.exists) {
      final List blockedList =
          (doc.data() as Map<String, dynamic>)['blockedUsers'] ?? [];
      return blockedList.contains(targetUid);
    }
    return false;
  }

  Future<bool> isFollowing(String followerUid, String followedUid) async {
    final doc = await _firestore
        .collection('following')
        .doc(followerUid)
        .collection('userFollowing')
        .doc(followedUid)
        .get();
    return doc.exists;
  }
}
