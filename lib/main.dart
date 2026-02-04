import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grock/grock.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/voice/voice_controller.dart';
import 'core/voice/commands/system_optimization_command.dart';
import 'core/voice/commands/navigate_command.dart';

import 'Unic/fonksiyonlar/serviceDart.dart';
import 'Unic/fonksiyonlar/translate_getx.dart';
import 'login/splash.dart';
// Sayfa Importları
import 'akis/feed.dart'; 
import 'Unic/yapayZeka/unica_chat_page.dart';

import 'Unic/zaman/zamanBildirimi.dart';
import 'firebase_options.dart';
import 'login/auth_kontrol.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await Hive.initFlutter('data');

    // Kilit hatası durumunda temizlik yapmak için boxları tek tek açmayı deniyoruz
    Future<void> openBoxWithRetry(String name) async {
      try {
        await Hive.openBox(name);
      } catch (e) {
        debugPrint(
            "Error opening box $name: $e. Retrying after cleaning lock...");
        try {
          // macOS/iOS/Android için kilit dosyasını temizleme denemesi
          final directory = await getApplicationDocumentsDirectory();
          final lockFile = File('${directory.path}/data/$name.lock');
          if (await lockFile.exists()) {
            await lockFile.delete();
            debugPrint("Lock file deleted: $name.lock");
            await Hive.openBox(name);
          }
        } catch (retryError) {
          debugPrint("Retry failed for $name: $retryError");
        }
      }
    }

    await openBoxWithRetry("unicotantic");
    await openBoxWithRetry('unica_logs');
    await openBoxWithRetry('unica_profile');
    await openBoxWithRetry('unica_thoughts');
  } catch (e) {
    debugPrint("Hive initialization fatal error: $e");
  }

  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      MobileAds.instance.initialize();
    } catch (e) {
      debugPrint("MobileAds initialization failed: $e");
    }
  }

  FirebaseNotification().connectNotifi();
  await NotificationService.initializeNotification();
  tz.initializeTimeZones();
  await GetStorage.init();

  // Akış: Voice Controller Başlatılması
  final voiceController = Get.put(VoiceController());
  voiceController.registerCommand(SystemOptimizationCommand());
  voiceController.registerCommand(NavigateCommand());
  print("🎤 Akış VoiceController başlatıldı ve komutlar kaydedildi.");


  runApp(
    ValueListenableBuilder(
      valueListenable: Hive.box(
        'unicotantic',
      ).listenable(keys: ['tema', 'karanlik_tema']),
      builder: (context, kutu, widget) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            systemNavigationBarColor: Colors.black,
          ),
        );

        return GetMaterialApp(
          translations: Messages(),
          navigatorKey: Grock.navigationKey,
          scaffoldMessengerKey: Grock.scaffoldMessengerKey,
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
          theme: kutu.get('karanlik_tema', defaultValue: false)
              ? ThemeData.light()
              : ThemeData.dark(),
          home: Splash(),
          getPages: [
            GetPage(name: '/AuthKontrol', page: () => const AuthKontrol()),
            GetPage(name: '/feed', page: () => const FeedSayfasi()), // Akış
            GetPage(name: '/unica', page: () => const UnicaChatPage()), // Unica AI
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
