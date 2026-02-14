import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  String? get _userId => _auth.currentUser?.uid;

  // Firestore'daki koleksiyon yapısı:
  // users / {uid} / unica_memory / logs
  // users / {uid} / unica_memory / profile
  // users / {uid} / unica_memory / thoughts

  Future<void> syncAll() async {
    if (_userId == null) return;
    try {
      print("Firebase senkronizasyonu başlatılıyor: $_userId");
      // Senkronizasyonun tamamı için 15 saniyelik bir süre tanı
      await Future.wait([
        _syncLogs(),
        _syncProfile(),
        _syncThoughts(),
      ]).timeout(const Duration(seconds: 15));
      print("Firebase senkronizasyonu tamamlandı.");
    } catch (e) {
      print("Firebase senkronizasyon hatası: $e");
      // Senkronizasyon hatası uygulamanın çalışmasını engellememeli
    }
  }

  Future<void> _syncLogs() async {
    if (_userId == null) return;

    // 1. Yerel verileri Firebase'e yükle
    final localLogs = await _db.getLogs(limit: 50);
    final remoteCollection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('unica_memory')
        .doc('data')
        .collection('logs');

    for (var log in localLogs) {
      await remoteCollection.doc(log['time'].toString().replaceAll('.', '_')).set({
        'time': log['time'],
        'user': log['user'],
        'ai': log['ai'],
      }, SetOptions(merge: true));
    }

    // 2. Firebase'deki verileri yerele indir
    final remoteSnapshot = await remoteCollection.orderBy('time', descending: true).limit(50).get();
    for (var doc in remoteSnapshot.docs) {
      await _db.checkAndInsertLog(doc.data());
    }
  }

  Future<void> _syncProfile() async {
    if (_userId == null) return;

    final remoteDoc = _firestore
        .collection('users')
        .doc(_userId)
        .collection('unica_memory')
        .doc('profile');

    // Yerel profili çek ve Firebase'e yükle
    final localProfile = await _db.getFullProfile();
    if (localProfile.isNotEmpty) {
      await remoteDoc.set(localProfile, SetOptions(merge: true));
    }

    // Remote'tan çek ve yerele kaydet
    final remoteSnapshot = await remoteDoc.get();
    if (remoteSnapshot.exists) {
      final data = remoteSnapshot.data()!;
      for (var entry in data.entries) {
        final key = entry.key;
        final valueMap = entry.value as Map<String, dynamic>;
        await _db.updateProfile(key, valueMap['value'] as String);
      }
    }
  }

  Future<void> _syncThoughts() async {
    if (_userId == null) return;

    final remoteCollection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('unica_memory')
        .doc('data')
        .collection('thoughts');

    // 1. Yerel düşünceleri yükle
    // Not: getLastThought sadece bir tane getiriyor, şimdilik böyle kalsın veya genişletilebilir
    final lastThought = await _db.getLastThought();
    if (lastThought != null) {
      // time bilgisi olmadığı için şimdilik manuel oluşturuyoruz (veya DB metotları güncellenebilir)
      // Ancak getLogs gibi thoughts için de bir liste çekme eklenebilir. 
      // Şimdilik sadece indirme kısmına odaklanalım.
    }

    // 2. İndir
    final remoteSnapshot = await remoteCollection.orderBy('time', descending: true).limit(20).get();
    for (var doc in remoteSnapshot.docs) {
      await _db.checkAndInsertThought(doc.data());
    }
  }

  // Tekil veri yazma işlemleri için tetikleyiciler
  Future<void> uploadLog(String time, String user, String ai) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('unica_memory')
        .doc('data')
        .collection('logs')
        .doc(time.replaceAll('.', '_'))
        .set({'time': time, 'user': user, 'ai': ai}, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getRemoteLogs({int limit = 10}) async {
    if (_userId == null) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('unica_memory')
          .doc('data')
          .collection('logs')
          .orderBy('time', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Remote logs fetch error: $e");
      return [];
    }
  }
}
