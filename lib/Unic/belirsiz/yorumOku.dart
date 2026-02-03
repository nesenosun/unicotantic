// import 'dart:math';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:unicotantic/Unic/doluAkis/bosBuildAppBar.dart';
//
// import '../fonksiyonlar/buildDefaultTextStyle.dart';
// import '../profil/BenDrawer.dart';
// import '../profil/bosBenDrawer.dart';
//
// class YorumOku extends StatefulWidget {
//   const YorumOku({super.key});
//
//   @override
//   State<YorumOku> createState() => _YorumOkuState();
// }
//
// class _YorumOkuState extends State<YorumOku> {
//   final _firestore = FirebaseFirestore.instance;
//   double gozetop = Get.height / 5;
//   double gozeleft = Get.width / 4;
//
//   // Rastgele benzersiz sayı üretmek için kullanılacak fonksiyon
//   String generateRandomNumber() {
//     Random random = Random();
//     int randomNumber = random.nextInt(1000000);
//     return randomNumber.toString();
//   }
//
//   final puanSa = Hive.box('unicotantic');
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     CollectionReference yorumSorgu = _firestore.collection('postlar');
//     print(yorumSorgu.toString() + '  yorumSorgu 01');
//
//     var yicerik = yorumSorgu.doc();
//     print(yicerik.toString() + '  yicerik 02');
//
//     Query akisSorguy = _firestore.collection('yorumaYorum').orderBy("zaman", descending: false);
//
//     return SafeArea(
//       child: Scaffold(
//         appBar: reklamBuildAppBar(),
//         drawer: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               return const BenDrawer();
//             } else {
//               return const bosBenDrawer();
//             }
//           },
//         ),
//         body: Center(
//           child: Column(
//             children: [
//               StreamBuilder<QuerySnapshot>(
//                   stream: akisSorguy.snapshots(),
//                   builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                     if (asyncSnapshot.hasError) {
//                       return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                     } else {
//                       if (asyncSnapshot.hasData) {
//                         List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;
//                         //var suzgec = listOfDocumentSnap.indexWhere((element) => true) == puanSa.get('postAydi');
//
//                         return Flexible(
//                           child: ListView.builder(
//                               itemCount: listOfDocumentSnap.length,
//                               itemBuilder: (context, index) {
//                                 var begenKontrol = listOfDocumentSnap[index].get('begen');
//                                 var isim = listOfDocumentSnap[index].get('isim');
//                                 var soyisim = listOfDocumentSnap[index].get('soyisim');
//                                 var id = listOfDocumentSnap[index].get('id');
//                                 var tarih = listOfDocumentSnap[index].get('tarih');
//                                 var baslik = listOfDocumentSnap[index].get('metin');
//                                 var sehir = listOfDocumentSnap[index].get('sehir');
//                                 var iletisim = listOfDocumentSnap[index].get('iletisim');
//                                 var hakkinda = listOfDocumentSnap[index].get('hakkinda');
//                                 var dogumtarihi = listOfDocumentSnap[index].get('dogum tarihi');
//                                 var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
//                                 dynamic yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
//                                 var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
//                                 var profilresmilinki = listOfDocumentSnap[index].get('profilresmilinki');
//                                 var postAydi = listOfDocumentSnap[index].get('postAydi');
//                                 var email = listOfDocumentSnap[index].get('email');
//
//                                 return Container(
//                                   child: puanSa.get('postAydi') == postAydi
//                                       ? Card(
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             mainAxisAlignment: MainAxisAlignment.start,
//                                             children: [
//                                               Card(
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   mainAxisAlignment: MainAxisAlignment.start,
//                                                   children: [
//                                                     Row(
//                                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                                       mainAxisAlignment: MainAxisAlignment.start,
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                                                           child: ClipRRect(
//                                                             borderRadius: BorderRadius.only(
//                                                               topLeft: Radius.circular(15.0),
//                                                               bottomRight: Radius.circular(15.0),
//                                                             ),
//                                                             child: Container(
//                                                               color: Colors.blue,
//                                                               width: 40.0,
//                                                               height: 40.0,
//                                                               child: Image.network(
//                                                                 profilresmilinki,
//                                                                 fit: BoxFit.fill,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Column(
//                                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                                           mainAxisAlignment: MainAxisAlignment.start,
//                                                           children: [
//                                                             Text(' ' + isim + ' ' + soyisim,
//                                                                 textAlign: TextAlign.start,
//                                                                 style: TextStyle(
//                                                                     fontWeight: FontWeight.bold,
//                                                                     color: Colors.blueAccent,
//                                                                     fontSize: 14)),
//                                                             Text(
//                                                               ' @' + id.substring(5, 15) + ' ',
//                                                               style: const TextStyle(
//                                                                   fontSize: 11,
//                                                                   fontFamily: 'Montserrat',
//                                                                   fontWeight: FontWeight.bold,
//                                                                   color: Colors.white70),
//                                                             ),
//                                                             Text(' ' + tarih.toString() + ' ',
//                                                                 textAlign: TextAlign.center,
//                                                                 style: TextStyle(
//                                                                     //fontWeight: FontWeight.bold,
//                                                                     color: Colors.white60,
//                                                                     fontSize: 12)),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsets.all(5.0),
//                                                 child: Text(
//                                                   '${baslik}',
//                                                   textAlign: TextAlign.start,
//                                                   style: const TextStyle(
//                                                     fontSize: 14,
//                                                     color: Colors.green,
//                                                     fontFamily: 'montserrat',
//                                                     //fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                               ),
//                                               altButonlar(begenMeKontrol, begenKontrol, listOfDocumentSnap, index,
//                                                   yorumSayisi, postAydi, email),
//                                             ],
//                                           ),
//                                         )
//                                       : Center(),
//                                 );
//                               }),
//                         );
//                       } else {
//                         /// yükleniyor bölümü
//                         return buildDefaultTextStyle();
//                       }
//                     }
//                   }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Card isimTarihEnUstBolum(isim, soyisim, profilresmilinki, tarih, id) {
//     return Card(
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(15.0),
//                     bottomRight: Radius.circular(15.0),
//                   ),
//                   child: Container(
//                     color: Colors.blue,
//                     width: 40.0,
//                     height: 40.0,
//                     child: Image.network(
//                       profilresmilinki,
//                       fit: BoxFit.fill,
//                     ),
//                   ),
//                 ),
//               ),
//               Text(' ' + isim + ' ' + soyisim,
//                   textAlign: TextAlign.start,
//                   style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14)),
//             ],
//           ),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 ' @' + id.substring(5, 15) + ' ',
//                 style: const TextStyle(
//                     fontSize: 11, fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.white70),
//               ),
//               Text(' ' + tarih.toString() + ' ',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       //fontWeight: FontWeight.bold,
//                       color: Colors.white60,
//                       fontSize: 12)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Row profilFotoBaslikAcilanProfilBilgileri(
//       BuildContext context, isim, soyisim, profilresmilinki, id, sehir, iletisim, hakkinda, dogumtarihi, baslik) {
//     return Row(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//           child: ClipRRect(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(15.0),
//               bottomRight: Radius.circular(15.0),
//             ),
//             child: Container(
//               color: Colors.blue,
//               width: 70.0,
//               height: 70.0,
//               child: Image.network(
//                 profilresmilinki,
//                 fit: BoxFit.fill,
//               ),
//             ),
//           ),
//         ),
//         Flexible(
//           child: Text(
//             '${baslik}',
//             textAlign: TextAlign.start,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.green,
//               fontFamily: 'montserrat',
//               //fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   AlertDialog acilanProfilBilgileri(
//       isim, soyisim, profilresmilinki, id, sehir, iletisim, hakkinda, dogumtarihi, BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
//       contentPadding: EdgeInsets.only(top: 5.0),
//       title: Text(
//         '@' + id.substring(5, 15),
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           fontSize: 15,
//           fontFamily: 'Montserrat',
//           fontWeight: FontWeight.bold,
//           color: Colors.blue,
//         ),
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             SizedBox(
//               height: 300,
//               child: Image.network(
//                 profilresmilinki.toString(),
//                 fit: BoxFit.fill,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
//               child: Card(
//                 color: Colors.white12,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                   child: Text(
//                     isim.toString() + ' ' + soyisim.toString(),
//                     style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
//                   ),
//                 ),
//               ),
//             ),
//             kutuPaddingler(iletisim),
//             kutuPaddingler(sehir),
//             kutuPaddingler(dogumtarihi),
//             kutuPaddingler(hakkinda),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () => Navigator.pop(context, 'Kapat'),
//           child: const Text('Kapat'),
//         ),
//       ],
//     );
//   }
//
//   Padding kutuPaddingler(iletisim) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
//       child: Card(
//         color: Colors.white12,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//           child: Text(
//             iletisim.toString(),
//             style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Padding paddingKutulari(isim, soyisim) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
//       child: Text(
//         isim.toString() + ' ' + soyisim.toString(),
//         style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
//       ),
//     );
//   }
//
//   ///
//   SizedBox altButonlar(begenMeKontrol, begenKontrol, List<DocumentSnapshot<Object?>> listOfDocumentSnap, int index,
//       yorumSayisi, postAydi, email) {
//     return SizedBox(
//       // height: 150,
//       child: Card(
//         //color: Colors.blueGrey[700],
//         //shadowColor: contains ? Colors.greenAccent : Colors.yellow,
//
//         elevation: 0,
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Text(' ${begenMeKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
//                 IconButton(
//                     onPressed: () {},
//                     icon: Icon(
//                       Icons.heart_broken,
//                       size: 25,
//                       color: begenMeKontrol.length >= 1 ? Colors.red : Colors.white70,
//                     )),
//                 Text('${begenKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
//                 IconButton(
//                     onPressed: () {},
//                     icon: Icon(
//                       Icons.thumb_up_alt_rounded,
//                       size: 25,
//                       color: begenKontrol.length >= 1 ? Colors.green : Colors.white70,
//                     )),
//                 // IconButton(
//                 //     onPressed: () async {
//                 //       puanSa.put('postAydi', postAydi.toString());
//                 //       puanSa.put('email', email.toString());
//                 //       print(postAydi.toString());
//                 //       Get.to(YorumOku());
//                 //     },
//                 //     icon: Icon(
//                 //       Icons.mode_comment_sharp,
//                 //       size: 25,
//                 //       color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
//                 //     )),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   ///
// }
//
// ///
// ///
// ///
// ///
// ///
