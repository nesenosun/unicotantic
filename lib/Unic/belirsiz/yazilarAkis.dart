// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:pinch_zoom/pinch_zoom.dart';
//
// import '../fonksiyonlar/buildDefaultTextStyle.dart';
// import '../fonksiyonlar/profilResmiGetir.dart';
// import '../profil/BenDrawer.dart';
// import '../profil/bosBenDrawer.dart';
// import 'bosBuildAppBar.dart';
//
// class YazilarAkis extends StatefulWidget {
//   const YazilarAkis({super.key});
//
//   @override
//   State<YazilarAkis> createState() => _YazilarAkisState();
// }
//
// class _YazilarAkisState extends State<YazilarAkis> {
//   final _firestore = FirebaseFirestore.instance;
//
//   final puanSa = Hive.box('unicotantic');
//
//   @override
//   Widget build(BuildContext context) {
//     Query akisSorgu = _firestore.collection('postlar').orderBy("zaman", descending: true).limit(100);
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
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               StreamBuilder<QuerySnapshot>(
//                   stream: akisSorgu.snapshots(),
//                   builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                     if (asyncSnapshot.hasError) {
//                       return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                     } else {
//                       if (asyncSnapshot.hasData) {
//                         List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;
//
//                         return Flexible(
//                           child: ListView.builder(
//                               itemCount: listOfDocumentSnap.length,
//                               itemBuilder: (context, index) {
//                                 var begenKontrol = listOfDocumentSnap[index].get('begen');
//                                 var id = listOfDocumentSnap[index].get('id');
//                                 var tarih = listOfDocumentSnap[index].get('tarih');
//                                 var baslik = listOfDocumentSnap[index].get('baslik');
//                                 var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
//                                 dynamic yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
//                                 var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
//                                 var email = listOfDocumentSnap[index].get('email');
//                                 var videoFoto = listOfDocumentSnap[index].get('soyisim');
//
//                                 dynamic profilResmiCikar(email) {
//                                   return profilResmiGetir(email);
//                                 }
//
//                                 dynamic profilIsmiCikar(email) {
//                                   return profilIsmiGetir(email);
//                                 }
//
//                                 dynamic unicCikar(email) {
//                                   return profilUnicGetir(email);
//                                 }
//
//                                 return Container(
//                                   child: Card(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: [
//                                         Wrap(
//                                           children: [
//                                             Card(
//                                               child: Row(
//                                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                                 mainAxisAlignment: MainAxisAlignment.start,
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                                                     child: Padding(
//                                                       padding: const EdgeInsets.only(right: 8),
//                                                       child: ClipRRect(
//                                                         borderRadius: BorderRadius.only(
//                                                           topLeft: Radius.circular(15.0),
//                                                           bottomRight: Radius.circular(15.0),
//                                                         ),
//                                                         child: Container(
//                                                           //color: Colors.blue,
//                                                           width: 50.0,
//                                                           height: 50.0,
//                                                           child: GestureDetector(
//                                                             onTap: () async {},
//                                                             child: profilResmiCikar(email.toString()),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Column(
//                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                     mainAxisAlignment: MainAxisAlignment.start,
//                                                     children: [
//                                                       profilIsmiCikar(email),
//                                                       Row(
//                                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                                         children: [
//                                                           Text(
//                                                             '@' + id.substring(5, 15) + ' ',
//                                                             style: const TextStyle(
//                                                                 fontSize: 12,
//                                                                 //fontFamily: 'Montserrat',
//                                                                 fontWeight: FontWeight.bold,
//                                                                 color: Colors.white60),
//                                                           ),
//                                                           Card(
//                                                             child: unicCikar(email),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       Padding(
//                                                         padding: const EdgeInsets.only(bottom: 2),
//                                                         child: Text(tarih.toString() + ' ',
//                                                             textAlign: TextAlign.center,
//                                                             style: TextStyle(
//                                                                 //fontWeight: FontWeight.bold,
//                                                                 color: Colors.white60,
//                                                                 fontSize: 10)),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   //postuDuzenleIconu(email, postAydi),
//                                                 ],
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.all(5.0),
//                                               child: Text(
//                                                 '${baslik}',
//                                                 textAlign: TextAlign.start,
//                                                 style: GoogleFonts.aBeeZee(
//                                                   fontWeight: FontWeight.normal,
//                                                   fontSize: 15,
//                                                   color: Colors.white60,
//                                                   //fontFamily: 'montserrat',
//                                                   //fontWeight: FontWeight.w500,
//                                                 ),
//                                               ),
//                                             ),
//                                             Card(
//                                               child: Row(
//                                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(2.0),
//                                                     child: videoFoto == ''
//                                                         ? Center()
//                                                         : PinchZoom(
//                                                             onZoomStart: () {},
//                                                             onZoomEnd: () {},
//                                                             child: ClipRRect(
//                                                               borderRadius: BorderRadius.only(
//                                                                 topLeft: Radius.circular(15.0),
//                                                                 topRight: Radius.circular(15.0),
//                                                                 bottomRight: Radius.circular(15.0),
//                                                                 bottomLeft: Radius.circular(15.0),
//                                                               ),
//                                                               child: SizedBox(
//                                                                 width: 160,
//                                                                 child: GestureDetector(
//                                                                   onTap: () {},
//                                                                   child: Stack(
//                                                                     //fit: StackFit.expand,
//                                                                     alignment: Alignment.center,
//                                                                     children: [
//                                                                       Image.network(
//                                                                         videoFoto,
//                                                                         fit: BoxFit.fill,
//                                                                       ),
//                                                                       SizedBox(
//                                                                           height: 50,
//                                                                           child: Image.asset(
//                                                                               'assets/images/png/play.png')),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                   ),
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(2.0),
//                                                     child: postFotolinki == 'bos'
//                                                         ? Center()
//                                                         : PinchZoom(
//                                                             onZoomStart: () {},
//                                                             onZoomEnd: () {},
//                                                             child: ClipRRect(
//                                                               borderRadius: BorderRadius.only(
//                                                                 topLeft: Radius.circular(8.0),
//                                                                 topRight: Radius.circular(8.0),
//                                                                 bottomRight: Radius.circular(8.0),
//                                                                 bottomLeft: Radius.circular(8.0),
//                                                               ),
//                                                               child: SizedBox(
//                                                                 width: 160,
//                                                                 child: GestureDetector(
//                                                                   onTap: () {},
//                                                                   child: Image.network(
//                                                                     postFotolinki,
//                                                                     fit: BoxFit.fill,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               height: 35,
//                                               child: Row(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                 children: [
//                                                   Row(
//                                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                                     mainAxisAlignment: MainAxisAlignment.center,
//                                                     children: [
//                                                       IconButton(
//                                                           onPressed: () async {},
//                                                           icon: Icon(
//                                                             Icons.heart_broken,
//                                                             size: 20,
//                                                             color: Colors.white70,
//                                                           )),
//                                                       Text(' ${begenMeKontrol.length}',
//                                                           style: TextStyle(fontSize: 13, color: Colors.white70)),
//                                                     ],
//                                                   ),
//                                                   Row(
//                                                     children: [
//                                                       IconButton(
//                                                           onPressed: () async {},
//                                                           icon: Icon(
//                                                             Icons.thumb_up_alt_rounded,
//                                                             size: 20,
//                                                             color: Colors.white70,
//                                                           )),
//                                                       Text('${begenKontrol.length}',
//                                                           style: TextStyle(fontSize: 13, color: Colors.white70)),
//                                                     ],
//                                                   ),
//                                                   Row(
//                                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                                     mainAxisAlignment: MainAxisAlignment.end,
//                                                     children: [
//                                                       IconButton(
//                                                           onPressed: () async {},
//                                                           icon: Icon(
//                                                             Icons.mode_comment_sharp,
//                                                             size: 20,
//                                                             color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
//                                                           )),
//                                                       Text('${yorumSayisi}' + '  ',
//                                                           style: TextStyle(
//                                                               fontSize: 13,
//                                                               color: Colors.white70,
//                                                               fontWeight: FontWeight.bold)),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
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
//   Row akistanGelenYazi(
//       BuildContext context, isim, soyisim, profilresmilinki, id, sehir, iletisim, hakkinda, dogumtarihi, baslik) {
//     return Row(
//       children: [
//         Flexible(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               '${baslik}',
//               textAlign: TextAlign.start,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.green,
//                 fontFamily: 'montserrat',
//                 //fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   AlertDialog acilanMesajBilgileri(
//       isim, soyisim, profilresmilinki, id, sehir, iletisim, hakkinda, dogumtarihi, BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
//       contentPadding: EdgeInsets.only(top: 5.0),
//       title: Text(
//         'Üye Olmadan Yorumları Göremezsiniz',
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           fontSize: 15,
//           fontFamily: 'Montserrat',
//           fontWeight: FontWeight.bold,
//           color: Colors.blue,
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
//   ///
//
//   ///
// }
//
// ///
// ///
// ///
// ///
// ///
