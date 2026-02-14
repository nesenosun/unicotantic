import '../models/message.dart';
import 'ai_logic_service.dart';
import 'database_service.dart';
import 'sync_service.dart';

class ApiService {
  final AiLogicService _aiLogic = AiLogicService();
  final DatabaseService _db = DatabaseService();

  Future<List<Message>> getHistory({int limit = 5, int offset = 0}) async {
    var rows = await _db.getLogs(limit: limit, offset: offset);
    
    // Eğer yerel boşsa ve web'deysek veya senkronizasyon gerekiyorsa remote'a bak
    if (rows.isEmpty && offset == 0) {
      rows = await SyncService().getRemoteLogs(limit: limit);
    }

    List<Message> history = [];
    // Gelen veriler zamanı azalan (en yeni başta) olarak geliyor, biz bu sayfayı kendi içinde ters çeviriyoruz
    final pageRows = rows.toList();

    for (var row in pageRows) {
      // Önce AI mesajını ekleyelim (sıralama gereği)
      if (row['ai'] != null) {
        history.insert(0, 
          Message(
            text: row['ai'],
            isUser: false,
            timestamp: DateTime.parse(row['time']),
            thought: row['thought'],
          ),
        );
      }
      // Sonra kullanıcı mesajını
      if (row['user'] != null) {
        history.insert(0,
          Message(
            text: row['user'],
            isUser: true,
            timestamp: DateTime.parse(row['time']),
          ),
        );
      }
    }
    return history;
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    return await _aiLogic.chat(message);
  }
}
