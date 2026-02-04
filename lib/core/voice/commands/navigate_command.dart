
import 'package:get/get.dart';
import '../action_command.dart';

/// Akış Projesi - Navigasyon Komutu
/// "Profile git", "Ayarları aç" gibi komutlarla sayfa geçişi sağlar.
class NavigateCommand extends ActionCommand {
  
  // Basit rota haritası
  final Map<String, String> routes = {
    'profil': '/profile', 
    'ayarlar': '/settings',
    'ana yetki': '/home',
    'giriş': '/login',
    'kimlik doğrulama': '/AuthKontrol',
    // YENİ ROTALAR
    'yunikaya': '/unica',
    'unica': '/unica', // Alternatif söyleniş
    'yunika': '/unica', // Alternatif söyleniş
    'akışa': '/feed',
    'akış': '/feed',
  };

  @override
  List<String> get triggers => [
        'git',
        'aç',
        'yönlendir',
        'göster',
        'geç' 
      ];

  @override
  void execute(dynamic arguments) {
    String input = arguments.toString().toLowerCase();
    
    // Hangi rotaya gitmek istediğini bul
    String? targetRoute;
    routes.forEach((key, value) {
      if (input.contains(key)) {
        targetRoute = value;
      }
    });

    if (targetRoute != null) {
      print("🚀 Navigasyon: $targetRoute rotasına gidiliyor...");
      
      // GetX Rota Yönetimi
      // Eğer zaten o sayfadaysa gitme (opsiyonel kontrol eklenebilir)
      Get.toNamed(targetRoute!);
      
    } else {
      print("⚠️ Hedef rota anlaşılamadı.");
      // Sesli geri bildirim eklenebilir
    }
  }
}
