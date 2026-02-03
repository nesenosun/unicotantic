// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:unicotantic/Unic/doluAkis/yorumaYorum.dart';
//
// import '../fonksiyonlar/buildDefaultTextStyle.dart';
// import '../fonksiyonlar/controllerFnksiyon.dart';
// import '../fonksiyonlar/controllerNet.dart';
//
// ///////////////////////////////////
// class YorumaYorumBildirimleri extends StatefulWidget {
//   const YorumaYorumBildirimleri({super.key});
//
//   @override
//   State<YorumaYorumBildirimleri> createState() => _YorumaYorumBildirimleriState();
// }
//
// class _YorumaYorumBildirimleriState extends State<YorumaYorumBildirimleri> {
//   final controllerNet = Get.put(ControllerNet());
//   final controllerFonk = Get.put(ControllerFonksiyon());
//   final kullanici = FirebaseAuth.instance.currentUser!;
//   final _firestore = FirebaseFirestore.instance;
//
//   final getbox = GetStorage();
//   GetStorage box = GetStorage();
//   dynamic puanSa = Hive.box('unicotantic');
//
//   @override
//   void initState() {
//     //firebaseIndirHiveYukleFonksiyonu();
//     // TODO: implement initState
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Query yorumSorgu = _firestore.collection('yorumaYorum').orderBy("zaman", descending: true).limit(100);
//
//     return Container(
//       child: StreamBuilder<QuerySnapshot>(
//           stream: yorumSorgu.snapshots(),
//           builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//             if (asyncSnapshot.hasError) {
//               return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//             } else {
//               if (asyncSnapshot.hasData) {
//                 List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;
//
//                 return Flexible(
//                   child: ListView.builder(
//                       itemCount: listOfDocumentSnap.length,
//                       itemBuilder: (context, index) {
//                         var email = listOfDocumentSnap[index].get('email');
//                         var tarih = listOfDocumentSnap[index].get('tarih');
//                         var baslik = listOfDocumentSnap[index].get('metin');
//                         var bildirim = listOfDocumentSnap[index].get('bildirim');
//                         var videoFoto = listOfDocumentSnap[index].get('soyisim');
//                         var kimeYorumEmail = listOfDocumentSnap[index].get('kimeYorumEmail');
//
//                         var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
//
//                         var postAydi = listOfDocumentSnap[index].get('postAydi');
//                         var postYorumID = listOfDocumentSnap[index].get('postYorumID');
//
//                         return Container(
//                           child: email == kullanici.email
//                               ? Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     bildirim >= 1
//                                         ? GestureDetector(
//                                             onTap: () async {
//                                               //listOfDocumentSnap[index].reference.update({"bildirim": 0});
//                                               Get.to(YorumaYorum(
//                                                 postYorumID: postYorumID.toString(),
//                                                 gelenKullaniciEmail: email.toString(),
//                                                 postAydi: postAydi.toString(),
//                                               ));
//                                             },
//                                             child: Card(
//                                               child: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 mainAxisAlignment: MainAxisAlignment.start,
//                                                 children: [
//                                                   Row(
//                                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                                     mainAxisAlignment: MainAxisAlignment.start,
//                                                     children: [
//                                                       Text(tarih.toString() + ' ',
//                                                           textAlign: TextAlign.center,
//                                                           style: TextStyle(
//                                                               //fontWeight: FontWeight.bold,
//                                                               color: Colors.white60,
//                                                               fontSize: 12)),
//                                                       //postuDuzenleIconu(email, postAydi),
//                                                     ],
//                                                   ),
//                                                   Row(
//                                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                                     mainAxisAlignment: MainAxisAlignment.center,
//                                                     children: [
//                                                       Padding(
//                                                         padding: const EdgeInsets.all(2.0),
//                                                         child: videoFoto == ''
//                                                             ? Center()
//                                                             : ClipRRect(
//                                                                 borderRadius: BorderRadius.only(
//                                                                   topLeft: Radius.circular(15.0),
//                                                                   topRight: Radius.circular(15.0),
//                                                                   bottomRight: Radius.circular(15.0),
//                                                                   bottomLeft: Radius.circular(15.0),
//                                                                 ),
//                                                                 child: SizedBox(
//                                                                   width: 120,
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
//                                                       ),
//                                                       Padding(
//                                                         padding: const EdgeInsets.all(2.0),
//                                                         child: postFotolinki == 'bos'
//                                                             ? Center()
//                                                             : ClipRRect(
//                                                                 borderRadius: BorderRadius.only(
//                                                                   topLeft: Radius.circular(8.0),
//                                                                   topRight: Radius.circular(8.0),
//                                                                   bottomRight: Radius.circular(8.0),
//                                                                   bottomLeft: Radius.circular(8.0),
//                                                                 ),
//                                                                 child: SizedBox(
//                                                                   width: 120,
//                                                                   child: Image.network(
//                                                                     postFotolinki,
//                                                                     fit: BoxFit.fill,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(5.0),
//                                                     child: Text(
//                                                       '${baslik}',
//                                                       textAlign: TextAlign.start,
//                                                       style: const TextStyle(
//                                                         fontWeight: FontWeight.normal,
//                                                         fontSize: 14,
//                                                         color: Colors.green,
//                                                         fontFamily: 'montserrat',
//                                                         //fontWeight: FontWeight.w500,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(5.0),
//                                                     child: Text(
//                                                       'Yorumunuza cevap verildi',
//                                                       textAlign: TextAlign.end,
//                                                       style: const TextStyle(
//                                                         fontWeight: FontWeight.normal,
//                                                         fontSize: 14,
//                                                         color: Colors.white70,
//                                                         fontFamily: 'montserrat',
//                                                         //fontWeight: FontWeight.w500,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           )
//                                         : Center(),
//                                   ],
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
//   ///
//
//   ///
// }
