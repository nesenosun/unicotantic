import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../fonksiyonlar/altButonlar.dart';

class DakikaController extends GetxController {
  late Timestamp zaman;

  bool gecmisMiGelecekMi = true;
  bool tarihDurumu = true;
  RxString mesaj = 'Lütfen bekleyin'.obs;
  RxString saniyeCeviri = '00'.obs;
  RxString dakikaCeviri = '00'.obs;
  int saniye = 0;
  int dakika = 0;
  int sunucuyaSaniyeEkle = 35;
  int sunucuyaDakikaEkle = 0;

  void sadeceVerileriCek() {
    print(tarihDurumu.toString() + ' tarihDurumu Değişkeni ilk hali');

    final timestamp =
        FirebaseFirestore.instance.collection('Kullanicilar').doc(kullanici.email).collection('oyun').doc('tarla');
    timestamp.get().then((snapshot) {
      zaman = snapshot.data()?['zaman'] as Timestamp;
      //ileriZaman = snapshot.data()?['ileriZaman'] as Timestamp;

      if (snapshot.data() != null) {
        tarihGecmisMiGelecekMi(zaman);
        print(zaman.toString() + 'Zaman verisi başarıyla sunucudan çekildi');
      } else {
        zaman = Timestamp(1703970000, 786000000);
        mesaj.value = 'Bağlantınızı Kontrol Edin';
        print(zaman.toString() + ' Zaman sunucudan istenirken hata oldu');
      }
    });
  }

  void tarihGecmisMiGelecekMi(zaman) async {
    try {} catch (error) {
      debugPrint(error.toString());
    }
    DateTime dateTime = zaman.toDate();
    DateTime now = DateTime.now();
    var tarihDurumuGecmis = dateTime.isBefore(now);
    print(tarihDurumuGecmis.toString() + ' tarihDurumuGecmis Değişkeni ');
    if (tarihDurumuGecmis) {
      print('Geçmiş zaman');
      //gecmisMiGelecekMi = false;
    } else {
      //gecmisMiGelecekMi = true;
      gelenZamaniSimdikiZamanDanCikar(zaman);
      print('Gelecek zaman');
    }
    print('tarihGecmisMiGelecekMi çalıştı');
  }

  void gelenZamaniSimdikiZamanDanCikar(zaman) async {
    var dateTimeCevrildi = zaman.toDate();
    var dateTimeCevrildiVeFormatlandi = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeCevrildi);
    DateTime parcalandi = DateTime.parse(dateTimeCevrildiVeFormatlandi);
    Duration zamanFarki = parcalandi.difference(DateTime.now().toUtc());

    dakika = zamanFarki.inMinutes % 60;
    saniye = zamanFarki.inSeconds % 60;

    String formattedTime = '${dakika.toString().padLeft(2, '0')}:${saniye.toString().padLeft(2, '0')}';
    print('Fark: $formattedTime');
    geriSayacDakika();
  }

  void geriSayacDakika() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      saniye--;

      if (saniye <= 0 && dakika <= 0) {
        saniye = 0;
        dakika = 0;
        mesaj.value = 'KAZANDINIZ';
        timerCansel(timer);
      } else if (saniye < 0) {
        saniye = 59;

        dakika--;
      }

      print(dakika.toString() + ':' + saniye.toString());
      saniyeCevirici();
    });
  }

  void timerCansel(Timer timer) {
    timer.cancel();
  }

  void saniyeCevirici() {
    if (saniye == 0) {
      saniyeCeviri.value = '00';
    } else if (saniye == 1) {
      saniyeCeviri.value = '01';
    } else if (saniye == 2) {
      saniyeCeviri.value = '02';
    } else if (saniye == 3) {
      saniyeCeviri.value = '03';
    } else if (saniye == 4) {
      saniyeCeviri.value = '04';
    } else if (saniye == 5) {
      saniyeCeviri.value = '05';
    } else if (saniye == 6) {
      saniyeCeviri.value = '06';
    } else if (saniye == 7) {
      saniyeCeviri.value = '07';
    } else if (saniye == 8) {
      saniyeCeviri.value = '08';
    } else if (saniye == 9) {
      saniyeCeviri.value = '09';
    } else {
      saniyeCeviri.value = saniye.toString();
    }
    if (dakika == 0) {
      dakikaCeviri.value = '00';
    } else if (dakika == 1) {
      dakikaCeviri.value = '01';
    } else if (dakika == 2) {
      dakikaCeviri.value = '02';
    } else if (dakika == 3) {
      dakikaCeviri.value = '03';
    } else if (dakika == 4) {
      dakikaCeviri.value = '04';
    } else if (dakika == 5) {
      dakikaCeviri.value = '05';
    } else if (dakika == 6) {
      dakikaCeviri.value = '06';
    } else if (dakika == 7) {
      dakikaCeviri.value = '07';
    } else if (dakika == 8) {
      dakikaCeviri.value = '08';
    } else if (dakika == 9) {
      dakikaCeviri.value = '09';
    } else {
      dakikaCeviri.value = dakika.toString();
    }
  }

  void ilerikiZamanBas() async {
    saniye = sunucuyaSaniyeEkle;
    dakika = sunucuyaDakikaEkle;
    gecmisMiGelecekMi = true;

    geriSayacDakika();
    DateTime suankiZaman = DateTime.now();
    mesaj.value = 'Oyun başladı';

    Duration sure = Duration(days: 0, hours: 0, minutes: sunucuyaDakikaEkle, seconds: sunucuyaSaniyeEkle);
    DateTime ilerikiZaman = suankiZaman.add(sure);
    Timestamp timestamp = Timestamp.fromDate(ilerikiZaman);

    await FirebaseFirestore.instance
        .collection('Kullanicilar')
        .doc(kullanici.email)
        .collection('oyun')
        .doc('tarla')
        .update({'zaman': timestamp});

    print('İleriki zaman başarıyla yazıldı!');
  }
}
