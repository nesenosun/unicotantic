import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateAllPostsLanguage() async {
    try {
      debugPrint("MigrationService: Başlatılıyor...");

      // Tüm postları çek (language alanı olmayanlar veya null olanlar için sorgu yapılamaz, hepsini çekip kontrol edeceğiz)
      // Batch işlemi için limit koymak gerekebilir ama şimdilik 500'lük gruplar halinde yapalım.

      QuerySnapshot snapshot = await _firestore.collection('posts').get();

      WriteBatch batch = _firestore.batch();
      int count = 0;
      int totalUpdated = 0;

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (!data.containsKey('language') || data['language'] == null) {
          batch.update(doc.reference, {'language': 'tr'});
          count++;
          totalUpdated++;
        }

        // Firestore batch limiti 500'dür
        if (count >= 400) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
          debugPrint("MigrationService: 400 post güncellendi...");
        }
      }

      if (count > 0) {
        await batch.commit();
        debugPrint("MigrationService: Son $count post güncellendi.");
      }

      debugPrint(
          "MigrationService: Tamamlandı. Toplam $totalUpdated post güncellendi.");
    } catch (e) {
      debugPrint("MigrationService Hatası: $e");
    }
  }
}
