import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'action_command.dart';

/// Akış Projesi - Voice Controller
/// Uygulamanın sesli beyni. Gelen metni analiz eder ve ilgili komutu çalıştırır.
class VoiceController extends GetxController {
  /// Kayıtlı komutların listesi
  final List<ActionCommand> _commands = [];

  /// Son işlenen komutun durumu (Reactive)
  var lastCommandStatus = ''.obs;
  var isProcessing = false.obs;

  final _speech = stt.SpeechToText();
  var isListening = false.obs;
  var recognizedText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Başlangıçta sürekli dinlemeyi başlatmıyoruz (Loop sorunu nedeniyle manuel)
    // startListening();
  }

  /// Yeni bir komutu sisteme tanıtır
  void registerCommand(ActionCommand command) {
    _commands.add(command);
  }

  var isWakeWordActive = false.obs; // Komut almaya hazır mı?
  var isContinuousListening = false.obs; // Arka planda sürekli dinliyor mu?

  /// Dinlemeyi Başlat/Durdur (Manuel Tetikleme)
  Future<void> toggleListening() async {
    if (isListening.value) {
      stopListening();
    } else {
      // Manuel basış doğrudan aktif modu açar
      isWakeWordActive.value = true;
      startListening();
    }
  }

  Future<void> startListening() async {
    isContinuousListening.value = true;
    _startListeningInternal();
  }

  Future<void> _startListeningInternal() async {
    try {
      bool available = await _speech.initialize(
        debugLogging: true,
        onStatus: (status) {
          debugPrint("🎤 STT Durumu: $status");
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (errorNotification) {
          debugPrint(
              "🎤 Ses Hatası Detayı: ${errorNotification.errorMsg} - ${errorNotification.permanent}");
          isListening.value = false;
          lastCommandStatus.value = "Hata: ${errorNotification.errorMsg}";
        },
      );

      debugPrint("🎤 STT Başlatılabilir mi?: $available");

      if (available) {
        isListening.value = true;

        _speech.listen(
          onResult: (result) {
            debugPrint("🎤 Duyulan: ${result.recognizedWords}");
            recognizedText.value = result.recognizedWords;

            if (!isWakeWordActive.value) {
              _checkForWakeWord(result.recognizedWords);
            } else {
              process(result.recognizedWords);
            }
          },
          localeId: "tr_TR",
          partialResults: true,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        );

        if (!isWakeWordActive.value) {
          lastCommandStatus.value = "Artemiz denmesi bekleniyor...";
        } else {
          lastCommandStatus.value = "Dinliyorum...";
        }
      } else {
        lastCommandStatus.value = "Mikrofon kullanılamıyor.";
        isListening.value = false;
      }
    } catch (e) {
      debugPrint("🎤 Kritik Hata: $e");
      lastCommandStatus.value = "Mikrofon başlatılamadı.";
      isListening.value = false;
    }
  }

  void _checkForWakeWord(String text) {
    // Regex ile esnek arama: artemiz, artemis, arte miz vb.
    final wakeWordRegex = RegExp(r'\b(artemiz|artemis|arte|yunikaya|yunika)\b',
        caseSensitive: false);

    if (wakeWordRegex.hasMatch(text)) {
      debugPrint("🔔 Wake Word Algılandı!");
      isWakeWordActive.value = true;
      lastCommandStatus.value = "Buyrun, dinliyorum...";

      // Sesli/Titreşim geri bildirimi eklenebilir
      Get.snackbar("Unica", "Dinliyorum...",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1),
          backgroundColor: Get.theme.primaryColor.withOpacity(0.5),
          colorText: Get.theme.colorScheme.onSurface);

      // Uyandırma kelimesinden sonra gelen kısmı hemen işle
      // Örn: "Artemiz nasılsın" dediğinde "nasılsın" kısmını alması için
      // Şu an basitçe aktif edip bırakıyoruz, kullanıcı devam edebilir.
    }
  }

  Future<void> stopListening() async {
    isContinuousListening.value = false; // Döngüyü kır
    isWakeWordActive.value = false;
    _speech.stop();
    isListening.value = false;
  }

  /// Gelen sesli metni işler
  Future<void> process(String text) async {
    if (text.isEmpty) return;

    isProcessing.value = true;
    lastCommandStatus.value = "Analiz ediliyor: '$text'...";

    // Konuşma metnini logla
    debugPrint("🎤 İşlenen Metin: $text");

    // En iyi eşleşen komutu bul
    ActionCommand? bestMatch;
    double highestConfidence = 0.0;

    for (var command in _commands) {
      double confidence = command.matchConfidence(text);
      if (confidence > highestConfidence) {
        highestConfidence = confidence;
        bestMatch = command;
      }
    }

    // Eşik değer (örn: 0.7) eklenebilir. Şimdilik basit tutuyoruz.
    if (bestMatch != null && highestConfidence > 0) {
      lastCommandStatus.value = "Komut algılandı. Çalıştırılıyor...";
      try {
        // Parametre ayrıştırma (basitlik için tüm text gönderiliyor)
        bestMatch.execute(text);
        lastCommandStatus.value = "Başarıyla tamamlandı.";

        // Komut başarıyla çalıştıktan sonra bir süre sonra pasife geçebiliriz
        // Şimdilik sürekli aktif kalsın ki sohbet edebilsin
        // Future.delayed(Duration(seconds: 5), () => isWakeWordActive.value = false);
      } catch (e) {
        lastCommandStatus.value = "Hata: $e";
      }
    } else {
      if (isWakeWordActive.value) {
        lastCommandStatus.value = "Komut anlaşılamadı.";
      }
    }

    isProcessing.value = false;
  }
}
