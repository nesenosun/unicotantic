import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username; // Benzersiz kullanıcı adı (@ersin)
  final String name; // Görünen ad (Ersin Boçnak)
  final String email;
  final String photoUrl;
  final String bio;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final int unicBalance;
  final int notificationCount;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final List<String> blockedBy;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.name = '',
    this.photoUrl = '',
    this.bio = '',
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.unicBalance = 0,
    this.notificationCount = 0,
    this.createdAt,
    this.lastLogin,
    this.blockedBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'unicBalance': unicBalance,
      'notificationCount': notificationCount,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'lastLogin': lastLogin ?? FieldValue.serverTimestamp(),
      'blockedBy': blockedBy,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? map['kullaniciAdi'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? map['profilFoto'] ?? '',
      bio: map['bio'] ?? map['hakkinda'] ?? '',
      followerCount: map['followerCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      postCount: map['postCount'] ?? 0,
      unicBalance:
          (map['unicBalance'] is num) ? (map['unicBalance'] as num).toInt() : 0,
      notificationCount: map['notificationCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
      blockedBy: List<String>.from(map['blockedBy'] ?? []),
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    var map = snap.data() as Map<String, dynamic>;
    return UserModel.fromMap(map);
  }
}
