// import 'dart:io';
// import 'dart:math';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:unicotantic/Unic/fonksiyonlar/altButonlar.dart';
// import 'package:video_compress/video_compress.dart';
//
// import '../fonksiyonlar/oyun_controller.dart';
//
// class BaskasininAkisaMetinGir extends StatefulWidget {
//   String gelenKullaniciEmail;
//
//   BaskasininAkisaMetinGir({required this.gelenKullaniciEmail});
//
//   @override
//   State<BaskasininAkisaMetinGir> createState() => _BaskasininAkisaMetinGirState();
// }
//
// class _BaskasininAkisaMetinGirState extends State<BaskasininAkisaMetinGir> {
//   //IsimC isimCtrl = Get.put(IsimC());
//   final kullanici = FirebaseAuth.instance.currentUser!;
//   late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
//   late File yuklenecekgetThumbnailDosya = 'assets/images/icon/icon256.png' as File;
//   String? indirmeBaglantisi;
//   String? indirmeBaglantisiThumbnail;
//
//   final _firestore = FirebaseFirestore.instance;
//   TextEditingController metinController = TextEditingController();
//   TextEditingController baslikController = TextEditingController();
//   final box = GetStorage();
//   final controller = Get.put(PuanC());
//   double gozetop = Get.height / 5;
//   double gozeleft = Get.width / 4;
//   GetStorage getbox = GetStorage();
//   String alinanDosya = 'assets/images/png/dactylo.png';
//   String alinanDosyaVideo = 'assets/images/png/dactylo.png';
//   String galeri = '.....';
//
//   galeridenYukle() async {
//     // ignore: deprecated_member_use
//     var alinanDosya = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 40);
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
//     const maksimumBoyut = 4 * 1024 * 1024; // 2 MB
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
//
//   compressVideoFile(String alinanDosyaVideo) async {
//     final compressVideoFilePath = await VideoCompress.compressVideo(alinanDosyaVideo, quality: VideoQuality.LowQuality);
//     return compressVideoFilePath!.file;
//   }
//
//   galeridenVideoYukle() async {
//     // ignore: deprecated_member_use
//     var alinanDosyaVideo = await ImagePicker().pickVideo(
//       source: ImageSource.gallery,
//       maxDuration: Duration(seconds: 60),
//     );
//     setState(() {
//       galeri = 'Video yükleniyor';
//     });
//
//     var compressVideoFilePath =
//         await VideoCompress.compressVideo(alinanDosyaVideo!.path, quality: VideoQuality.LowQuality);
//     var compressVideoFilePathFile = compressVideoFilePath!.file;
//
//     ///
//     var getThumbnail = await VideoCompress.getFileThumbnail(alinanDosyaVideo.path);
//     print('ryyjyrj yjy5 k5e5yk yksy kuyk dyk sytkdytkdt kdtktkktkk tkdt y' + getThumbnail.toString());
//
//     setState(() {
//       galeri = 'Video yükleniyor...';
//
//       yuklenecekDosya = File(compressVideoFilePathFile!.path);
//       yuklenecekgetThumbnailDosya = File(getThumbnail!.path);
//     });
//
//     // Seçilen resmi okuyun
//     File alinanDosyaVideoBoyut = File(alinanDosyaVideo!.path);
//
//     /// Resmin boyutunu alın
//
//     int boyut = await alinanDosyaVideoBoyut.length();
//     int yuklenecekDosyab = await yuklenecekDosya.length();
//     print('Video Boyutu alinanDosyaVideo: $boyut byte');
//     print('Video Boyutu yuklenecekDosyab: $yuklenecekDosyab byte');
//     // Maksimum boyut sınırlaması (örneğin, 2 MB)
//     const maksimumBoyut = 40 * 1024 * 1024; // 2 MB
//     print('maksimum buyuat : ' + maksimumBoyut.toString());
//
//     if (yuklenecekDosyab > maksimumBoyut) {
//       print('Video çok büyük, yeniden boyutlandırın veya işlem yapın');
//       setState(() {
//         galeri = 'Video Boyutu Çok Büyük!';
//       });
//
//       //Get.to(const VideoApp());
//
//       // Resim çok büyük, yeniden boyutlandırın veya işlem yapın
//       // Örnek: Resmi yeniden boyutlandırma işlemi için flutter_image_compress veya başka bir paket kullanabilirsiniz.
//     } else {
//       var dtNow = DateTime.now().microsecondsSinceEpoch;
//
//       Reference referansYol = FirebaseStorage.instance
//           .ref()
//           .child('postVideolari')
//           .child(kullanici.email.toString())
//           .child('${dtNow}postVideo.mp4');
//       Reference referansYolFoto = FirebaseStorage.instance
//           .ref()
//           .child('postVideolari')
//           .child(kullanici.email.toString())
//           .child('${dtNow}postFoto.jpg');
//
//       UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
//       UploadTask yuklemeGoreviThumbnail = referansYolFoto.putFile(yuklenecekgetThumbnailDosya);
//
//       String url = await (await yuklemeGorevi).ref.getDownloadURL();
//       String urlyuklemeGoreviThumbnail = await (await yuklemeGoreviThumbnail).ref.getDownloadURL();
//       setState(() {
//         indirmeBaglantisi = url;
//         indirmeBaglantisiThumbnail = urlyuklemeGoreviThumbnail;
//         getbox.write('postVideolinki', indirmeBaglantisi.toString());
//         getbox.write('getThumbnail', indirmeBaglantisiThumbnail.toString());
//         galeri = 'Yüklendi....';
//       });
//     }
//   }
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
//   metinEkle() async {
//     String metino = metinController.text;
//     String baslik = baslikController.text;
//     String getfoto = getbox.read("postFotolinki");
//     String getVideo = getbox.read("postVideolinki");
//     String getThumbnail = getbox.read("getThumbnail");
//     String bakisEmail = puanSa.get("email");
//
//     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//     var icerik = kullanicilar.doc(kullanici.email);
//     var secim = await icerik.get();
//     dynamic map = secim.data();
//
//     icerik.update({'postSayisi': FieldValue.increment(1)});
//     var dtNow = DateTime.now();
//     // dynamic khakkinda = map['hakkinda'];
//
//     var yil = DateTime.now().year;
//     var ay = DateTime.now().month;
//     var gun = DateTime.now().day;
//     var saat = DateTime.now().hour;
//     var dakika = DateTime.now().minute;
//
//     await FirebaseFirestore.instance
//         .collection("Kullanicilar")
//         .doc(widget.gelenKullaniciEmail)
//         .collection("bireyselAkis")
//         .doc(kullanici.email.toString() + dtNow.toString())
//         .set({
//       'id': kullanici.uid,
//       'postAydi': kullanici.email.toString() + dtNow.toString(),
//       "email": kullanici.email.toString(),
//       'isim': getVideo.toString(),
//       'unic': '',
//       'soyisim': getThumbnail.toString(),
//       'sehir': '',
//       'dogum tarihi': '',
//       'hakkinda': '',
//       'iletisim': '',
//       'metin': '',
//       'baslik': baslik,
//       'zaman': dtNow,
//       'tarih': '$gun / ' + '$ay / ' + '$yil    ' + '$saat :' + ' $dakika ',
//       'begen': [],
//       'yorumSayisi': 0,
//       'bildirim': 0,
//       'begenMe': [],
//       'profilresmilinki': '',
//       'postFotolinki': getfoto.toString(),
//       'mapYorum': getVideo.toString(),
//     });
//   }
//
//   @override
//   void initState() {
//     getbox.write('postFotolinki', 'bos');
//     getbox.write('postVideolinki', '');
//     getbox.write('getThumbnail', '');
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//     var icerik = kullanicilar.doc(kullanici.email);
//     return Positioned(
//       top: gozetop,
//       left: gozeleft,
//       child: GestureDetector(
//         onPanUpdate: (details) {
//           setState(() {
//             gozetop = max(-300, gozetop + details.delta.dy);
//             gozeleft = max(-200, gozeleft + details.delta.dx);
//           });
//         },
//         child: SizedBox(
//           height: 300,
//           width: 300,
//           child: Obx(
//             () => GestureDetector(
//               onTap: () async {
//                 getbox.write('postFotolinki', 'bos');
//                 getbox.write('postVideolinki', '');
//                 getbox.write('getThumbnail', '');
//                 var secim = await icerik.get();
//                 dynamic map = secim.data();
//
//                 dynamic unic = map['unic'];
//
//                 if (unic <= 0) {
//                   controller.acilGoze = false.obs;
//                 } else {
//                   setState(() {
//                     controller.acilGoze = true.obs;
//                   });
//                 }
//               },
//               child: Wrap(children: [
//                 if (controller.acilGoze == true.obs)
//                   Center(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Center(
//                           child: GestureDetector(
//                               onTap: () async {
//                                 setState(() async {
//                                   if (baslikController.text.isNotEmpty) {
//                                     //kullaniciBilgileriEkle();
//
//                                     var secim = await icerik.get();
//                                     dynamic map = secim.data();
//
//                                     dynamic unic = map['unic'];
//
//                                     if (unic <= 0) {
//                                     } else {
//                                       unicCikar();
//                                       metinEkle();
//                                       galeri = '.....';
//
//                                       getbox.write('postFotolinki', 'bos');
//                                       getbox.write('postVideolinki', '');
//                                       getbox.write('getThumbnail', '');
//                                       setState(() {});
//                                     }
//                                   } else {
//                                     FocusScope.of(context).requestFocus(FocusNode());
//                                     controller.acilGoze = false.obs;
//                                   }
//
//                                   baslikController.clear();
//                                 });
//                               },
//                               child: SizedBox(
//                                 width: 150,
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(2.0),
//                                       child: SizedBox(
//                                           height: 35,
//                                           width: 40,
//                                           child: GestureDetector(
//                                             onTap: () {
//                                               galeridenVideoYukle();
//                                             },
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(8.0),
//                                               child: Image.asset(
//                                                 'assets/images/png/camera.png',
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                           )),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(2.0),
//                                       child: SizedBox(
//                                           height: 35,
//                                           width: 40,
//                                           child: GestureDetector(
//                                             onTap: () {
//                                               galeridenYukle();
//                                             },
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(8.0),
//                                               child: Image.asset(
//                                                 'assets/images/png/gallery.png',
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                           )),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: SizedBox(
//                                           height: 35,
//                                           width: 40,
//                                           child: Image.asset(
//                                             'assets/images/png/unic.png',
//                                             fit: BoxFit.cover,
//                                           )),
//                                     ),
//                                   ],
//                                 ),
//                               )),
//                         ),
//                         Center(
//                           child: GestureDetector(
//                             onTap: () {
//                               controller.acilGoze = false.obs;
//                               setState(() {});
//                             },
//                             // kapatma ikonu koyulabilir
//                             child: SizedBox(
//                               height: 300,
//                               child: Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                                   child: Column(
//                                     children: [
//                                       Card(
//                                         color: Colors.black87,
//                                         child: TextField(
//                                             onSubmitted: (value) {
//                                               if (value.isEmpty) {
//                                                 //  kullaniciBilgileriEkle();
//                                                 metinEkle();
//                                                 galeri = '.....';
//                                                 setState(() {});
//                                               } else {
//                                                 controller.acilGoze = false.obs;
//                                                 setState(() {});
//                                               }
//                                             },
//                                             maxLength: 440,
//                                             maxLines: 6,
//                                             controller: baslikController,
//                                             decoration: InputDecoration(
//                                               focusColor: Colors.cyanAccent,
//                                               //add prefix icon
//
//                                               border: OutlineInputBorder(
//                                                 borderRadius: BorderRadius.circular(10.0),
//                                               ),
//
//                                               focusedBorder: OutlineInputBorder(
//                                                 borderSide: const BorderSide(color: Colors.cyan, width: 1.0),
//                                                 borderRadius: BorderRadius.circular(10.0),
//                                               ),
//                                               fillColor: Colors.cyanAccent,
//
//                                               //make hint text
//                                               hintStyle: const TextStyle(
//                                                 color: Colors.cyan,
//                                                 fontSize: 18,
//                                                 fontFamily: "verdana_regular",
//                                                 fontWeight: FontWeight.w400,
//                                               ),
//
//                                               //create lable
//                                               labelText: galeri,
//                                               //lable style
//                                               labelStyle: const TextStyle(
//                                                 textBaseline: TextBaseline.alphabetic,
//                                                 color: Colors.cyan,
//                                                 fontSize: 18,
//                                                 fontFamily: "verdana_regular",
//                                                 fontWeight: FontWeight.w400,
//                                               ),
//                                             )),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 if (controller.acilGoze == false.obs)
//                   Center(
//                     child: Card(
//                       color: Colors.black45,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: SizedBox(
//                             height: 30,
//                             width: 50,
//                             child: Image.asset(
//                               alinanDosya,
//                               fit: BoxFit.cover,
//                             )),
//                       ),
//                     ),
//                   ),
//               ]),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
