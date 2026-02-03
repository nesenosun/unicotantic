import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'database_service.dart';

class AiLogicService {
  static const String _apiKey =
      "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";
  static const String _apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";
  static const String _model = "llama-3.3-70b-versatile";

  final DatabaseService _db = DatabaseService();

  Future<String> _loadBaseSystem() async {
    try {
      return await rootBundle.loadString('assets/base_system.txt');
    } catch (e) {
      print("System Prompt Load Error: $e");
      return "Sen Unica'sın.";
    }
  }

  Future<String> _buildSystemPrompt() async {
    final db = await _db.database;

    // Profil bilgilerini al
    final List<Map<String, dynamic>> profileRows = await db.query(
      'user_profile',
    );
    String profile = profileRows
        .map((row) => "${row['key']}:${row['value']}")
        .join("\n");

    // Son günlük özeti al
    final List<Map<String, dynamic>> summaryRows = await db.query(
      'daily_summary',
      orderBy: 'date DESC',
      limit: 1,
    );
    String daily = summaryRows.isNotEmpty ? summaryRows.first['summary'] : "";

    final baseSystem = await _loadBaseSystem();

    return """$baseSystem

HAFIZA:
$profile

SON DURUM:
$daily
""";
  }

  Future<String> generateInnerThought(String userInput) async {
    try {
      final prompt = "İç durum analizi yap ama kısa tut:\n$userInput";
      print("Inner thought is being generated for: $userInput");

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

      print("Inner thought response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thought = data['choices'][0]['message']['content'].trim();
        await _db.insertThought(thought);
        return thought;
      }
    } catch (e) {
      print("Inner Thought Generation Error: $e");
    }
    return "...";
  }

  Future<Map<String, dynamic>> chat(String message) async {
    try {
      // 1. İç düşünce üret
      final thought = await generateInnerThought(message);

      // 2. Sistem mesajını ve geçmişi hazırla
      final systemPrompt = await _buildSystemPrompt();
      final pastLogs = await _db.getLogs(limit: 4);

      List<Map<String, String>> messages = [
        {"role": "system", "content": systemPrompt},
      ];

      // Geçmişi ekle (kronolojik sıra için reversed)
      for (var log in pastLogs.reversed) {
        messages.add({"role": "user", "content": log['user']});
        messages.add({"role": "assistant", "content": log['ai']});
      }

      // Mevcut mesajı ekle
      messages.add({"role": "user", "content": message});

      // 3. Groq'a gönder
      print("Main chat request is being sent for: $message");
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

      print("Main chat response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiText = data['choices'][0]['message']['content'].trim();

        // 4. Kaydet
        await _db.insertLog(message, aiText);

        return {"response": aiText, "thought": thought};
      } else {
        print("Groq API Error Body: ${response.body}");
        throw Exception('Groq API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      print("Main Chat Exception: $e");
      rethrow;
    }
  }
}
