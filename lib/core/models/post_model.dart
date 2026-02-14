import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postID;
  final String authorID;
  final String email;
  final String text;
  final String? mediaUrl;
  final String mediaType;
  final DateTime createdAt;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;
  final String? parentID;
  final String rootID;

  PostModel({
    required this.postID,
    required this.authorID,
    required this.text,
    this.mediaUrl,
    this.mediaType = 'text',
    required this.createdAt,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
    this.parentID,
    required this.rootID,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'postID': postID,
      'authorID': authorID,
      'email': email,
      'text': text,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'createdAt': createdAt,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
      'parentID': parentID,
      'rootID': rootID,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    // Legacy support for media
    String? detectedMediaUrl = map['mediaUrl'] ?? 
                             (map['postFotolinki'] != 'bos' ? map['postFotolinki'] : null) ?? 
                             (map['postVideoLinki'] != '' ? map['postVideoLinki'] : null);

    String detectedMediaType = map['mediaType'] ?? 
                              ((map['postVideoLinki'] != null && map['postVideoLinki'] != '') ? 'video' : 
                               (map['postFotolinki'] != null && map['postFotolinki'] != 'bos') ? 'image' : 'text');

    return PostModel(
      postID: map['postID'] ?? map['postAydi'] ?? '',
      authorID: map['authorID'] ?? map['email'] ?? '',
      email: map['email'] ?? '',
      text: map['text'] ?? map['baslik'] ?? map['metin'] ?? '',
      mediaUrl: detectedMediaUrl,
      mediaType: detectedMediaType,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? 
                 (map['zaman'] as Timestamp?)?.toDate() ?? 
                 DateTime.now(),
      likeCount: map['likeCount'] ?? (map['begen'] as List?)?.length ?? 0,
      dislikeCount: map['dislikeCount'] ?? (map['begenMe'] as List?)?.length ?? 0,
      commentCount: map['commentCount'] ?? map['yorumSayisi'] ?? 0,
      parentID: map['parentID'] ?? map['parentId'],
      rootID: map['rootID'] ?? map['rootId'] ?? map['postAydi'] ?? '',
    );
  }

  factory PostModel.fromSnapshot(DocumentSnapshot snap) {
    var map = snap.data() as Map<String, dynamic>;
    return PostModel.fromMap(map);
  }
}
