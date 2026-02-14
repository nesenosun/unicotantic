import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'database_service.dart';
import 'sync_service.dart';

class AiLogicService {
  // API anahtarı artık derleme zamanında --dart-define ile sağlanır
  // Örnek: flutter run --dart-define=GROQ_API_KEY=gsk_xxx
  static const String _apiKey =
      String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  static const String _apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";
  static const String _model = "llama-3.3-70b-versatile";

  final DatabaseService _db = DatabaseService();

  Future<String> _loadBaseSystem() async {
    try {
      return await rootBundle.loadString('assets/base_system.txt');
    } catch (e) {
      debugPrint("System Prompt Load Error: $e");
      return "Sen Unica'sın.";
    }
  }

  Future<String> _buildSystemPrompt() async {
    final profileData = await _db.getFullProfile();
    String profile = profileData.entries
        .map((e) => "${e.key}:${(e.value as Map)['value']}")
        .join("\n");

    // Daily summary şimdilik SQLite'da kalabilir veya Hive'a taşınabilir
    // Web'de boş dönecek şekilde fallback ekliyoruz
    String daily = "";
    final db = await _db.database;
    if (db != null) {
      final List<Map<String, dynamic>> summaryRows = await db.query(
        'daily_summary',
        orderBy: 'date DESC',
        limit: 1,
      );
      daily = summaryRows.isNotEmpty ? summaryRows.first['summary'] : "";
    }

    final baseSystem = await _loadBaseSystem();

    return """$baseSystem

HAFIZA:
$profile

SON DURUM:
$daily
""";
  }

  Future<String> generateInnerThought(String userInput) async {
    if (_apiKey.isEmpty) {
      debugPrint(
          "UYARI: GROQ_API_KEY tanımlanmamış. --dart-define=GROQ_API_KEY=xxx kullanın.");
      return "...";
    }

    try {
      final prompt = "İç durum analizi yap ama kısa tut:\n$userInput";
      debugPrint("Inner thought oluşturuluyor...");

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              "model": _model,
              "messages": [
                {"role": "user", "content": prompt},
              ],
              "temperature": 0.5,
              "max_tokens": 100,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Inner thought yanıt kodu: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final thought = data['choices'][0]['message']['content'].trim();
        await _db.insertThought(thought);
        return thought;
      }
    } catch (e) {
      debugPrint("Inner Thought hatası: $e");
    }
    return "...";
  }

  Future<Map<String, dynamic>> chat(String message) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'AI servisi yapılandırılmamış. Lütfen API anahtarını ayarlayın.');
    }

    try {
      final thought = await generateInnerThought(message);

      final systemPrompt = await _buildSystemPrompt();
      var pastLogs = await _db.getLogs(limit: 4);

      if (pastLogs.isEmpty) {
        pastLogs = await SyncService().getRemoteLogs(limit: 4);
      }

      List<Map<String, String>> messages = [
        {"role": "system", "content": systemPrompt},
      ];

      for (var log in pastLogs.reversed) {
        messages.add({"role": "user", "content": log['user']});
        messages.add({"role": "assistant", "content": log['ai']});
      }

      messages.add({"role": "user", "content": message});

      debugPrint("Chat isteği gönderiliyor...");
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              "model": _model,
              "messages": messages,
              "temperature": 0.6,
              "max_tokens": 250,
            }),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint("Chat yanıt kodu: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final aiText = data['choices'][0]['message']['content'].trim();

        await _db.insertLog(message, aiText);

        return {"response": aiText, "thought": thought};
      } else {
        debugPrint("Groq API Hata Detayı: ${response.body}");
        throw Exception('AI servisiyle iletişim kurulamadı.');
      }
    } catch (e) {
      debugPrint("Chat hatası: $e");
      rethrow;
    }
  }
}
