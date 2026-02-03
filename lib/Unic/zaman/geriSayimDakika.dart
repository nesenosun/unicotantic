import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../fonksiyonlar/altButonlar.dart';

class GeriSayimDakika extends StatefulWidget {
  const GeriSayimDakika({super.key});

  @override
  State<GeriSayimDakika> createState() => _GeriSayimDakikaState();
}

class _GeriSayimDakikaState extends State<GeriSayimDakika> {
  late Timestamp zaman;
  bool gecmisMiGelecekMi = true;
  String mesaj = 'Çalışma sürüyor';
  int saniyeBas = 6;
  int dakikaBas = 2;

  int saniye = 0;
  var saniyeCeviri = '00';
  int dakika = 0;
  var dakikaCeviri = '00';

  @override
  void initState() {
    super.initState();
    sadeceVerileriCek();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Card(
            child: SizedBox(
              width: 700,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.yellow,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Text(dakikaCeviri.toString() + ' : ' + saniyeCeviri.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 125,
                                color: Colors.black87,
                              )),
                        ),
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      mesaj = 'Çalışma sürüyor';
                      ilerikiZamanBas();
                    },
                    child: Text('Sureyi Başlat',
                        style: TextStyle(
                          fontFamily: 'Madimi',
                          fontSize: 24,
                          color: mesaj == 'Süreyi Başlat' ? Colors.green : Colors.yellow,
                        )),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.black12,
                      child: Center(
                        child: Text(mesaj.toString(),
                            style: TextStyle(
                              fontFamily: 'Madimi',
                              fontSize: mesaj == 'KAZANDINIZ' ? 84 : 45,
                              color: mesaj == 'KAZANDINIZ' ? Colors.green : Colors.yellow,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void ilerikiZamanBas() async {
    saniye = saniyeBas;
    dakika = dakikaBas;
    gecmisMiGelecekMi = true;
    geriSayacDakika();

    DateTime suankiZaman = DateTime.now();
    Duration sure = Duration(days: 0, hours: 0, minutes: dakikaBas, seconds: saniyeBas);
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

  void geriSayacDakika() {
    if (gecmisMiGelecekMi == true) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        saniye--;
        print(saniye.toString());

        if (saniye < 0) {
          dakika--;
          print(dakika.toString());
          if (saniye < 0 && dakika < 0) {
            dakika = 0;
            saniye = 0;
            mesaj = 'KAZANDINIZ';
            timer.cancel();
          } else {
            saniye = 59;
          }
        }
        dakikaCevirici();
        setState(() {});
      });
    }
  }

  void dakikaCevirici() {
    if (saniye == 0) {
      saniyeCeviri = '00';
    } else if (saniye == 1) {
      saniyeCeviri = '01';
    } else if (saniye == 2) {
      saniyeCeviri = '02';
    } else if (saniye == 3) {
      saniyeCeviri = '03';
    } else if (saniye == 4) {
      saniyeCeviri = '04';
    } else if (saniye == 5) {
      saniyeCeviri = '05';
    } else if (saniye == 6) {
      saniyeCeviri = '06';
    } else if (saniye == 7) {
      saniyeCeviri = '07';
    } else if (saniye == 8) {
      saniyeCeviri = '08';
    } else if (saniye == 9) {
      saniyeCeviri = '09';
    } else {
      saniyeCeviri = saniye.toString();
    }
    if (dakika == 0) {
      dakikaCeviri = '00';
    } else if (dakika == 1) {
      dakikaCeviri = '01';
    } else if (dakika == 2) {
      dakikaCeviri = '02';
    } else if (dakika == 3) {
      dakikaCeviri = '03';
    } else if (dakika == 4) {
      dakikaCeviri = '04';
    } else if (dakika == 5) {
      dakikaCeviri = '05';
    } else if (dakika == 6) {
      dakikaCeviri = '06';
    } else if (dakika == 7) {
      dakikaCeviri = '07';
    } else if (dakika == 8) {
      dakikaCeviri = '08';
    } else if (dakika == 9) {
      dakikaCeviri = '09';
    } else {
      dakikaCeviri = dakika.toString();
    }
  }

  void gelenZamaniSimdikiZamanDanCikar(zaman) async {
    var dateTime = zaman.toDate();
    var formatZaman = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    DateTime serverTime = DateTime.parse(formatZaman);

    Duration difference = serverTime.difference(DateTime.now().toUtc());

    print('saniyeler: ${difference.inSeconds}');
    print('Dakikalar: ${difference.inMinutes}');

    saniye = difference.inSeconds % 60;
    print('Seconds formatına çevrilmiş ' + saniye.toString());

    dakika = difference.inMinutes % 60;
    print('Minut formatına çevrilmiş ' + dakika.toString());

    String formattedTime = '${dakika.toString().padLeft(2, '0')}:${saniye.toString().padLeft(2, '0')}';

    print('Fark: $formattedTime');

    geriSayacDakika();

    setState(() {});
  }

  void tarihGecmisMiGelecekMi(zaman) async {
    DateTime dateTime = zaman.toDate();
    DateTime now = DateTime.now();
    var tarihDurumu = dateTime.isBefore(now);
    if (tarihDurumu) {
      print('Tarih geçmişe ait.');
      gecmisMiGelecekMi = false;
    } else {
      gecmisMiGelecekMi = true;
      gelenZamaniSimdikiZamanDanCikar(zaman);
      print('Tarih geleceğe ait.');
    }
    setState(() {});

    print('tarihGecmisMiGelecekMi çalıştı');
  }

  sadeceVerileriCek() {
    final timestamp =
        FirebaseFirestore.instance.collection('Kullanicilar').doc(kullanici.email).collection('oyun').doc('tarla');
    timestamp.get().then((snapshot) {
      zaman = snapshot.data()?['zaman'] as Timestamp;
      //ileriZaman = snapshot.data()?['ileriZaman'] as Timestamp;

      if (snapshot.exists) {
        tarihGecmisMiGelecekMi(zaman);
        print(zaman.toString() + ' Zaman sadece verileri çek bölümü 2');
      } else {
        print(zaman.toString() + ' Zaman sadece verileri çek bölümü 1');
        zaman = Timestamp(1703970000, 786000000);
        mesaj = 'Bağlantınızı Kontrol Edin';
      }

      setState(() {});
    });
  }
}
