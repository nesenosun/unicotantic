import '../models/message.dart';
import 'ai_logic_service.dart';
import 'database_service.dart';

class ApiService {
  final AiLogicService _aiLogic = AiLogicService();
  final DatabaseService _db = DatabaseService();

  Future<List<Message>> getHistory({int limit = 10, int offset = 0}) async {
    final rows = await _db.getLogs(limit: limit, offset: offset);
    List<Message> history = [];

    // Database'den gelen verileri kronolojik sıraya sok (eskiden yeniye)
    // getLogs DESC döndüğü için burada tekrar reverse yapıyoruz UI'da doğru görünmesi için
    final reversedRows = rows.reversed.toList();

    for (var row in reversedRows) {
      if (row['user'] != null) {
        history.add(
          Message(
            text: row['user'],
            isUser: true,
            timestamp: DateTime.parse(row['time']),
          ),
        );
      }
      if (row['ai'] != null) {
        history.add(
          Message(
            text: row['ai'],
            isUser: false,
            timestamp: DateTime.parse(row['time']),
            // thought alanı için inner_thoughts tablosundan çekim yapılabilir ama şimdilik logda yok
            // Basitlik için log tablosuna thought alanını eklemedik, gerekirse eklenebilir.
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
