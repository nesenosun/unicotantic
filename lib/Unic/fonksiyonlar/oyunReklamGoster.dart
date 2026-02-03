// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:unicotantic/Unic/oyun/oyunSplash.dart';
//
// import '../doluAkis/doluAkisAppBar.dart';
// import '../profil/BenDrawer.dart';
//
// class OyunReklamGoster extends StatefulWidget {
//   final gelenMaden;
//
//   OyunReklamGoster({required this.gelenMaden});
//
//   @override
//   State<OyunReklamGoster> createState() => _OyunReklamGosterState();
// }
//
// class _OyunReklamGosterState extends State<OyunReklamGoster> {
//   final kullanici = FirebaseAuth.instance.currentUser!;
//   final _firestore = FirebaseFirestore.instance;
//
//   final puanSa = Hive.box('unicotantic');
//   RewardedAd? rewardedAd;
//
//   Future<dynamic> gelenMadenEkle() async {
//     await FirebaseFirestore.instance
//         .collection("Kullanicilar")
//         .doc(kullanici.email)
//         .collection('oyun')
//         .doc('uzay')
//         .update({widget.gelenMaden.toString(): FieldValue.increment(50)});
//   }
//
//   void disposeAds() {
//     rewardedAd?.dispose();
//   }
//
//   void showRewardedAd() {
//     if (rewardedAd != null) {
//       rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(onAdShowedFullScreenContent: (RewardedAd ad) {
//         if (kDebugMode) {
//           print("Reklamda GösterilenTam Ekran İçeriğinde Reklam");
//         }
//       }, onAdDismissedFullScreenContent: (RewardedAd ad) {
//         ad.dispose();
//         loadRewardedAd();
//       }, onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
//         ad.dispose();
//         loadRewardedAd();
//       });
//
//       rewardedAd!.setImmersiveMode(true);
//       rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
//         gelenMadenEkle();
//
//         Get.off(const OyunSplash());
//       });
//     }
//   }
//
//   void loadRewardedAd() {
//     RewardedAd.load(
//
//         ///kuukuk
//         //adUnitId: "ca-app-pub-0034228901133766/9314838928",
//         adUnitId: "ca-app-pub-0034228901133766/6384730666",
//         request: const AdRequest(),
//         rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
//           rewardedAd = ad;
//         }, onAdFailedToLoad: (LoadAdError error) {
//           rewardedAd = null;
//         }));
//   }
//
//   @override
//   void initState() {
//     loadRewardedAd();
//     //reklam();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String gelenMadenDegiskeni = widget.gelenMaden.toString();
//     gelenMadenDegiskeni == 'zirh' ? gelenMadenDegiskeni = 'Zırhınız' : '';
//     gelenMadenDegiskeni == 'enerji' ? gelenMadenDegiskeni = 'Enerjiniz' : '';
//     gelenMadenDegiskeni == 'silah' ? gelenMadenDegiskeni = 'Silahınız' : '';
//
//     return Scaffold(
//       appBar: DoluAkisAppBar(),
//       drawer: const BenDrawer(),
//       body: Center(
//         child: SizedBox(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(18.0),
//                 child: Text(
//                   gelenMadenDegiskeni + ' çok zayıfladı, 1 reklam izleyerek onu +50 güçlendirebilirsiniz!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 24, fontFamily: "Montserrat", color: Colors.white70),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               GestureDetector(
//                 onTap: () {
//                   //Get.back();
//                   showRewardedAd();
//                 },
//                 child: Column(
//                   children: [
//                     Card(
//                       elevation: 5,
//                       child: Padding(
//                         padding: const EdgeInsets.all(3.0),
//                         child: SizedBox(height: 100, width: 120, child: Image.asset("assets/images/jpg/birReklam.jpg")),
//                       ),
//                     ),
//                     Text(
//                       'İzliyim Bağri',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 24, fontFamily: "Montserrat", color: Colors.white70),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
