
/// Akış Projesi - Voice-to-Action Çekirdeği
/// Tüm sesli komutlar bu arayüzden türemelidir.
abstract class ActionCommand {
  /// Komutun tetiklenme anahtarları (örn: ['oy ver', 'seçim yap'])
  List<String> get triggers;

  /// Gelen metnin bu komutla ne kadar alakalı olduğunu puanlar (0.0 - 1.0)
  double matchConfidence(String input) {
    input = input.toLowerCase();
    for (var trigger in triggers) {
      if (input.contains(trigger.toLowerCase())) {
        return 1.0; // Tam eşleşme veya içerme (basitleştirilmiş)
      }
    }
    return 0.0;
  }

  /// Komutu çalıştırır
  void execute(dynamic arguments);
}
