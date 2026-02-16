import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unicotantic/firebase_options.dart';

import 'core/utils/translate_getx.dart';
import 'core/voice/commands/navigate_command.dart';
import 'core/voice/commands/system_optimization_command.dart';
import 'core/voice/voice_controller.dart';
import 'features/ai/unica_chat_page.dart';
import 'features/auth/auth_kontrol.dart';
import 'features/auth/splash.dart';
import 'core/services/migration_service.dart'; // Import eklendi
// Sayfa Importları
import 'features/feed/akis.dart';

Future<void> main() async {
  // usePathUrlStrategy(); // Her yenilemede anasayfadan başlaması için kaldırıldı.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init(); // GetStorage başlatıldı

  // Migration Servisini Çalıştır (Tüm postlara varsayılan dil ataması yapar)
  // Gelecekte bu çağrıyı kaldırabilir veya bir admin paneline taşıyabilirsiniz.
  MigrationService().updateAllPostsLanguage();

  try {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      await Hive.initFlutter('data');
    }

    // Kilit hatası durumunda temizlik yapmak için boxları tek tek açmayı deniyoruz
    Future<void> openBoxWithRetry(String name, {HiveAesCipher? cipher}) async {
      try {
        await Hive.openBox(name, encryptionCipher: cipher);
      } catch (e) {
        debugPrint(
            "Error opening box $name: $e. Retrying after cleaning lock...");

        if (!kIsWeb) {
          try {
            // macOS/iOS/Android için kilit dosyasını temizleme denemesi
            final directory = await getApplicationDocumentsDirectory();
            final lockFile = File('${directory.path}/data/$name.lock');
            if (await lockFile.exists()) {
              await lockFile.delete();
              debugPrint("Lock file deleted: $name.lock");
              await Hive.openBox(name, encryptionCipher: cipher);
            }
          } catch (retryError) {
            debugPrint("Retry failed for $name: $retryError");
          }
        }
      }
    }

    // Şifreleme anahtarı hazırlığı
    String? encryptionKeyString;

    if (kIsWeb) {
      // Web üzerinde GetStorage kullan (MissingPluginException'ı önlemek için)
      final gStorage = GetStorage();
      encryptionKeyString = gStorage.read<String>('hive_key');
      if (encryptionKeyString == null) {
        final key = Hive.generateSecureKey();
        encryptionKeyString = base64UrlEncode(key);
        await gStorage.write('hive_key', encryptionKeyString);
      }
    } else {
      // Mobil üzerinde FlutterSecureStorage kullan
      const secureStorage = FlutterSecureStorage();
      try {
        encryptionKeyString = await secureStorage.read(key: 'hive_key');
        if (encryptionKeyString == null) {
          final key = Hive.generateSecureKey();
          await secureStorage.write(
            key: 'hive_key',
            value: base64UrlEncode(key),
          );
          encryptionKeyString = await secureStorage.read(key: 'hive_key');
        }
      } catch (e) {
        debugPrint("Secure storage error: $e");
      }
    }

    if (encryptionKeyString != null) {
      final key = base64Url.decode(encryptionKeyString);
      final encryptionCipher = HiveAesCipher(key);

      await openBoxWithRetry("unicotantic");
      await openBoxWithRetry('unica_logs', cipher: encryptionCipher);
      await openBoxWithRetry('unica_profile', cipher: encryptionCipher);
      await openBoxWithRetry('unica_thoughts', cipher: encryptionCipher);
    } else {
      await openBoxWithRetry("unicotantic");
      debugPrint(
          "Warning: Encryption key not found, some boxes might not open.");
    }
  } catch (e) {
    debugPrint("Hive initialization fatal error: $e");
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    try {
      MobileAds.instance.initialize();
    } catch (e) {
      debugPrint("MobileAds initialization failed: $e");
    }
  }

  // Akış: Voice Controller Başlatılması
  final voiceController = Get.put(VoiceController());
  voiceController.registerCommand(SystemOptimizationCommand());
  voiceController.registerCommand(NavigateCommand());
  debugPrint("🎤 Akış VoiceController başlatıldı ve komutlar kaydedildi.");

  runApp(
    ValueListenableBuilder(
      valueListenable: Hive.box(
        'unicotantic',
      ).listenable(keys: ['tema', 'karanlik_tema']),
      builder: (context, kutu, widget) {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            systemNavigationBarColor: Colors.black,
          ),
        );

        // Dil tercihini oku
        final box = GetStorage();
        String? langCode = box.read('languageCode');
        String? countryCode = box.read('countryCode');

        Locale startLocale = Get.deviceLocale ?? const Locale('en', 'US');

        if (langCode != null && countryCode != null) {
          startLocale = Locale(langCode, countryCode);
        }

        return GetMaterialApp(
          translations: Messages(),
          locale: startLocale,
          fallbackLocale: const Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
          theme: kutu.get('karanlik_tema', defaultValue: false)
              ? ThemeData.light()
              : ThemeData.dark(),
          initialRoute: '/',
          onGenerateInitialRoutes: (initialRoute) {
            return [
              GetPageRoute(
                page: () => const Splash(),
                settings: const RouteSettings(name: '/'),
              )
            ];
          },
          getPages: [
            GetPage(name: '/', page: () => const Splash()),
            GetPage(name: '/AuthKontrol', page: () => const AuthKontrol()),
            GetPage(name: '/feed', page: () => const Akis()),
            GetPage(name: '/unica', page: () => const UnicaChatPage()),
          ],
        );
      },
    ),
  );
}
//flutter clean
//flutter pub cache repair
//flutter pub get
// flutter build web --no-tree-shake-icons
//flutter build web --release --no-tree-shake-icons

//firebase deploy --only hosting
//
//"prefer_related_applications": false

// 1.Değişiklikleri Ekle: git add .
// (tüm değişiklikler için) veya git add <dosya_adı> (belirli dosyalar için)
// 2.Yorumla Commit Et: git commit -m "22 Haziran güncelleme"
// 3.Gönder: git push
// com.nesenosun.yogaberryone.macos
// com.nesenosun.yogaberryone
//firebase deploy --only hosting:unicotantic
//firebase deploy --only hosting:nesenosun
//firebase deploy --only hosting:unic-otantic-e4f32
//flutter run -d chrome --web-port=5001
