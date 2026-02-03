import 'package:cloud_firestore/cloud_firestore.dart';

import '../fonksiyonlar/altButonlar.dart';

void sunucudanVerileriGetir(zaman, ileriZaman) {
  final timestamp =
      FirebaseFirestore.instance.collection('Kullanicilar').doc(kullanici.email).collection('oyun').doc('tarla');
  timestamp.get().then((snapshot) {
    zaman = snapshot.data()?['zaman'] as Timestamp;
    ileriZaman = snapshot.data()?['ileriZaman'] as Timestamp;
  });
  print('sunucudanVerileriGetir çalıştı');
}

// Card(
//   color: Colors.black26,
//   child: Center(
//     child: FutureBuilder<DocumentSnapshot>(
//         future: timestamp.get(),
//         builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//           if (asyncSnapshot.hasError) {
//             return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//           } else {
//             if (asyncSnapshot.hasData) {
//               dynamic unicSayisi = asyncSnapshot.data.data()['ileriZaman'];
//               DateTime dateTime = unicSayisi.toDate();
//               DateTime now = DateTime.now();
//
//               dynamic renk = dateTime.isBefore(now);
//               print(renk.toString() + ' renk buraya basılıyor');
//
//               return Text(
//                 renk.toString(),
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.red),
//               );
//             } else {
//               /// yükleniyor bölümü
//               return buildDefaultTextStyle();
//             }
//           }
//         }),
//   ),
// ),

// final kullanici = FirebaseAuth.instance.currentUser!;
// final _firestore = FirebaseFirestore.instance;
// CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
// var icerik = kullanicilar.doc(kullanici.email);
// print(zaman.toString() + ' zaman degiskeni yazıldı');
// print(ileriZaman.toString() + ' ileriZaman degiskeni yazıldı');
// var dateTimeIleri = ileriZaman.toDate();
// var formatZamanIleri = DateFormat('MM-dd-yyyy HH:mm:ss').format(dateTimeIleri);
// print(formatZamanIleri.toString() + ' formatZamanIleri degiskeni yazıldı');
// var timestamp =
//     FirebaseFirestore.instance.collection('Kullanicilar').doc(kullanici.email).collection('oyun').doc('tarla');

// void sayacCeviri() {
//   var dateTime = zaman.toDate();
//   var formatZaman = DateFormat('MM-dd-yyyy HH:mm:ss').format(dateTime);
//   print('Veri çekildi zamaniDuzenle ' + formatZaman);
//   var formatYil = DateFormat('yyyy').format(dateTime);
//   int yil = int.parse(formatYil);
//   var formatAy = DateFormat('MM').format(dateTime);
//   int ay = int.parse(formatAy);
//   var formatGun = DateFormat('dd').format(dateTime);
//   int gun = int.parse(formatGun);
//   var formatSaat = DateFormat('HH').format(dateTime);
//   int saat = int.parse(formatSaat);
//   var formatDakika = DateFormat('mm').format(dateTime);
//   int dakika = int.parse(formatDakika);
//   var formatSaniye = DateFormat('ss').format(dateTime);
//   int saniye = int.parse(formatSaniye);
//   gosterSaniye = saniye;
//   gosterDakika = dakika;
//   gosterSaat = saat;
//   gosterGun = gun;
//   gosterAy = ay;
//   gosterYil = yil;
//
//   Timer.periodic(const Duration(seconds: 1), (timer) {
//     gosterSaniye++;
//     print(gosterSaniye.toString());
//
//     if (gosterSaniye > 59) {
//       tarihSaatBas();
//       gosterDakika++;
//       print(gosterDakika.toString());
//
//       if (gosterSaniye > 59 && gosterDakika > 59) {
//         unicBas();
//         gosterSaat++;
//         print(gosterSaat.toString());
//
//         if (gosterSaniye > 59 && gosterDakika > 59 && gosterSaat > 23) {
//           gosterSaat = 0;
//           //timer.cancel();
//         }
//         gosterDakika = 0;
//       }
//       gosterSaniye = 0;
//     }
//     setState(() {});
//   });
//
//   if (gosterSaniye == 0) {
//     gosterSaniyeCeviri = '00';
//   } else if (gosterSaniye == 1) {
//     gosterSaniyeCeviri = '01';
//   } else if (gosterSaniye == 2) {
//     gosterSaniyeCeviri = '02';
//   } else if (gosterSaniye == 3) {
//     gosterSaniyeCeviri = '03';
//   } else if (gosterSaniye == 4) {
//     gosterSaniyeCeviri = '04';
//   } else if (gosterSaniye == 5) {
//     gosterSaniyeCeviri = '05';
//   } else if (gosterSaniye == 6) {
//     gosterSaniyeCeviri = '06';
//   } else if (gosterSaniye == 7) {
//     gosterSaniyeCeviri = '07';
//   } else if (gosterSaniye == 8) {
//     gosterSaniyeCeviri = '08';
//   } else if (gosterSaniye == 9) {
//     gosterSaniyeCeviri = '09';
//   } else {
//     gosterSaniyeCeviri = gosterSaniye.toString();
//   }
//   if (gosterDakika == 0) {
//     gosterDakikaCeviri = '00';
//   } else if (gosterDakika == 1) {
//     gosterDakikaCeviri = '01';
//   } else if (gosterDakika == 2) {
//     gosterDakikaCeviri = '02';
//   } else if (gosterDakika == 3) {
//     gosterDakikaCeviri = '03';
//   } else if (gosterDakika == 4) {
//     gosterDakikaCeviri = '04';
//   } else if (gosterDakika == 5) {
//     gosterDakikaCeviri = '05';
//   } else if (gosterDakika == 6) {
//     gosterDakikaCeviri = '06';
//   } else if (gosterDakika == 7) {
//     gosterDakikaCeviri = '07';
//   } else if (gosterDakika == 8) {
//     gosterDakikaCeviri = '08';
//   } else if (gosterDakika == 9) {
//     gosterDakikaCeviri = '09';
//   } else {
//     gosterDakikaCeviri = gosterDakika.toString();
//   }
//   if (gosterSaat == 0) {
//     gosterSaatCeviri = '00';
//   } else if (gosterSaat == 1) {
//     gosterSaatCeviri = '01';
//   } else if (gosterSaat == 2) {
//     gosterSaatCeviri = '02';
//   } else if (gosterSaat == 3) {
//     gosterSaatCeviri = '03';
//   } else if (gosterSaat == 4) {
//     gosterSaatCeviri = '04';
//   } else if (gosterSaat == 5) {
//     gosterSaatCeviri = '05';
//   } else if (gosterSaat == 6) {
//     gosterSaatCeviri = '06';
//   } else if (gosterSaat == 7) {
//     gosterSaatCeviri = '07';
//   } else if (gosterSaat == 8) {
//     gosterSaatCeviri = '08';
//   } else if (gosterSaat == 9) {
//     gosterSaatCeviri = '09';
//   } else {
//     gosterSaatCeviri = gosterSaat.toString();
//   }
//   if (gosterAy == 1) {
//     gosterAyCeviri = 'Ocak';
//   } else if (gosterAy == 2) {
//     gosterAyCeviri = 'Şubat';
//   } else if (gosterAy == 3) {
//     gosterAyCeviri = 'Mart';
//   } else if (gosterAy == 4) {
//     gosterAyCeviri = 'Nisan';
//   } else if (gosterAy == 5) {
//     gosterAyCeviri = 'Mayıs';
//   } else if (gosterAy == 6) {
//     gosterAyCeviri = 'Haziran';
//   } else if (gosterAy == 7) {
//     gosterAyCeviri = 'Temmuz';
//   } else if (gosterAy == 8) {
//     gosterAyCeviri = 'Ağustos';
//   } else if (gosterAy == 9) {
//     gosterAyCeviri = 'Eylül';
//   } else if (gosterAy == 10) {
//     gosterAyCeviri = 'Ekim';
//   } else if (gosterAy == 11) {
//     gosterAyCeviri = 'Kasım';
//   } else if (gosterAy == 12) {
//     gosterAyCeviri = 'Aralık';
//   } else {
//     gosterAyCeviri = '00';
//   }
// }

// Timer.periodic(const Duration(seconds: 1), (timer) {
// gosterSaniye++;
// print(gosterSaniye.toString());
//
// if (gosterSaniye > 59) {
// tarihSaatBas();
// gosterDakika++;
// print(gosterDakika.toString());
//
// if (gosterSaniye > 59 && gosterDakika > 59) {
// unicBas();
// gosterSaat++;
// print(gosterSaat.toString());
//
// if (gosterSaniye > 59 && gosterDakika > 59 && gosterSaat > 23) {
// gosterSaat = 0;
// //timer.cancel();
// }
// gosterDakika = 0;
// }
// gosterSaniye = 0;
// }
// setState(() {});
// });

bool gecmisTarih(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  DateTime now = DateTime.now();
  var varreg = dateTime.isBefore(now);
  return varreg;
}
