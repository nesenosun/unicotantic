// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pinch_zoom/pinch_zoom.dart';
// import 'package:unicotantic/Unic/doluAkis/yYMGD.dart';
// import 'package:unicotantic/Unic/profil/ziyaretciProfilAkis.dart';
//
// import '../fonksiyonlar/altButonlar.dart';
// import '../fonksiyonlar/buildDefaultTextStyle.dart';
// import '../fonksiyonlar/controllerFnksiyon.dart';
// import '../fonksiyonlar/controllerNet.dart';
// import '../fonksiyonlar/doluYorumFonksiyonlari.dart';
// import '../fonksiyonlar/negatifOyVer_pozitifOyVer.dart';
// import '../fonksiyonlar/profilResmiGetir.dart';
// import '../fonksiyonlar/videoPlayrFlick.dart';
// import '../profil/BenDrawer.dart';
// import 'doluAkisAppBar.dart';
// import 'doluYorumOku.dart';
//
// class YorumaYorum extends StatefulWidget {
//   final gelenKullaniciEmail;
//   final postAydi;
//   final postYorumID;
//
//   YorumaYorum({required this.gelenKullaniciEmail, required this.postAydi, required this.postYorumID});
//
//   @override
//   State<YorumaYorum> createState() => _YorumaYorumState();
// }
//
// class _YorumaYorumState extends State<YorumaYorum> {
//   final controllerNet = Get.put(ControllerNet());
//   final controllerFonk = Get.put(ControllerFonksiyon());
//
//   TextEditingController yorumController = TextEditingController();
//   bool kapat = false;
//
//   final box = GetStorage();
//   double gozetop = Get.height / 5;
//   double gozeleft = Get.width / 4;
//   GetStorage getbox = GetStorage();
//   var galeri = '......';
//
//   @override
//   void initState() {
//     puanSa.put('yorumaEkle', '....');
//
//     // FirebaseFirestore.instance.collection("postlar").doc(puanSa.get('postAydi')).update({'bildirim': 0});
//     kapat = true;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     CollectionReference postlar = controllerNet.firestore.collection('postlar');
//     var postIcerik = postlar.doc(widget.postAydi.toString());
//     //
//     Query yorumaYorumSorgu = controllerNet.firestore.collection('yorumaYorum').orderBy("zaman", descending: false);
//     //
//     CollectionReference postaYorum = controllerNet.firestore.collection('postaYorum');
//     var postYorumIcerik = postaYorum.doc(widget.postYorumID.toString());
//
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.blueGrey,
//         appBar: DoluAkisAppBar(),
//         drawer: const BenDrawer(),
//         body: Stack(
//           children: [
//             Container(
//               child: StreamBuilder<DocumentSnapshot>(
//                   stream: postIcerik.snapshots(),
//                   builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                     if (asyncSnapshot.hasError) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Container(height: 30, child: Center(child: Text('Bu Posta ulaşılamıyor...'))),
//                           Container(color: Colors.red, height: 2),
//                           // yorumStream(postaYorumSorgu),
//                         ],
//                       );
//                     } else {
//                       if (asyncSnapshot.hasData) {
//                         var baslik = asyncSnapshot.data.data()?['metin'];
//                         if (baslik == null) {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Container(height: 30, child: Center(child: Text('Bu Posta ulaşılamıyor...'))),
//                               Container(color: Colors.red, height: 2),
//                               yorumYorumStream(yorumaYorumSorgu),
//                             ],
//                           );
//                         }
//
//                         var postuAtanEmail = asyncSnapshot.data.data()['email'];
//                         //var id = asyncSnapshot.data.data()['id'];
//                         var postTarih = asyncSnapshot.data.data()['tarih'];
//                         var postBaslik = asyncSnapshot.data.data()['baslik'];
//                         var postBegenMe = asyncSnapshot.data.data()['begenMe'];
//                         var postBegen = asyncSnapshot.data.data()['begen'];
//                         var postFotolinki = asyncSnapshot.data.data()['postFotolinki'];
//                         var postAydi = asyncSnapshot.data.data()['postAydi'];
//                         //var duzenlemeMetin = asyncSnapshot.data.data()['metin'];
//                         var videoFoto = asyncSnapshot.data.data()['soyisim'];
//                         var mapYorumVideo = asyncSnapshot.data.data()['mapYorum'];
//
//                         var bakBegenKontrol = postBegen.contains(controllerNet.kullanici.email);
//                         var bakBegenMeKontrol = postBegenMe.contains(controllerNet.kullanici.email);
//
//                         dynamic profilResmiCikar(email) {
//                           return profilResmiGetir(email);
//                         }
//
//                         dynamic profilIsmiCikar(email) {
//                           return profilIsmiGetir(email);
//                         }
//
//                         dynamic unicCikarGetir(email) {
//                           return profilUnicGetir(email);
//                         }
//
//                         dynamic profilIdGetire(email) {
//                           return profilIdGetir(email);
//                         }
//
//                         return Card(
//                           child: Column(
//                             children: [
//                               kapat == true
//                                   ? Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: [
//                                         birinciPost(
//                                             postuAtanEmail,
//                                             postAydi,
//                                             profilResmiCikar,
//                                             profilIsmiCikar,
//                                             profilIdGetire,
//                                             unicCikarGetir,
//                                             postTarih,
//                                             postBaslik,
//                                             videoFoto,
//                                             mapYorumVideo,
//                                             postFotolinki,
//                                             postBegenMe,
//                                             bakBegenMeKontrol,
//                                             postBegen,
//                                             bakBegenKontrol),
//                                         Container(color: Colors.red, height: 2),
//                                         ikinciPost(postYorumIcerik, yorumaYorumSorgu),
//                                       ],
//                                     )
//                                   : oncekiGonderiler(),
//                               Container(color: Colors.red, height: 2),
//                               ucuncuPostYorumlar(yorumaYorumSorgu),
//                             ],
//                           ),
//                         );
//                       } else {
//                         /// yükleniyor bölümü
//                         return buildDefaultTextStyle();
//                       }
//                     }
//                   }),
//             ),
//             YorumaYorumMetinGir(
//                 postAydi: widget.postAydi,
//                 gelenKullaniciEmail: widget.gelenKullaniciEmail,
//                 postYorumID: widget.postYorumID),
//           ],
//         ),
//       ),
//     );
//   }
//
//   GestureDetector birinciPost(
//       postuAtanEmail,
//       postAydi,
//       profilResmiCikar(dynamic email),
//       profilIsmiCikar(dynamic email),
//       profilIdGetire(dynamic email),
//       unicCikarGetir(dynamic email),
//       postTarih,
//       postBaslik,
//       videoFoto,
//       mapYorumVideo,
//       postFotolinki,
//       postBegenMe,
//       bakBegenMeKontrol,
//       postBegen,
//       bakBegenKontrol) {
//     return GestureDetector(
//       onTap: () {
//         Get.to(DoluYorumOku(
//           gelenKullaniciEmail: postuAtanEmail.toString(),
//           postAydi: postAydi.toString(),
//         ));
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Card(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(15.0),
//                         bottomRight: Radius.circular(15.0),
//                       ),
//                       child: Container(
//                         //color: Colors.blue,
//                         width: 50.0,
//                         height: 50.0,
//                         child: GestureDetector(
//                           onTap: () async {
//                             // puanSa.put('postAydi', postAydi.toString());
//                             puanSa.put('email', postuAtanEmail.toString());
//                             Get.to(ZiyaretciProfilAkis(gelenKullaniciEmail: postuAtanEmail));
//                           },
//                           child: profilResmiCikar(postuAtanEmail.toString()),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     profilIsmiCikar(postuAtanEmail),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         Card(
//                           child: profilIdGetire(postuAtanEmail),
//                         ),
//                         Card(
//                           child: unicCikarGetir(postuAtanEmail),
//                         ),
//                       ],
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 2),
//                       child: Text(postTarih.toString() + ' ',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               //fontWeight: FontWeight.bold,
//                               color: Colors.white60,
//                               fontSize: 10)),
//                     ),
//                   ],
//                 ),
//                 //postuDuzenleIconu(email, postAydi),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(3.0),
//             child: Text(
//               '${postBaslik}',
//               textAlign: TextAlign.start,
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.normal,
//                 fontSize: 15,
//                 color: Colors.white60,
//                 //fontFamily: 'montserrat',
//                 //fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Container(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Card(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(2.0),
//                         child: videoFoto == ''
//                             ? Center()
//                             : PinchZoom(
//                                 onZoomStart: () {},
//                                 onZoomEnd: () {},
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(15.0),
//                                     topRight: Radius.circular(15.0),
//                                     bottomRight: Radius.circular(15.0),
//                                     bottomLeft: Radius.circular(15.0),
//                                   ),
//                                   child: SizedBox(
//                                     height: 90,
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         Get.to(VideoFotoGosterSayfasi(
//                                           gelenVideolink: mapYorumVideo,
//                                           gelenFotolink: postFotolinki,
//                                         ));
//                                       },
//                                       child: Stack(
//                                         //fit: StackFit.expand,
//                                         alignment: Alignment.center,
//                                         children: [
//                                           Image.network(
//                                             videoFoto,
//                                             fit: BoxFit.fill,
//                                           ),
//                                           SizedBox(height: 50, child: Image.asset('assets/images/png/play.png')),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(2.0),
//                         child: postFotolinki == 'bos'
//                             ? Center()
//                             : PinchZoom(
//                                 onZoomStart: () {},
//                                 onZoomEnd: () {},
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(8.0),
//                                     topRight: Radius.circular(8.0),
//                                     bottomRight: Radius.circular(8.0),
//                                     bottomLeft: Radius.circular(8.0),
//                                   ),
//                                   child: SizedBox(
//                                     height: 90,
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         Get.to(VideoFotoGosterSayfasi(
//                                           gelenVideolink: mapYorumVideo,
//                                           gelenFotolink: postFotolinki,
//                                         ));
//                                       },
//                                       child: Image.network(
//                                         postFotolinki,
//                                         fit: BoxFit.fill,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Card(
//             child: Container(
//               height: 40,
//               // color: Colors.black45,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text(
//                     ' ${postBegenMe.length}',
//                     style: TextStyle(fontSize: 13, color: Colors.white70),
//                   ),
//                   IconButton(
//                       onPressed: () async {
//                         var KullaniciUnicSayisi = await KullaniciUnicSayisiGetirFonksiyonu();
//
//                         if (KullaniciUnicSayisi <= 0) {
//                         } else {
//                           if (postuAtanEmail != controllerNet.kullanici.email) {
//                             if (bakBegenMeKontrol) {
//                               await postBegenMedenEmailCikarFonksiyonu(postAydi);
//                               await poostSahibineUnicEkle(postuAtanEmail);
//                             } else {
//                               await postBegeneMEyeEmailEkleFonksiyonu(postAydi);
//                               await kullanicidanUnicCikar(KullaniciUnicSayisi);
//                               await postSahibinidenUnicCikar(postuAtanEmail);
//                             }
//                           }
//                         }
//                       },
//                       icon: Icon(
//                         Icons.heart_broken,
//                         size: 20,
//                         color: postBegenMe.contains(kullanici.email) ? Colors.red : Colors.white70,
//                       )),
//                   Text('${postBegen.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
//                   IconButton(
//                       onPressed: () async {
//                         var KullaniciUnicSayisi = await KullaniciUnicSayisiGetirFonksiyonu();
//
//                         if (KullaniciUnicSayisi <= 0) {
//                         } else {
//                           if (postuAtanEmail != controllerNet.kullanici.email) {
//                             if (bakBegenKontrol) {
//                               await postBegendenEmailCikarFonksiyonu(postAydi);
//
//                               await postSahibinidenUnicCikar(postuAtanEmail);
//                             } else {
//                               await postBegeneEmailEkleFonksiyonu(postAydi);
//                               await kullanicidanUnicCikar(KullaniciUnicSayisi);
//                               await poostSahibineUnicEkle(postuAtanEmail);
//                             }
//                           }
//                         }
//                       },
//                       icon: Icon(
//                         Icons.thumb_up_alt_rounded,
//                         size: 20,
//                         color: postBegen.contains(kullanici.email) ? Colors.cyanAccent : Colors.white70,
//                       )),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   GestureDetector oncekiGonderiler() {
//     return GestureDetector(
//       onTap: () {
//         kapat = true;
//         setState(() {});
//       },
//       child: Card(
//         color: Colors.black26,
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//               child: Center(
//                 child: Text('Önceki Gönderiler',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Container ucuncuPostYorumlar(Query<Object?> yorumaYorumSorgu) {
//     return Container(
//       child: StreamBuilder<QuerySnapshot>(
//           stream: yorumaYorumSorgu.snapshots(),
//           builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//             if (asyncSnapshot.hasError) {
//               return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//             } else {
//               if (asyncSnapshot.hasData) {
//                 List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;
//                 //var suzgec = listOfDocumentSnap.indexWhere((element) => true) == puanSa.get('postAydi');
//
//                 return Flexible(
//                   child: ListView.builder(
//                       itemCount: listOfDocumentSnap.length,
//                       itemBuilder: (context, index) {
//                         var begenKontrol = listOfDocumentSnap[index].get('begen');
//                         var email = listOfDocumentSnap[index].get('email');
//                         var kimeYorumEmail = listOfDocumentSnap[index].get('kimeYorumEmail');
//                         var id = listOfDocumentSnap[index].get('id');
//                         var tarih = listOfDocumentSnap[index].get('tarih');
//                         var baslik = listOfDocumentSnap[index].get('metin');
//                         //var duzenlemeMetin = listOfDocumentSnap[index].get('metin');
//                         var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
//                         var mapYorumVideo = listOfDocumentSnap[index].get('mapYorum');
//                         //var isimVideo = listOfDocumentSnap[index].get('isim');
//                         var videoFoto = listOfDocumentSnap[index].get('soyisim');
//                         //var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
//
//                         var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
//
//                         var postAydi = listOfDocumentSnap[index].get('postAydi');
//                         var postYorumID = listOfDocumentSnap[index].get('postYorumID');
//                         var update = listOfDocumentSnap[index].reference.update;
//                         var bakBegenKontrol = begenKontrol.contains(kullanici.email);
//                         var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);
//
//                         dynamic profilResmiCikar(email) {
//                           return profilResmiGetir(email);
//                         }
//
//                         dynamic profilIsmiCikar(email) {
//                           return profilIsmiGetir(email);
//                         }
//
//                         dynamic unicCikar(email) {
//                           return profilUnicGetir(email);
//                         }
//
//                         dynamic profilIdGetire(email) {
//                           return profilIdGetir(email);
//                         }
//
//                         var postYorumIDe = widget.postYorumID;
//
//                         return Container(
//                           child: postYorumID == postYorumIDe
//                               ? Card(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Card(
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.center,
//                                           mainAxisAlignment: MainAxisAlignment.start,
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                                               child: Padding(
//                                                 padding: const EdgeInsets.only(right: 8),
//                                                 child: ClipRRect(
//                                                   borderRadius: BorderRadius.only(
//                                                     topLeft: Radius.circular(15.0),
//                                                     bottomRight: Radius.circular(15.0),
//                                                   ),
//                                                   child: Container(
//                                                     //color: Colors.blue,
//                                                     width: 50.0,
//                                                     height: 50.0,
//                                                     child: GestureDetector(
//                                                       onTap: () async {
//                                                         Get.to(ZiyaretciProfilAkis(gelenKullaniciEmail: email));
//                                                       },
//                                                       child: profilResmiCikar(email.toString()),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               mainAxisAlignment: MainAxisAlignment.start,
//                                               children: [
//                                                 profilIsmiCikar(email),
//                                                 Row(
//                                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                                   children: [
//                                                     Card(
//                                                       child: profilIdGetire(email),
//                                                     ),
//                                                     Card(
//                                                       child: unicCikar(email),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 Padding(
//                                                     padding: const EdgeInsets.only(bottom: 2),
//                                                     child: Text(tarih.toString() + ' ',
//                                                         textAlign: TextAlign.center,
//                                                         style: TextStyle(
//                                                             //fontWeight: FontWeight.bold,
//                                                             color: Colors.white60,
//                                                             fontSize: 10))),
//                                               ],
//                                             ),
//                                             //postuDuzenleIconu(email, postAydi),
//                                           ],
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.all(3.0),
//                                         child: baslik.toString().substring(0, 1) == '@'
//                                             ? RichText(
//                                                 text: TextSpan(
//                                                   style: GoogleFonts.poppins(
//                                                     fontWeight: FontWeight.normal,
//                                                     fontSize: 15,
//                                                     color: Colors.white60,
//                                                   ),
//                                                   children: [
//                                                     TextSpan(
//                                                       text: baslik.toString().substring(0, baslik.indexOf(' ') + 1),
//                                                       style: GoogleFonts.poppins(
//                                                         fontWeight: FontWeight.bold,
//                                                         fontSize: 15,
//                                                         color: Colors.blue,
//                                                       ),
//                                                       recognizer: TapGestureRecognizer()
//                                                         ..onTap = () {
//                                                           // Linkin açılacağı işlemler buraya
//                                                           // launch('https://www.example.com');
//                                                         },
//                                                     ),
//                                                     TextSpan(
//                                                       text: baslik.toString().substring(baslik.indexOf(' ') + 1),
//                                                       style: GoogleFonts.poppins(
//                                                         fontWeight: FontWeight.normal,
//                                                         fontSize: 15,
//                                                         color: Colors.white60,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               )
//                                             : Text(
//                                                 '${baslik}',
//                                                 textAlign: TextAlign.start,
//                                                 style: GoogleFonts.poppins(
//                                                   fontWeight: FontWeight.normal,
//                                                   fontSize: 15,
//                                                   color: Colors.white60,
//                                                 ),
//                                               ),
//                                       ),
//                                       Card(
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.center,
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.all(2.0),
//                                               child: videoFoto == ''
//                                                   ? Center()
//                                                   : PinchZoom(
//                                                       onZoomStart: () {},
//                                                       onZoomEnd: () {},
//                                                       child: ClipRRect(
//                                                         borderRadius: BorderRadius.only(
//                                                           topLeft: Radius.circular(15.0),
//                                                           topRight: Radius.circular(15.0),
//                                                           bottomRight: Radius.circular(15.0),
//                                                           bottomLeft: Radius.circular(15.0),
//                                                         ),
//                                                         child: SizedBox(
//                                                           width: 160,
//                                                           child: GestureDetector(
//                                                             onTap: () {
//                                                               Get.to(VideoFotoGosterSayfasi(
//                                                                 gelenVideolink: mapYorumVideo,
//                                                                 gelenFotolink: postFotolinki,
//                                                               ));
//                                                             },
//                                                             child: Stack(
//                                                               //fit: StackFit.expand,
//                                                               alignment: Alignment.center,
//                                                               children: [
//                                                                 Image.network(
//                                                                   videoFoto,
//                                                                   fit: BoxFit.fill,
//                                                                 ),
//                                                                 SizedBox(
//                                                                     height: 50,
//                                                                     child: Image.asset('assets/images/png/play.png')),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.all(2.0),
//                                               child: postFotolinki == 'bos'
//                                                   ? Center()
//                                                   : PinchZoom(
//                                                       onZoomStart: () {},
//                                                       onZoomEnd: () {},
//                                                       child: ClipRRect(
//                                                         borderRadius: BorderRadius.only(
//                                                           topLeft: Radius.circular(8.0),
//                                                           topRight: Radius.circular(8.0),
//                                                           bottomRight: Radius.circular(8.0),
//                                                           bottomLeft: Radius.circular(8.0),
//                                                         ),
//                                                         child: SizedBox(
//                                                           width: 160,
//                                                           child: GestureDetector(
//                                                             onTap: () {
//                                                               Get.to(VideoFotoGosterSayfasi(
//                                                                 gelenVideolink: mapYorumVideo,
//                                                                 gelenFotolink: postFotolinki,
//                                                               ));
//                                                             },
//                                                             child: Image.network(
//                                                               postFotolinki,
//                                                               fit: BoxFit.fill,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         height: 35,
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.all(1.0),
//                                               child: IconButton(
//                                                   onPressed: () async {
//                                                     var kimeYorumEmaile = listOfDocumentSnap[index].get('email');
//
//                                                     CollectionReference kullanicilar =
//                                                         controllerNet.firestore.collection('Kullanicilar');
//                                                     var icerik = kullanicilar.doc(kimeYorumEmaile);
//
//                                                     var secim = await icerik.get();
//                                                     dynamic map = secim.data();
//                                                     dynamic kullaniciID = map['id'];
//                                                     puanSa.put('yorumYapanEmail', '@' + kullaniciID.toString());
//
//                                                     puanSa.put('kimeYorumDegistir', kimeYorumEmaile.toString());
//                                                     print(
//                                                         '           ddd h                    h                  h               h   ' +
//                                                             puanSa.get('yorumYapanEmail'));
//                                                     print('                          h   ' +
//                                                         puanSa.get('kimeYorumDegistir'));
//
//                                                     // var id = await listOfDocumentSnap[index]
//                                                     //     .reference
//                                                     //     .update({"id": FieldValue.increment(-1)});
//                                                     setState(() {});
//                                                   },
//                                                   icon: const Icon(
//                                                     Icons.add,
//                                                     size: 20,
//                                                     color: Colors.red,
//                                                   )),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.all(1.0),
//                                               child: kullanici.email == email.toString()
//                                                   ? IconButton(
//                                                       onPressed: () async {
//                                                         await listOfDocumentSnap[index].reference.delete();
//                                                         await FirebaseFirestore.instance
//                                                             .collection("postaYorum")
//                                                             .doc(postYorumIDe.toString())
//                                                             .update({
//                                                           "yorumSayisi": FieldValue.increment(-1),
//                                                           "bildirim": FieldValue.increment(-1)
//                                                         });
//                                                       },
//                                                       icon: const Icon(
//                                                         Icons.delete,
//                                                         size: 20,
//                                                         color: Colors.red,
//                                                       ))
//                                                   : Padding(
//                                                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2)),
//                                             ),
//                                             Row(
//                                               children: [
//                                                 IconButton(
//                                                     onPressed: () async {
//                                                       final kullanici = FirebaseAuth.instance.currentUser!;
//                                                       final _firestore = FirebaseFirestore.instance;
//                                                       CollectionReference kullanicilar =
//                                                           _firestore.collection('Kullanicilar');
//                                                       var icerik = kullanicilar.doc(kullanici.email);
//                                                       var secim = await icerik.get();
//                                                       dynamic map = secim.data();
//
//                                                       dynamic unic = map['unic'];
//
//                                                       if (unic <= 0) {
//                                                       } else {
//                                                         if (email != kullanici.email) {
//                                                           if (bakBegenMeKontrol) {
//                                                             update({
//                                                               'begenMe': FieldValue.arrayRemove([kullanici.email])
//                                                             });
//                                                             update({'unic': FieldValue.increment(1)});
//
//                                                             await FirebaseFirestore.instance
//                                                                 .collection("Kullanicilar")
//                                                                 .doc(email.toString())
//                                                                 .update({"unic": FieldValue.increment(1)});
//                                                           } else {
//                                                             controllerFonk.unicCikart();
//                                                             update({
//                                                               'begenMe': FieldValue.arrayUnion([kullanici.email])
//                                                             });
//                                                             update({'unic': FieldValue.increment(-1)});
//
//                                                             await FirebaseFirestore.instance
//                                                                 .collection("Kullanicilar")
//                                                                 .doc(email.toString())
//                                                                 .update({"unic": FieldValue.increment(-1)});
//                                                           }
//                                                         }
//                                                       }
//                                                     },
//                                                     icon: Icon(
//                                                       Icons.heart_broken,
//                                                       size: 20,
//                                                       color: bakBegenMeKontrol ? Colors.red : Colors.white70,
//                                                     )),
//                                                 Text(' ${begenMeKontrol.length}',
//                                                     style: TextStyle(fontSize: 13, color: Colors.white70)),
//                                               ],
//                                             ),
//                                             Row(
//                                               children: [
//                                                 IconButton(
//                                                     onPressed: () async {
//                                                       await pozitifOyVer(
//                                                           listOfDocumentSnap, index, bakBegenKontrol, update, email);
//                                                     },
//                                                     icon: Icon(
//                                                       Icons.thumb_up_alt_rounded,
//                                                       size: 20,
//                                                       color: bakBegenKontrol ? Colors.cyan : Colors.white70,
//                                                     )),
//                                                 Text('${begenKontrol.length}',
//                                                     style: TextStyle(fontSize: 13, color: Colors.white70)),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               : Center(),
//                         );
//                       }),
//                 );
//               } else {
//                 /// yükleniyor bölümü
//                 return buildDefaultTextStyle();
//               }
//             }
//           }),
//     );
//   }
//
//   Container ikinciPost(DocumentReference<Object?> postYorumIcerik, Query<Object?> yorumaYorumSorgu) {
//     return Container(
//       child: StreamBuilder<DocumentSnapshot>(
//           stream: postYorumIcerik.snapshots(),
//           builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//             if (asyncSnapshot.hasError) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Container(height: 30, child: Center(child: Text('Bu Posta ulaşılamıyor...'))),
//                   Container(color: Colors.red, height: 2),
//                   yorumYorumStream(yorumaYorumSorgu),
//                 ],
//               );
//             } else {
//               if (asyncSnapshot.hasData) {
//                 var baslik = asyncSnapshot.data.data()?['baslik'];
//                 if (baslik == null) {
//                   return Center(child: Text('Bu Posta ulaşılamıyor...'));
//                 }
//
//                 var postuAtanEmail = asyncSnapshot.data.data()['email'];
//                 var postTarih = asyncSnapshot.data.data()['tarih'];
//                 var postBaslik = asyncSnapshot.data.data()['metin'];
//                 var postBegenMe = asyncSnapshot.data.data()['begenMe'];
//                 var postBegen = asyncSnapshot.data.data()['begen'];
//                 var postFotolinki = asyncSnapshot.data.data()['postFotolinki'];
//                 var postAydik = asyncSnapshot.data.data()['postAydi'];
//                 var videoFoto = asyncSnapshot.data.data()['soyisim'];
//                 var mapYorumVideo = asyncSnapshot.data.data()['mapYorum'];
//
//                 var bakBegenKontrol = postBegen.contains(controllerNet.kullanici.email);
//                 var bakBegenMeKontrol = postBegenMe.contains(controllerNet.kullanici.email);
//
//                 dynamic profilResmiCikar(email) {
//                   return profilResmiGetir(email);
//                 }
//
//                 dynamic profilIsmiCikar(email) {
//                   return profilIsmiGetir(email);
//                 }
//
//                 dynamic unicCikarGetir(email) {
//                   return profilUnicGetir(email);
//                 }
//
//                 dynamic profilIdGetire(email) {
//                   return profilIdGetir(email);
//                 }
//
//                 return Card(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Card(
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                               child: Padding(
//                                 padding: const EdgeInsets.only(right: 8),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(15.0),
//                                     bottomRight: Radius.circular(15.0),
//                                   ),
//                                   child: Container(
//                                     //color: Colors.blue,
//                                     width: 50.0,
//                                     height: 50.0,
//                                     child: GestureDetector(
//                                       onTap: () async {
//                                         // puanSa.put('postAydi', postAydi.toString());
//                                         puanSa.put('email', postuAtanEmail.toString());
//                                         Get.to(ZiyaretciProfilAkis(gelenKullaniciEmail: postuAtanEmail));
//                                       },
//                                       child: profilResmiCikar(postuAtanEmail.toString()),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 profilIsmiCikar(postuAtanEmail),
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                   children: [
//                                     Card(
//                                       child: profilIdGetire(postuAtanEmail),
//                                     ),
//                                     Card(
//                                       child: unicCikarGetir(postuAtanEmail),
//                                     ),
//                                   ],
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(bottom: 2),
//                                   child: Text(postTarih.toString() + ' ',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           //fontWeight: FontWeight.bold,
//                                           color: Colors.white60,
//                                           fontSize: 10)),
//                                 ),
//                               ],
//                             ),
//                             //postuDuzenleIconu(email, postAydi),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(3.0),
//                         child: Text(
//                           '${postBaslik}',
//                           textAlign: TextAlign.start,
//                           style: GoogleFonts.poppins(
//                             fontWeight: FontWeight.normal,
//                             fontSize: 15,
//                             color: Colors.white60,
//                             //fontFamily: 'montserrat',
//                             //fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Card(
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(2.0),
//                                   child: videoFoto == ''
//                                       ? Center()
//                                       : PinchZoom(
//                                           onZoomStart: () {},
//                                           onZoomEnd: () {},
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.only(
//                                               topLeft: Radius.circular(15.0),
//                                               topRight: Radius.circular(15.0),
//                                               bottomRight: Radius.circular(15.0),
//                                               bottomLeft: Radius.circular(15.0),
//                                             ),
//                                             child: SizedBox(
//                                               height: 90,
//                                               child: GestureDetector(
//                                                 onTap: () {
//                                                   Get.to(VideoFotoGosterSayfasi(
//                                                     gelenVideolink: mapYorumVideo,
//                                                     gelenFotolink: postFotolinki,
//                                                   ));
//                                                 },
//                                                 child: Stack(
//                                                   //fit: StackFit.expand,
//                                                   alignment: Alignment.center,
//                                                   children: [
//                                                     Image.network(
//                                                       videoFoto,
//                                                       fit: BoxFit.fill,
//                                                     ),
//                                                     SizedBox(
//                                                         height: 50, child: Image.asset('assets/images/png/play.png')),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(2.0),
//                                   child: postFotolinki == 'bos'
//                                       ? Center()
//                                       : PinchZoom(
//                                           onZoomStart: () {},
//                                           onZoomEnd: () {},
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.only(
//                                               topLeft: Radius.circular(8.0),
//                                               topRight: Radius.circular(8.0),
//                                               bottomRight: Radius.circular(8.0),
//                                               bottomLeft: Radius.circular(8.0),
//                                             ),
//                                             child: SizedBox(
//                                               height: 90,
//                                               child: GestureDetector(
//                                                 onTap: () {
//                                                   Get.to(VideoFotoGosterSayfasi(
//                                                     gelenVideolink: mapYorumVideo,
//                                                     gelenFotolink: postFotolinki,
//                                                   ));
//                                                 },
//                                                 child: Image.network(
//                                                   postFotolinki,
//                                                   fit: BoxFit.fill,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           kapat = false;
//                           setState(() {});
//                         },
//                         child: Card(
//                           child: Container(
//                             height: 40,
//                             // color: Colors.black45,
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   ' ${postBegenMe.length}',
//                                   style: TextStyle(fontSize: 13, color: Colors.white70),
//                                 ),
//                                 IconButton(
//                                     onPressed: () async {
//                                       CollectionReference kullanicilar =
//                                           controllerNet.firestore.collection('Kullanicilar');
//                                       var icerik = kullanicilar.doc(controllerNet.kullanici.email);
//                                       var secim = await icerik.get();
//                                       dynamic map = secim.data();
//
//                                       dynamic unic = map['unic'];
//
//                                       if (unic <= 0) {
//                                       } else {
//                                         if (postuAtanEmail != controllerNet.kullanici.email) {
//                                           if (postBegenMe.contains(kullanici.email)) {
//                                             await FirebaseFirestore.instance
//                                                 .collection("postaYorum")
//                                                 .doc(widget.postYorumID.toString())
//                                                 .update({
//                                               'begenMe': FieldValue.arrayRemove([controllerNet.kullanici.email])
//                                             });
//                                             FirebaseFirestore.instance
//                                                 .collection("Kullanicilar")
//                                                 .doc(postuAtanEmail.toString())
//                                                 .update({'unic': FieldValue.increment(1)});
//                                           } else {
//                                             await FirebaseFirestore.instance
//                                                 .collection("postaYorum")
//                                                 .doc(widget.postYorumID.toString())
//                                                 .update({
//                                               'begenMe': FieldValue.arrayUnion([controllerNet.kullanici.email])
//                                             });
//                                             FirebaseFirestore.instance
//                                                 .collection("Kullanicilar")
//                                                 .doc(postuAtanEmail.toString())
//                                                 .update({'unic': FieldValue.increment(-1)});
//                                             await kullanicidanUnicCikar(unic);
//                                           }
//                                         }
//                                       }
//                                     },
//                                     icon: Icon(
//                                       Icons.heart_broken,
//                                       size: 20,
//                                       color: postBegenMe.contains(kullanici.email) ? Colors.red : Colors.white70,
//                                     )),
//                                 Text('${postBegen.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
//                                 IconButton(
//                                     onPressed: () async {
//                                       CollectionReference kullanicilar =
//                                           controllerNet.firestore.collection('Kullanicilar');
//                                       var icerik = kullanicilar.doc(controllerNet.kullanici.email);
//                                       var secim = await icerik.get();
//                                       dynamic map = secim.data();
//
//                                       dynamic unic = map['unic'];
//
//                                       if (unic <= 0) {
//                                       } else {
//                                         if (postuAtanEmail != controllerNet.kullanici.email) {
//                                           if (postBegen.contains(kullanici.email)) {
//                                             await FirebaseFirestore.instance
//                                                 .collection("postaYorum")
//                                                 .doc(widget.postYorumID.toString())
//                                                 .update({
//                                               'begen': FieldValue.arrayRemove([controllerNet.kullanici.email])
//                                             });
//                                             FirebaseFirestore.instance
//                                                 .collection("Kullanicilar")
//                                                 .doc(postuAtanEmail.toString())
//                                                 .update({'unic': FieldValue.increment(-1)});
//                                           } else {
//                                             await FirebaseFirestore.instance
//                                                 .collection("postaYorum")
//                                                 .doc(widget.postYorumID.toString())
//                                                 .update({
//                                               'begen': FieldValue.arrayUnion([controllerNet.kullanici.email])
//                                             });
//                                             FirebaseFirestore.instance
//                                                 .collection("Kullanicilar")
//                                                 .doc(postuAtanEmail.toString())
//                                                 .update({'unic': FieldValue.increment(1)});
//                                             await kullanicidanUnicCikar(unic);
//                                           }
//                                         }
//                                       }
//                                     },
//                                     icon: Icon(
//                                       Icons.thumb_up_alt_rounded,
//                                       size: 20,
//                                       color: postBegen.contains(kullanici.email) ? Colors.cyanAccent : Colors.white70,
//                                     )),
//                                 Card(
//                                   color: Colors.black38,
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                                     child: Center(
//                                       child: Text('Gönderiyi Kapat',
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 11)),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               } else {
//                 /// yükleniyor bölümü
//                 return buildDefaultTextStyle();
//               }
//             }
//           }),
//     );
//   }
//
//   StreamBuilder<QuerySnapshot<Object?>> yorumYorumStream(Query<Object?> postaYorumSorgu) {
//     return StreamBuilder<QuerySnapshot>(
//         stream: postaYorumSorgu.snapshots(),
//         builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//           if (asyncSnapshot.hasError) {
//             return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//           } else {
//             if (asyncSnapshot.hasData) {
//               List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;
//               //var suzgec = listOfDocumentSnap.indexWhere((element) => true) == puanSa.get('postAydi');
//
//               return Flexible(
//                 child: ListView.builder(
//                     itemCount: listOfDocumentSnap.length,
//                     itemBuilder: (context, index) {
//                       var begenKontrol = listOfDocumentSnap[index].get('begen');
//                       var email = listOfDocumentSnap[index].get('email');
//                       var kimeYorumEmail = listOfDocumentSnap[index].get('kimeYorumEmail');
//                       var id = listOfDocumentSnap[index].get('id');
//                       var tarih = listOfDocumentSnap[index].get('tarih');
//                       var baslik = listOfDocumentSnap[index].get('metin');
//                       //var duzenlemeMetin = listOfDocumentSnap[index].get('metin');
//                       var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
//                       var mapYorumVideo = listOfDocumentSnap[index].get('mapYorum');
//                       //var isimVideo = listOfDocumentSnap[index].get('isim');
//                       var videoFoto = listOfDocumentSnap[index].get('soyisim');
//                       //var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
//
//                       var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
//
//                       var postAydi = listOfDocumentSnap[index].get('postAydi');
//                       var postYorumID = listOfDocumentSnap[index].get('postYorumID');
//                       var update = listOfDocumentSnap[index].reference.update;
//                       var bakBegenKontrol = begenKontrol.contains(kullanici.email);
//                       var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);
//
//                       dynamic profilResmiCikar(email) {
//                         return profilResmiGetir(email);
//                       }
//
//                       dynamic profilIsmiCikar(email) {
//                         return profilIsmiGetir(email);
//                       }
//
//                       dynamic unicCikar(email) {
//                         return profilUnicGetir(email);
//                       }
//
//                       dynamic profilIdGetire(email) {
//                         return profilIdGetir(email);
//                       }
//
//                       var postYorumIDe = widget.postYorumID;
//
//                       return Container(
//                         child: postYorumID == postYorumIDe
//                             ? Card(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Card(
//                                       child: Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                                             child: Padding(
//                                               padding: const EdgeInsets.only(right: 8),
//                                               child: ClipRRect(
//                                                 borderRadius: BorderRadius.only(
//                                                   topLeft: Radius.circular(15.0),
//                                                   bottomRight: Radius.circular(15.0),
//                                                 ),
//                                                 child: Container(
//                                                   //color: Colors.blue,
//                                                   width: 50.0,
//                                                   height: 50.0,
//                                                   child: GestureDetector(
//                                                     onTap: () async {
//                                                       Get.to(ZiyaretciProfilAkis(gelenKullaniciEmail: email));
//                                                     },
//                                                     child: profilResmiCikar(email.toString()),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             mainAxisAlignment: MainAxisAlignment.start,
//                                             children: [
//                                               profilIsmiCikar(email),
//                                               Row(
//                                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                                 children: [
//                                                   Card(
//                                                     child: profilIdGetire(email),
//                                                   ),
//                                                   Card(
//                                                     child: unicCikar(email),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Padding(
//                                                   padding: const EdgeInsets.only(bottom: 2),
//                                                   child: Text(tarih.toString() + ' ',
//                                                       textAlign: TextAlign.center,
//                                                       style: TextStyle(
//                                                           //fontWeight: FontWeight.bold,
//                                                           color: Colors.white60,
//                                                           fontSize: 10))),
//                                             ],
//                                           ),
//                                           //postuDuzenleIconu(email, postAydi),
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(3.0),
//                                       child: baslik.toString().substring(0, 1) == '@'
//                                           ? RichText(
//                                               text: TextSpan(
//                                                 style: GoogleFonts.poppins(
//                                                   fontWeight: FontWeight.normal,
//                                                   fontSize: 15,
//                                                   color: Colors.white60,
//                                                   //fontFamily: 'montserrat',
//                                                   //fontWeight: FontWeight.w500,
//                                                 ),
//                                                 children: [
//                                                   TextSpan(
//                                                     text: baslik.toString().substring(0, 11),
//                                                     style: GoogleFonts.poppins(
//                                                       fontWeight: FontWeight.bold,
//                                                       fontSize: 13,
//                                                       color: Colors.blue,
//                                                       //fontFamily: 'montserrat',
//                                                       //fontWeight: FontWeight.w500,
//                                                     ),
//                                                     recognizer: TapGestureRecognizer()
//                                                       ..onTap = () {
//                                                         // Linkin açılacağı işlemler buraya
//                                                         // launch('https://www.example.com');
//                                                       },
//                                                   ),
//                                                   TextSpan(
//                                                     text: baslik.toString().substring(11),
//                                                     style: GoogleFonts.poppins(
//                                                       fontWeight: FontWeight.normal,
//                                                       fontSize: 15,
//                                                       color: Colors.white60,
//                                                       //fontFamily: 'montserrat',
//                                                       //fontWeight: FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             )
//                                           : Text(
//                                               '${baslik}',
//                                               textAlign: TextAlign.start,
//                                               style: GoogleFonts.poppins(
//                                                 fontWeight: FontWeight.normal,
//                                                 fontSize: 15,
//                                                 color: Colors.white60,
//                                                 //fontFamily: 'montserrat',
//                                                 //fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                     ),
//                                     Card(
//                                       child: Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.all(2.0),
//                                             child: videoFoto == ''
//                                                 ? Center()
//                                                 : PinchZoom(
//                                                     onZoomStart: () {},
//                                                     onZoomEnd: () {},
//                                                     child: ClipRRect(
//                                                       borderRadius: BorderRadius.only(
//                                                         topLeft: Radius.circular(15.0),
//                                                         topRight: Radius.circular(15.0),
//                                                         bottomRight: Radius.circular(15.0),
//                                                         bottomLeft: Radius.circular(15.0),
//                                                       ),
//                                                       child: SizedBox(
//                                                         width: 160,
//                                                         child: GestureDetector(
//                                                           onTap: () {
//                                                             Get.to(VideoFotoGosterSayfasi(
//                                                               gelenVideolink: mapYorumVideo,
//                                                               gelenFotolink: postFotolinki,
//                                                             ));
//                                                           },
//                                                           child: Stack(
//                                                             //fit: StackFit.expand,
//                                                             alignment: Alignment.center,
//                                                             children: [
//                                                               Image.network(
//                                                                 videoFoto,
//                                                                 fit: BoxFit.fill,
//                                                               ),
//                                                               SizedBox(
//                                                                   height: 50,
//                                                                   child: Image.asset('assets/images/png/play.png')),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(2.0),
//                                             child: postFotolinki == 'bos'
//                                                 ? Center()
//                                                 : PinchZoom(
//                                                     onZoomStart: () {},
//                                                     onZoomEnd: () {},
//                                                     child: ClipRRect(
//                                                       borderRadius: BorderRadius.only(
//                                                         topLeft: Radius.circular(8.0),
//                                                         topRight: Radius.circular(8.0),
//                                                         bottomRight: Radius.circular(8.0),
//                                                         bottomLeft: Radius.circular(8.0),
//                                                       ),
//                                                       child: SizedBox(
//                                                         width: 160,
//                                                         child: GestureDetector(
//                                                           onTap: () {
//                                                             Get.to(VideoFotoGosterSayfasi(
//                                                               gelenVideolink: mapYorumVideo,
//                                                               gelenFotolink: postFotolinki,
//                                                             ));
//                                                           },
//                                                           child: Image.network(
//                                                             postFotolinki,
//                                                             fit: BoxFit.fill,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 35,
//                                       child: Row(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.all(1.0),
//                                             child: IconButton(
//                                                 onPressed: () async {
//                                                   var kimeYorumEmaile = listOfDocumentSnap[index].get('bildirim');
//                                                   puanSa.put('yorumaEkle', kimeYorumEmaile.toString());
//                                                   print(
//                                                       '           ddd h                    h                  h               h' +
//                                                           puanSa.get('yorumaEkle'));
//
//                                                   CollectionReference kullanicilar =
//                                                       controllerNet.firestore.collection('Kullanicilar');
//                                                   var icerik = kullanicilar.doc(email);
//
//                                                   var secim = await icerik.get();
//                                                   dynamic map = secim.data();
//                                                   dynamic ide = map['id'];
//
//                                                   // var id = await listOfDocumentSnap[index]
//                                                   //     .reference
//                                                   //     .update({"id": FieldValue.increment(-1)});
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons.add,
//                                                   size: 40,
//                                                   color: Colors.blue,
//                                                 )),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(1.0),
//                                             child: kullanici.email == email.toString()
//                                                 ? IconButton(
//                                                     onPressed: () async {
//                                                       await FirebaseFirestore.instance
//                                                           .collection("postaYorum")
//                                                           .doc(postYorumIDe.toString())
//                                                           .update({
//                                                         "yorumSayisi": FieldValue.increment(-1),
//                                                         "bildirim": FieldValue.increment(-1)
//                                                       });
//
//                                                       await listOfDocumentSnap[index].reference.delete();
//                                                     },
//                                                     icon: const Icon(
//                                                       Icons.delete,
//                                                       size: 20,
//                                                       color: Colors.red,
//                                                     ))
//                                                 : Padding(
//                                                     padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2)),
//                                           ),
//                                           Row(
//                                             children: [
//                                               IconButton(
//                                                   onPressed: () async {
//                                                     final kullanici = FirebaseAuth.instance.currentUser!;
//                                                     final _firestore = FirebaseFirestore.instance;
//                                                     CollectionReference kullanicilar =
//                                                         _firestore.collection('Kullanicilar');
//                                                     var icerik = kullanicilar.doc(kullanici.email);
//                                                     var secim = await icerik.get();
//                                                     dynamic map = secim.data();
//
//                                                     dynamic unic = map['unic'];
//
//                                                     if (unic <= 0) {
//                                                     } else {
//                                                       if (email != kullanici.email) {
//                                                         if (bakBegenMeKontrol) {
//                                                           update({
//                                                             'begenMe': FieldValue.arrayRemove([kullanici.email])
//                                                           });
//                                                           update({'unic': FieldValue.increment(1)});
//
//                                                           await FirebaseFirestore.instance
//                                                               .collection("Kullanicilar")
//                                                               .doc(email.toString())
//                                                               .update({"unic": FieldValue.increment(1)});
//                                                         } else {
//                                                           controllerFonk.unicCikart();
//                                                           update({
//                                                             'begenMe': FieldValue.arrayUnion([kullanici.email])
//                                                           });
//                                                           update({'unic': FieldValue.increment(-1)});
//
//                                                           await FirebaseFirestore.instance
//                                                               .collection("Kullanicilar")
//                                                               .doc(email.toString())
//                                                               .update({"unic": FieldValue.increment(-1)});
//                                                         }
//                                                       }
//                                                     }
//                                                   },
//                                                   icon: Icon(
//                                                     Icons.heart_broken,
//                                                     size: 20,
//                                                     color: bakBegenMeKontrol ? Colors.red : Colors.white70,
//                                                   )),
//                                               Text(' ${begenMeKontrol.length}',
//                                                   style: TextStyle(fontSize: 13, color: Colors.white70)),
//                                             ],
//                                           ),
//                                           Row(
//                                             children: [
//                                               IconButton(
//                                                   onPressed: () async {
//                                                     await pozitifOyVer(
//                                                         listOfDocumentSnap, index, bakBegenKontrol, update, email);
//                                                   },
//                                                   icon: Icon(
//                                                     Icons.thumb_up_alt_rounded,
//                                                     size: 20,
//                                                     color: bakBegenKontrol ? Colors.cyan : Colors.white70,
//                                                   )),
//                                               Text('${begenKontrol.length}',
//                                                   style: TextStyle(fontSize: 13, color: Colors.white70)),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : Center(),
//                       );
//                     }),
//               );
//             } else {
//               /// yükleniyor bölümü
//               return buildDefaultTextStyle();
//             }
//           }
//         });
//   }
//
//   ///
// }
