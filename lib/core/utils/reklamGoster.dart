import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/features/profile/site.dart';

import '../../features/feed/anasayfa.dart';
import '../../features/feed/doluAkisAppBar.dart';

class ReklamGoster extends StatefulWidget {
  const ReklamGoster({super.key});

  @override
  State<ReklamGoster> createState() => _ReklamGosterState();
}

class _ReklamGosterState extends State<ReklamGoster> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  //final contrReklam = Get.put(ControllerReklam());

  final puanSa = Hive.box('unicotantic');
  RewardedAd? rewardedAd;

  Future<dynamic> unicEkle() async {
    CollectionReference kullanicilar = _firestore.collection('users');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic unic = map['unic'];

    await FirebaseFirestore.instance
        .collection("users")
        .doc(kullanici.email)
        .update({'unic': FieldValue.increment(50)});
    return unic;
  }

  void disposeAds() {
    rewardedAd?.dispose();
  }

  Future<dynamic> unicCikar() async {
    CollectionReference kullanicilar = _firestore.collection('users');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic unic = map['unic'];

    await FirebaseFirestore.instance
        .collection("users")
        .doc(kullanici.email)
        .update(unic >= 1 ? {"unic": FieldValue.increment(-1)} : {"unic": 0});
    return unic;
  }

  void showRewardedAd() {
    if (rewardedAd != null) {
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedAd ad) {
        if (kDebugMode) {
          print("Reklamda GösterilenTam Ekran İçeriğinde Reklam");
        }
      }, onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        loadRewardedAd();
      }, onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        loadRewardedAd();
      });

      rewardedAd!.setImmersiveMode(true);
      rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        unicEkle();

        Get.off(const Anasayfa());
      });
    }
  }

  void reklam() {
    Get.defaultDialog(
      title: "Bir Reklam".tr,
      //middleText: "Hello world!",
      backgroundColor: Colors.deepPurple[200],
      titleStyle: TextStyle(color: Colors.black87, fontSize: 22),

      //textConfirm: "Sesi Kapat",

      cancelTextColor: Colors.white,
      confirmTextColor: Colors.white,
      buttonColor: Colors.blueAccent,
      barrierDismissible: true,
      radius: 8,
      content: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                'Puanınız (Unic) bittiği zaman 1 Reklam izleyerek, 50 Unic kazanabilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: "Montserrat",
                    color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Get.back();
                showRewardedAd();
                //oyunBasladi = false;
              },
              child: Column(
                children: [
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: SizedBox(
                          height: 100,
                          width: 120,
                          child:
                              Image.asset("assets/images/jpg/birReklam.jpg")),
                    ),
                  ),
                  Text(
                    'İzliyim Bağri',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: "Montserrat",
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loadRewardedAd() {
    RewardedAd.load(

        ///kuukuk
        //adUnitId: "ca-app-pub-0034228901133766/9314838928",
        adUnitId: "ca-app-pub-0034228901133766/6384730666",
        request: const AdRequest(),
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          rewardedAd = ad;
        }, onAdFailedToLoad: (LoadAdError error) {
          rewardedAd = null;
        }));
  }

  @override
  void initState() {
    loadRewardedAd();
    //reklam();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: akisAppBar(),
      drawer: Site(),
      body: Center(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  'Puanınız (Unic) bittiği zaman 1 Reklam izleyerek, 50 Unic kazanabilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      fontFamily: "Montserrat",
                      color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  //Get.back();
                  showRewardedAd();
                },
                child: Column(
                  children: [
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: SizedBox(
                            height: 100,
                            width: 120,
                            child:
                                Image.asset("assets/images/jpg/birReklam.jpg")),
                      ),
                    ),
                    Text(
                      'İzliyim Bağri',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          fontFamily: "Montserrat",
                          color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
