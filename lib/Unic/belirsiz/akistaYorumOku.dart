// import 'dart:io';
// import 'dart:math';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:hive/hive.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:unicotantic/Unic/doluAkis/doluYorumOku.dart';
//
// import '../fonksiyonlar/oyun_controller.dart';
//
// class AkisYorumOku extends StatefulWidget {
//   const AkisYorumOku({Key? key}) : super(key: key);
//
//   @override
//   State<AkisYorumOku> createState() => _AkisYorumOkuState();
// }
//
// class _AkisYorumOkuState extends State<AkisYorumOku> {
//   final kullanici = FirebaseAuth.instance.currentUser!;
//   final _firestore = FirebaseFirestore.instance;
//   TextEditingController yorumController = TextEditingController();
//
//   final box = GetStorage();
//   final controller = Get.put(PuanC());
//   double gozetop = Get.height / 5;
//   double gozeleft = Get.width / 4;
//   GetStorage getbox = GetStorage();
//   String alinanDosya = 'assets/images/png/dactylo.png';
//   String galeri = '......';
//   late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
//   String? indirmeBaglantisi;
//   final puanSa = Hive.box('unicotantic');
//
//   Future<dynamic> unicCikar() async {
//     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//     var icerik = kullanicilar.doc(kullanici.email);
//     var secim = await icerik.get();
//     dynamic map = secim.data();
//
//     dynamic unic = map['unic'];
//
//     await FirebaseFirestore.instance
//         .collection("Kullanicilar")
//         .doc(kullanici.email)
//         .update(unic >= 1 ? {"unic": FieldValue.increment(-1)} : {"unic": 0});
//     return unic;
//   }
//
//   // Rastgele benzersiz sayı üretmek için kullanılacak fonksiyon
//   String generateRandomNumber() {
//     Random random = Random();
//     int randomNumber = random.nextInt(1000000);
//     return randomNumber.toString();
//   }
//
//   yorumEkle() async {
//     //String postID = generateRandomNumber();
//
//     String getfoto = getbox.read("postFotolinki");
//
//     String metino = yorumController.text;
//     String puansaPostAydi = puanSa.get('postAydi');
//     String puansaEmail = puanSa.get('email');
//     print(puansaEmail + ' nedersin');
//
//     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//     var icerik = kullanicilar.doc(kullanici.email);
//     var secim = await icerik.get();
//     dynamic map = secim.data();
//
//     dynamic khakkinda = map['hakkinda'];
//     dynamic ksehir = map['sehir'];
//     dynamic kisim = map['isim'];
//     dynamic ksoyisim = map['soyisim'];
//     dynamic kiletisim = map['iletisim'];
//     dynamic kdogumtarihi = map['dogum tarihi'];
//     dynamic profilresmilinki = map['profilresmilinki'];
//     icerik.update({'postSayisi': FieldValue.increment(1)});
//     var dtNow = DateTime.now();
//
//     var yil = DateTime.now().year;
//     var ay = DateTime.now().month;
//     var gun = DateTime.now().day;
//     var saat = DateTime.now().hour;
//     var dakika = DateTime.now().minute;
//     //dynamic unic = map['unic'];
//
//     CollectionReference kullanicilar1 = _firestore.collection('Kullanicilar');
//     var icerik1 = kullanicilar1.doc(puanSa.get('email'));
//     var secim1 = await icerik1.get();
//     dynamic map1 = secim1.data();
//
//     dynamic unic = map1['unic'];
//     await icerik1.update({'bildirim': FieldValue.increment(1)});
//
//     await FirebaseFirestore.instance.collection("yorumlar").doc(puansaPostAydi).collection("yorumlar").doc().set({
//       'id': kullanici.uid,
//       'postAydi': puansaPostAydi.toString(),
//       "email": kullanici.email.toString(),
//       'isim': kisim,
//       'soyisim': ksoyisim,
//       'sehir': ksehir,
//       'dogum tarihi': kdogumtarihi,
//       'hakkinda': khakkinda,
//       'iletisim': kiletisim,
//       'metin': metino,
//       'zaman': DateTime.now(),
//       'begen': [],
//       'yorumSayisi': 0,
//       'bildirim': 1,
//       'begenMe': [],
//       'mapYorum': [],
//       'profilresmilinki': profilresmilinki.toString(),
//       'tarih': '$gun / ' + '$ay / ' + '$yil    ' + '$saat :' + ' $dakika ',
//       'postFotolinki': getfoto.toString(),
//     });
//     await FirebaseFirestore.instance.collection("yorumaYorum").doc().set({
//       'id': kullanici.uid,
//       'postAydi': puansaPostAydi.toString(),
//       "email": kullanici.email.toString(),
//       'isim': kisim,
//       'soyisim': ksoyisim,
//       'sehir': ksehir,
//       'dogum tarihi': kdogumtarihi,
//       'hakkinda': khakkinda,
//       'iletisim': kiletisim,
//       'metin': metino,
//       'zaman': DateTime.now(),
//       'begen': [],
//       'yorumSayisi': 0,
//       'bildirim': 1,
//       'begenMe': [],
//       'mapYorum': [],
//       'profilresmilinki': profilresmilinki.toString(),
//       'tarih': '$gun / ' + '$ay / ' + '$yil    ' + '$saat :' + ' $dakika ',
//       'postFotolinki': getfoto.toString(),
//     });
//
//     await FirebaseFirestore.instance
//         .collection("postlar")
//         .doc(puansaPostAydi)
//         .update({'yorumSayisi': FieldValue.increment(1)});
//
//     await FirebaseFirestore.instance
//         .collection("postlar")
//         .doc(puansaPostAydi)
//         .update({'bildirim': FieldValue.increment(1)});
//
//     if (puansaEmail != kullanici.email) {
//       icerik1.update({'unic': FieldValue.increment(1)});
//     }
//
//     //}
//     galeri = '......';
//   }
//
//   @override
//   void initState() {
//     // FirebaseFirestore.instance.collection("postlar").doc(puanSa.get('postAydi')).update({'bildirim': 0});
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Query akisSorguy = _firestore.collection('yorumaYorum').orderBy("zaman", descending: false);
//     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//     var kullaniciIcerik = kullanicilar.doc(kullanici.email);
//     return SafeArea(
//       child: Scaffold(
//           body: Center(
//         child: Stack(
//           children: [
//             DoluYorumOku(),
//             Positioned(
//               top: gozetop,
//               left: gozeleft,
//               child: GestureDetector(
//                 onPanUpdate: (details) {
//                   setState(() {
//                     gozetop = max(-300, gozetop + details.delta.dy);
//                     gozeleft = max(-200, gozeleft + details.delta.dx);
//                   });
//                 },
//                 child: SizedBox(
//                   height: 300,
//                   width: 300,
//                   child: Obx(
//                     () => GestureDetector(
//                       onTap: () async {
//                         getbox.write('postFotolinki', 'bos');
//                         var secim = await kullaniciIcerik.get();
//                         dynamic map = secim.data();
//
//                         dynamic unic = map['unic'];
//
//                         if (unic <= 0) {
//                           controller.acilGoze = false.obs;
//                         } else {
//                           setState(() {
//                             controller.acilGoze = true.obs;
//                           });
//                         }
//                       },
//                       child: Wrap(children: [
//                         if (controller.acilGoze == true.obs)
//                           Center(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Center(
//                                   child: GestureDetector(
//                                       onTap: () async {
//                                         setState(() async {
//                                           if (yorumController.text.isNotEmpty) {
//                                             //kullaniciBilgileriEkle();
//
//                                             var secim = await kullaniciIcerik.get();
//                                             dynamic map = secim.data();
//
//                                             dynamic unic = map['unic'];
//
//                                             if (unic <= 0) {
//                                             } else {
//                                               unicCikar();
//                                               yorumEkle();
//                                               getbox.write('postFotolinki', 'bos');
//                                               galeri = '......';
//                                               setState(() {});
//                                             }
//                                           } else {
//                                             FocusScope.of(context).requestFocus(FocusNode());
//                                             controller.acilGoze = false.obs;
//                                           }
//
//                                           yorumController.clear();
//                                         });
//                                       },
//                                       child: SizedBox(
//                                         width: 150,
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.center,
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.all(2.0),
//                                               child: SizedBox(
//                                                   height: 40,
//                                                   width: 50,
//                                                   child: GestureDetector(
//                                                     onTap: () {
//                                                       galeridenYukle();
//                                                       galeri = '......';
//                                                       setState(() {});
//                                                     },
//                                                     child: Padding(
//                                                       padding: const EdgeInsets.all(8.0),
//                                                       child: Image.asset(
//                                                         'assets/images/png/gallery.png',
//                                                         fit: BoxFit.cover,
//                                                       ),
//                                                     ),
//                                                   )),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.all(8.0),
//                                               child: SizedBox(
//                                                   height: 40,
//                                                   width: 50,
//                                                   child: Image.asset(
//                                                     'assets/images/png/unic.png',
//                                                     fit: BoxFit.cover,
//                                                   )),
//                                             ),
//                                           ],
//                                         ),
//                                       )),
//                                 ),
//                                 Center(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       controller.acilGoze = false.obs;
//                                       setState(() {});
//                                     },
//                                     // kapatma ikonu koyulabilir
//                                     child: SizedBox(
//                                       height: 300,
//                                       child: Center(
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                                           child: Column(
//                                             children: [
//                                               Card(
//                                                 color: Colors.black87,
//                                                 child: TextField(
//                                                     onSubmitted: (value) {
//                                                       if (value.isEmpty) {
//                                                         //  kullaniciBilgileriEkle();
//                                                         yorumEkle();
//                                                         galeri = '......';
//                                                       } else {
//                                                         controller.acilGoze = false.obs;
//                                                         setState(() {});
//                                                       }
//                                                     },
//                                                     maxLength: 120,
//                                                     maxLines: 2,
//                                                     controller: yorumController,
//                                                     decoration: InputDecoration(
//                                                       focusColor: Colors.cyanAccent,
//                                                       //add prefix icon
//
//                                                       border: OutlineInputBorder(
//                                                         borderRadius: BorderRadius.circular(10.0),
//                                                       ),
//
//                                                       focusedBorder: OutlineInputBorder(
//                                                         borderSide: const BorderSide(color: Colors.cyan, width: 1.0),
//                                                         borderRadius: BorderRadius.circular(10.0),
//                                                       ),
//                                                       fillColor: Colors.cyanAccent,
//
//                                                       //make hint text
//                                                       hintStyle: const TextStyle(
//                                                         color: Colors.cyan,
//                                                         fontSize: 18,
//                                                         fontFamily: "verdana_regular",
//                                                         fontWeight: FontWeight.w400,
//                                                       ),
//
//                                                       //create lable
//                                                       labelText: galeri.toString(),
//                                                       //lable style
//                                                       labelStyle: const TextStyle(
//                                                         textBaseline: TextBaseline.alphabetic,
//                                                         color: Colors.cyan,
//                                                         fontSize: 18,
//                                                         fontFamily: "verdana_regular",
//                                                         fontWeight: FontWeight.w400,
//                                                       ),
//                                                     )),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         if (controller.acilGoze == false.obs)
//                           Center(
//                             child: Card(
//                               color: Colors.black45,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: SizedBox(
//                                     height: 30,
//                                     width: 50,
//                                     child: Image.asset(
//                                       alinanDosya,
//                                       fit: BoxFit.cover,
//                                     )),
//                               ),
//                             ),
//                           ),
//                       ]),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       )),
//     );
//   }
//
//   galeridenYukle() async {
//     // ignore: deprecated_member_use
//     var alinanDosya = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 30);
//     setState(() {
//       yuklenecekDosya = File(alinanDosya!.path);
//     });
//
//     // Seçilen resmi okuyun
//     File resimDosyasi = File(alinanDosya!.path);
//
// // Resmin boyutunu alın
//     int boyut = await resimDosyasi.length();
//     print('Resim Boyutu: $boyut byte');
//     // Maksimum boyut sınırlaması (örneğin, 2 MB)
//     const maksimumBoyut = 2 * 1024 * 1024; // 2 MB
//     print('maksimum buyuat : ' + maksimumBoyut.toString());
//
//     if (boyut > maksimumBoyut) {
//       print('Resim çok büyük, yeniden boyutlandırın veya işlem yapın');
//
//       galeri = 'Dosya Boyutu Çok Büyük!';
//
//       //Get.to(const VideoApp());
//
//       // Resim çok büyük, yeniden boyutlandırın veya işlem yapın
//       // Örnek: Resmi yeniden boyutlandırma işlemi için flutter_image_compress veya başka bir paket kullanabilirsiniz.
//     } else {
//       Reference referansYol = FirebaseStorage.instance
//           .ref()
//           .child('postFotoları')
//           .child(kullanici.email.toString())
//           .child('${DateTime.now().microsecondsSinceEpoch}postFoto.png');
//       UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
//       String url = await (await yuklemeGorevi).ref.getDownloadURL();
//       setState(() {
//         indirmeBaglantisi = url;
//         getbox.write('postFotolinki', indirmeBaglantisi.toString());
//         galeri = 'Yüklendi.. ileti girin.';
//       });
//     }
//   }
// }
//
// ///
// ///
// ///
// ///
