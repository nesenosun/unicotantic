import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Beğeni ve dislike işlemlerini yöneten servis sınıfı.
/// Firestore'daki 'likes' koleksiyonunu ve 'posts' koleksiyonunu günceller.
class LikeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mevcut kullanıcının verilen postu beğenip beğenmediğini kontrol eder.
  static Future<bool> isLiked(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final likeDocId = '${postId}_${user.uid}';
    final doc = await _firestore.collection('likes').doc(likeDocId).get();
    return doc.exists;
  }

  /// Beğeni toggle - beğenilmişse kaldır, değilse ekle.
  /// Başarılı olursa yeni beğeni durumunu döndürür.
  /// Unic Ekonomisi:
  /// - Like verirken: veren 1 unic harcar, post sahibi 1 unic kazanır
  /// - Like kaldırırken: veren 1 unic geri alır, post sahibi 1 unic kaybeder
  static Future<bool> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final likeDocId = '${postId}_${user.uid}';
    final dislikeDocId = 'dislike_${postId}_${user.uid}';
    final likeRef = _firestore.collection('likes').doc(likeDocId);
    final dislikeRef = _firestore.collection('likes').doc(dislikeDocId);
    final postRef = _firestore.collection('posts').doc(postId);
    final currentUserRef = _firestore.collection('users').doc(user.uid);

    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final likeDoc = await transaction.get(likeRef);
        final dislikeDoc = await transaction.get(dislikeRef);
        final postDoc = await transaction.get(postRef);
        final currentUzerDoc = await transaction.get(currentUserRef);

        if (!postDoc.exists || !currentUzerDoc.exists) return false;

        final postData = postDoc.data() as Map<String, dynamic>;
        final authorId = postData['authorID'] ?? postData['email'] ?? '';
        
        if (authorId == user.uid || authorId == user.email) return false;
        final authorRef = _firestore.collection('users').doc(authorId);

        final userData = currentUzerDoc.data() as Map<String, dynamic>;
        final int currentUnic = userData['unicBalance'] ?? 0;

        if (likeDoc.exists) {
          // Beğeniyi kaldır
          transaction.delete(likeRef);
          transaction.update(postRef, {'likeCount': FieldValue.increment(-1)});
          transaction.update(authorRef, {'unicBalance': FieldValue.increment(-1)});
          return false;
        } else {
          // Bakiye kontrolü
          if (currentUnic <= 0) return false;

          // Eğer dislike varsa önce onu kaldır
          if (dislikeDoc.exists) {
            transaction.delete(dislikeRef);
            transaction.update(postRef, {
              'dislikeCount': FieldValue.increment(-1),
              'likeCount': FieldValue.increment(1),
            });
            transaction.update(authorRef, {
              'unicBalance': FieldValue.increment(2), // -1'den +1'e çıkış (+2 fark)
            });
          } else {
            transaction.update(postRef, {'likeCount': FieldValue.increment(1)});
            transaction.update(authorRef, {'unicBalance': FieldValue.increment(1)});
          }

          transaction.set(likeRef, {
            'uid': user.uid,
            'postId': postId,
            'authorId': authorId,
            'timestamp': FieldValue.serverTimestamp(),
          });
          transaction.update(currentUserRef, {'unicBalance': FieldValue.increment(-1)});
          
          // Bildirim
          final notificationRef = _firestore.collection('firebasedenofication').doc(authorId).collection('notifications').doc();
          transaction.set(notificationRef, {
            'fromId': user.uid,
            'type': 'like',
            'postId': postId,
            'content': 'Gönderini beğendi',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });
          transaction.update(authorRef, {'notificationCount': FieldValue.increment(1)});

          return true;
        }
      });
    } catch (e) {
      debugPrint('Like toggle hatası: $e');
      return false;
    }
  }

  static Future<bool> toggleDislike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final likeDocId = '${postId}_${user.uid}';
    final dislikeDocId = 'dislike_${postId}_${user.uid}';
    final likeRef = _firestore.collection('likes').doc(likeDocId);
    final dislikeRef = _firestore.collection('likes').doc(dislikeDocId);
    final postRef = _firestore.collection('posts').doc(postId);
    final currentUserRef = _firestore.collection('users').doc(user.uid);

    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final likeDoc = await transaction.get(likeRef);
        final dislikeDoc = await transaction.get(dislikeRef);
        final postDoc = await transaction.get(postRef);
        final currentUzerDoc = await transaction.get(currentUserRef);

        if (!postDoc.exists || !currentUzerDoc.exists) return false;

        final postData = postDoc.data() as Map<String, dynamic>;
        final authorId = postData['authorID'] ?? postData['email'] ?? '';
        
        if (authorId == user.uid || authorId == user.email) return false;
        final authorRef = _firestore.collection('users').doc(authorId);

        final userData = currentUzerDoc.data() as Map<String, dynamic>;
        final int currentUnic = userData['unicBalance'] ?? 0;

        if (dislikeDoc.exists) {
          // Dislike'ı kaldır
          transaction.delete(dislikeRef);
          transaction.update(postRef, {'dislikeCount': FieldValue.increment(-1)});
          transaction.update(authorRef, {'unicBalance': FieldValue.increment(1)});
          return false;
        } else {
          // Bakiye kontrolü
          if (currentUnic <= 0) return false;

          // Eğer like varsa önce onu kaldır
          if (likeDoc.exists) {
            transaction.delete(likeRef);
            transaction.update(postRef, {
              'likeCount': FieldValue.increment(-1),
              'dislikeCount': FieldValue.increment(1),
            });
            transaction.update(authorRef, {
              'unicBalance': FieldValue.increment(-2), // +1'den -1'e düşüş (-2 fark)
            });
          } else {
            transaction.update(postRef, {'dislikeCount': FieldValue.increment(1)});
            transaction.update(authorRef, {'unicBalance': FieldValue.increment(-1)});
          }

          transaction.set(dislikeRef, {
            'uid': user.uid,
            'postId': postId,
            'authorId': authorId,
            'isDislike': true,
            'timestamp': FieldValue.serverTimestamp(),
          });
          transaction.update(currentUserRef, {'unicBalance': FieldValue.increment(-1)});

          return true;
        }
      });
    } catch (e) {
      debugPrint('Dislike toggle hatası: $e');
      return false;
    }
  }

  /// Beğeni ve dislike durumlarını eşzamanlı kontrol eder.
  static Future<Map<String, bool>> getLikeStatus(String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'isLiked': false, 'isDisliked': false};
    }

    final likeDocId = '${postId}_${user.uid}';
    final dislikeDocId = 'dislike_${postId}_${user.uid}';

    final results = await Future.wait([
      _firestore.collection('likes').doc(likeDocId).get(),
      _firestore.collection('likes').doc(dislikeDocId).get(),
    ]);

    return {
      'isLiked': results[0].exists,
      'isDisliked': results[1].exists,
    };
  }
}
