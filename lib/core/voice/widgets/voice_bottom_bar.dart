
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
// import '../voice_controller.dart'; // COMMENTED FOR WEB BUILD
import '../../../akis/feed.dart';
import '../../../profil/kullanici_profil_sayfasi.dart';
import '../../../Unic/yapayZeka/unica_chat_page.dart';

enum VoiceBottomBarTab {
  home,
  profile,
  none, // Chat gibi başka sayfalardaysak
}

/// Akış Projesi - Alt Bar (Bottom Bar)
/// Ortada Unica AI butonu
class VoiceBottomBar extends StatelessWidget {
  final VoiceBottomBarTab currentTab;

  const VoiceBottomBar({
    Key? key,
    this.currentTab = VoiceBottomBarTab.none,
  }) : super(key: key);

  void _navigateTo(VoiceBottomBarTab tab) {
    if (tab == currentTab) return;

    if (tab == VoiceBottomBarTab.home) {
      Get.offAll(() => const FeedSayfasi(), transition: Transition.fadeIn);
    } else if (tab == VoiceBottomBarTab.profile) {
      Get.to(() => const KullaniciProfilSayfasi(), transition: Transition.fadeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final VoiceController voiceController = Get.find<VoiceController>(); // COMMENTED FOR WEB BUILD

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dinlenen Metin Alanı - COMMENTED FOR WEB BUILD
        /* 
        Obx(() {
          if (voiceController.isListening.value ||
              voiceController.isProcessing.value ||
              (voiceController.recognizedText.value.isNotEmpty)) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Text(
                voiceController.recognizedText.value.isEmpty
                    ? (voiceController.isProcessing.value
                        ? "İşleniyor..."
                        : "Dinliyorum...")
                    : voiceController.recognizedText.value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        */

        // Alt Bar Gövdesi
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sol Butonlar (Home)
              IconButton(
                onPressed: () => _navigateTo(VoiceBottomBarTab.home),
                icon: Icon(
                  Iconsax.home,
                  color: currentTab == VoiceBottomBarTab.home
                      ? Colors.cyanAccent
                      : Colors.grey,
                ),
              ),
              
              // UNICA AI BUTONU (ORTA) - Mikrofon yerine
              GestureDetector(
                onTap: () => Get.to(() => const UnicaChatPage()),
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyanAccent.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.cyanAccent,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.cyanAccent,
                    size: 32,
                  ),
                ),
              ),

              // Sağ Butonlar (Profile)
              IconButton(
                onPressed: () => _navigateTo(VoiceBottomBarTab.profile),
                icon: Icon(
                  Iconsax.user,
                  color: currentTab == VoiceBottomBarTab.profile
                      ? Colors.cyanAccent
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
