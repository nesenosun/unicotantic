// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:unicotantic/Unic/doluAkis/videoPlayrFlick.dart';
// import 'package:unicotantic/Unic/profil/baskasininAkisaMetinGir.dart';
// import 'package:unicotantic/Unic/profil/ziyaretciProfilAkis.dart';
// import 'package:video_player/video_player.dart';
//
// import '../doluAkis/doluAkisAppBar.dart';
// import '../fonksiyonlar/buildDefaultTextStyle.dart';
// import '../fonksiyonlar/controllerNet.dart';
// import '../fonksiyonlar/negatifOyVer_pozitifOyVer.dart';
// import '../fonksiyonlar/profilResmiGetir.dart';
// import 'BenDrawer.dart';
// import 'ziyaretciProfilYorumBolumu.dart';
//
// class BaskasininAkisi extends StatefulWidget {
//   const BaskasininAkisi({super.key});
//
//   @override
//   State<BaskasininAkisi> createState() => _BaskasininAkisiState();
// }
//
// class _BaskasininAkisiState extends State<BaskasininAkisi> {
//   final controllerNet = Get.put(ControllerNet());
//
//   final kullanici = FirebaseAuth.instance.currentUser!;
//   final _firestore = FirebaseFirestore.instance;
//   final puanSa = Hive.box('unicotantic');
//   bool kapat = false;
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   late final VideoPlayerController controller;
//   final gidecekVideoLinki =
//       'https://firebasestorage.googleapis.com/v0/b/unic-otantic-e4f32.appspot.com/o/postVideolari%2F3195353059890115276.mp4?alt=media&token=09aa881f-416d-40ef-8d6c-ca0be546b2f7&_gl=1*krfqyo*_ga*OTUyNTQyNzIzLjE2ODY0ODM1MDc.*_ga_CW55HF8NVT*MTY5OTAwNDY2NC4yNDIuMS4xNjk5MDA0ODgwLjQ2LjAuMA..';
//   final gidecekVideoLinki2 = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
//   @override
//   void initState() {
//     super.initState();
//     puanSa.put('yorumYapanEmail', '');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var puanSaEmail = puanSa.get('email');
//
//     CollectionReference kullaniciSorgu = controllerNet.firestore.collection('Kullanicilar');
//
//     var kullaniciBilgileri = kullaniciSorgu.doc(puanSaEmail.toString());
//
//     Query postlarSorgu = _firestore
//         .collection('Kullanicilar')
//         .doc(puanSaEmail)
//         .collection('bireyselAkis')
//         .orderBy("zaman", descending: true)
//         .limit(100);
//     bool buyut = true;
//
//     return Scaffold(
//       //backgroundColor: Colors.black38,
//       appBar: DoluAkisAppBar(),
//       drawer: const BenDrawer(),
//       body: Center(
//         child: StreamBuilder<DocumentSnapshot>(
//             stream: kullaniciBilgileri.snapshots(),
//             builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//               if (asyncSnapshot.hasError) {
//                 return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//               } else {
//                 if (asyncSnapshot.hasData) {
//                   var ziyaretciProfilResmiLinki = asyncSnapshot.data.data()['profilresmilinki'];
//                   var isim = asyncSnapshot.data.data()['isim'];
//                   var soyisim = asyncSnapshot.data.data()['soyisim'];
//                   var sehir = asyncSnapshot.data.data()['sehir'];
//                   var iletisim = asyncSnapshot.data.data()['iletisim'];
//                   var unic = asyncSnapshot.data.data()['unic'];
//                   var uid = asyncSnapshot.data.data()['uid'];
//                   var hakkinda = asyncSnapshot.data.data()['hakkinda'];
//                   var dogumTarihi = asyncSnapshot.data.data()['dogum tarihi'];
//                   var email = asyncSnapshot.data.data()['email'];
//                   var engelleyenler = asyncSnapshot.data.data()['engelleyenler'];
//                   var arkadaslar = asyncSnapshot.data.data()['arkadaslar'];
//                   var begen = asyncSnapshot.data.data()['begen'];
//                   var engelledim = asyncSnapshot.data.data()['engelledim'];
//                   dynamic arkadaslarIcindemi = arkadaslar.contains(kullanici.email);
//                   dynamic engelledimGetir = engelledim.contains(kullanici.email);
//
//                   return Stack(
//                     children: [
//                       Column(
//                         children: [
//                           kapat == false
//                               ? GestureDetector(
//                                   onTap: () {
//                                     kapat = true;
//                                     setState(() {});
//                                   },
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Expanded(
//                                             child: GestureDetector(
//                                               onTap: () async {
//                                                 final _firestore = FirebaseFirestore.instance;
//                                                 CollectionReference kullanicilar =
//                                                     _firestore.collection('Kullanicilar');
//                                                 var icerik = kullanicilar.doc(kullanici.email);
//                                                 var secim = await icerik.get();
//                                                 dynamic map = secim.data();
//
//                                                 dynamic unic = map['unic'];
//                                                 dynamic arkadaslar = map['arkadaslar'];
//                                                 unicCikar();
//
//                                                 if (unic <= 0) {
//                                                 } else {
//                                                   if (email != kullanici.email) {
//                                                     if (arkadaslar.contains(email)) {
//                                                       await FirebaseFirestore.instance
//                                                           .collection("Kullanicilar")
//                                                           .doc(kullanici.email)
//                                                           .update({
//                                                         'arkadaslar': FieldValue.arrayRemove([email.toString()])
//                                                       }).whenComplete(() {
//                                                         print('kullanıcı engellendi');
//                                                       });
//                                                       await FirebaseFirestore.instance
//                                                           .collection("Kullanicilar")
//                                                           .doc(email.toString())
//                                                           .update({
//                                                         "begen": FieldValue.arrayRemove([kullanici.email.toString()])
//                                                       });
//                                                     } else {
//                                                       await FirebaseFirestore.instance
//                                                           .collection("Kullanicilar")
//                                                           .doc(kullanici.email)
//                                                           .update({
//                                                         'arkadaslar': FieldValue.arrayUnion([email.toString()])
//                                                       }).whenComplete(() {
//                                                         print('kullanıcı engellendi');
//                                                       });
//                                                       await FirebaseFirestore.instance
//                                                           .collection("Kullanicilar")
//                                                           .doc(email.toString())
//                                                           .update({
//                                                         "begen": FieldValue.arrayUnion([kullanici.email.toString()])
//                                                       });
//                                                     }
//                                                   }
//                                                 }
//                                               },
//                                               child: Card(
//                                                 color: begen.contains(kullanici.email) ? Colors.green : Colors.black87,
//                                                 child: Padding(
//                                                   padding: const EdgeInsets.all(8.0),
//                                                   child: begen.contains(kullanici.email)
//                                                       ? Text(
//                                                           'Akışta',
//                                                           style: TextStyle(
//                                                               fontFamily: 'Avenir',
//                                                               fontSize: 14,
//                                                               color: Colors.black,
//                                                               fontWeight: FontWeight.bold),
//                                                           textAlign: TextAlign.center,
//                                                         )
//                                                       : Text(
//                                                           'Akışa Al',
//                                                           style: TextStyle(
//                                                               fontFamily: 'Avenir',
//                                                               fontSize: 14,
//                                                               color: Colors.white70,
//                                                               fontWeight: FontWeight.normal),
//                                                           textAlign: TextAlign.center,
//                                                         ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Expanded(
//                                             child: GestureDetector(
//                                               onTap: () async {
//                                                 await engelleFonksiyonu(email);
//                                               },
//                                               child: Card(
//                                                 color: engelleyenler.contains(kullanici.email)
//                                                     ? Colors.red
//                                                     : Colors.black87,
//                                                 child: Padding(
//                                                   padding: const EdgeInsets.all(8.0),
//                                                   child: engelleyenler.contains(kullanici.email)
//                                                       ? Text(
//                                                           'Engellendi',
//                                                           style: TextStyle(
//                                                               fontFamily: 'Avenir',
//                                                               fontSize: 14,
//                                                               color: Colors.black,
//                                                               fontWeight: FontWeight.normal),
//                                                           textAlign: TextAlign.center,
//                                                         )
//                                                       : Text(
//                                                           'Engelle',
//                                                           style: TextStyle(
//                                                               fontFamily: 'Avenir',
//                                                               fontSize: 14,
//                                                               color: Colors.white70,
//                                                               fontWeight: FontWeight.normal),
//                                                           textAlign: TextAlign.center,
//                                                         ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         children: [
//                                           Expanded(
//                                             flex: 1,
//                                             child: Stack(children: [
//                                               CircleAvatar(
//                                                 backgroundColor: Colors.white70,
//                                                 radius: 60,
//                                                 child: ClipOval(
//                                                   child: Image.network(
//                                                     ziyaretciProfilResmiLinki.toString(),
//                                                     width: 110,
//                                                     height: 110,
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ]),
//                                           ),
//                                           Expanded(
//                                             flex: 2,
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(5.0),
//                                               child: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 mainAxisAlignment: MainAxisAlignment.start,
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(3.0),
//                                                     child: Text(
//                                                         style: TextStyle(
//                                                             //fontFamily: 'Montserrat',
//                                                             fontSize: 12,
//                                                             color: Colors.greenAccent,
//                                                             fontWeight: FontWeight.bold,
//                                                             shadows: [
//                                                               BoxShadow(
//                                                                   color: Colors.red.withOpacity(.15),
//                                                                   offset: Offset(2.0, 2.0),
//                                                                   blurRadius: 10),
//                                                             ]),
//                                                         '@' +
//                                                             uid.toString().substring(5, 15) +
//                                                             '    ' +
//                                                             'Unic: ' +
//                                                             unic.toString(),
//                                                         textAlign: TextAlign.center),
//                                                   ),
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(3.0),
//                                                     child: Text(
//                                                         style: TextStyle(
//                                                             fontFamily: 'Montserrat',
//                                                             fontSize: 12,
//                                                             color: Colors.greenAccent,
//                                                             fontWeight: FontWeight.bold,
//                                                             shadows: [
//                                                               BoxShadow(
//                                                                   color: Colors.red.withOpacity(.15),
//                                                                   offset: Offset(2.0, 2.0),
//                                                                   blurRadius: 10),
//                                                             ]),
//                                                         isim.toString() + ' ' + soyisim.toString(),
//                                                         textAlign: TextAlign.center),
//                                                   ),
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(3.0),
//                                                     child: Text(
//                                                         style: TextStyle(
//                                                             fontFamily: 'Montserrat',
//                                                             fontSize: 12,
//                                                             color: Colors.greenAccent,
//                                                             fontWeight: FontWeight.bold,
//                                                             shadows: [
//                                                               BoxShadow(
//                                                                   color: Colors.red.withOpacity(.15),
//                                                                   offset: Offset(2.0, 2.0),
//                                                                   blurRadius: 10),
//                                                             ]),
//                                                         sehir.toString() + '       ' + dogumTarihi.toString(),
//                                                         textAlign: TextAlign.center),
//                                                   ),
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(2.0),
//                                                     child: Text(
//                                                         style: TextStyle(
//                                                             fontFamily: 'Montserrat',
//                                                             fontSize: 13,
//                                                             color: Colors.greenAccent,
//                                                             fontWeight: FontWeight.bold,
//                                                             shadows: [
//                                                               BoxShadow(
//                                                                   color: Colors.red.withOpacity(.15),
//                                                                   offset: Offset(2.0, 2.0),
//                                                                   blurRadius: 10),
//                                                             ]),
//                                                         iletisim.toString(),
//                                                         textAlign: TextAlign.center),
//                                                   ),
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(2.0),
//                                                     child: Text(
//                                                         style: TextStyle(
//                                                             fontFamily: 'Montserrat',
//                                                             fontSize: 11,
//                                                             color: Colors.orangeAccent[700],
//                                                             fontWeight: FontWeight.bold,
//                                                             shadows: [
//                                                               BoxShadow(
//                                                                   color: Colors.red.withOpacity(.15),
//                                                                   offset: Offset(2.0, 2.0),
//                                                                   blurRadius: 10),
//                                                             ]),
//                                                         hakkinda.toString(),
//                                                         textAlign: TextAlign.center),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       engelledimGetir
//                                           ? Center()
//                                           : Row(
//                                               crossAxisAlignment: CrossAxisAlignment.center,
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               children: [
//                                                 Expanded(
//                                                   child: GestureDetector(
//                                                     onTap: () {
//                                                       Get.to(ZiyaretciProfilAkis(
//                                                         gelenKullaniciEmail: puanSa.get('email'),
//                                                       ));
//                                                     },
//                                                     child: Card(
//                                                       color: Colors.black87,
//                                                       child: Padding(
//                                                         padding: const EdgeInsets.all(8.0),
//                                                         child: Text(
//                                                           'Postlar',
//                                                           style: TextStyle(
//                                                               fontFamily: 'Avenir',
//                                                               fontSize: 14,
//                                                               color: Colors.white70,
//                                                               fontWeight: FontWeight.normal),
//                                                           textAlign: TextAlign.center,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Expanded(
//                                                   child: GestureDetector(
//                                                     onTap: () {
//                                                       Get.to(ZiyaretciProfilYorumBolumu(
//                                                         gelenKullaniciEmail: puanSa.get('email'),
//                                                       ));
//                                                     },
//                                                     child: Card(
//                                                       color: Colors.black87,
//                                                       child: Padding(
//                                                         padding: const EdgeInsets.all(8.0),
//                                                         child: Text(
//                                                           'Yorumlar',
//                                                           style: TextStyle(
//                                                               fontFamily: 'Avenir',
//                                                               fontSize: 14,
//                                                               color: Colors.white70,
//                                                               fontWeight: FontWeight.bold),
//                                                           textAlign: TextAlign.center,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 engelledim.contains(kullanici.email)
//                                                     ? Center()
//                                                     : Expanded(
//                                                         child: GestureDetector(
//                                                           onTap: () {
//                                                             puanSa.put('email', puanSaEmail);
//                                                             Get.to(BaskasininAkisi());
//                                                           },
//                                                           child: Card(
//                                                             color: Colors.cyan,
//                                                             child: Padding(
//                                                               padding: const EdgeInsets.all(8.0),
//                                                               child: Text(
//                                                                 'Akış',
//                                                                 style: TextStyle(
//                                                                     fontFamily: 'Avenir',
//                                                                     fontSize: 14,
//                                                                     color: Colors.white70,
//                                                                     fontWeight: FontWeight.normal),
//                                                                 textAlign: TextAlign.center,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                               ],
//                                             ),
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Expanded(
//                                             child: Card(
//                                               color: Colors.black87,
//                                               child: Padding(
//                                                 padding: const EdgeInsets.all(8.0),
//                                                 child: Text(
//                                                   'Yalnızca Postları Göster',
//                                                   style: TextStyle(
//                                                       fontFamily: 'Avenir',
//                                                       fontSize: 14,
//                                                       color: Colors.white70,
//                                                       fontWeight: FontWeight.normal),
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               : Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           kapat = false;
//                                           setState(() {});
//                                         },
//                                         child: Card(
//                                           color: Colors.transparent,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Text(
//                                                 style: TextStyle(
//                                                     fontFamily: 'Montserrat',
//                                                     fontSize: 12,
//                                                     color: Colors.greenAccent,
//                                                     fontWeight: FontWeight.bold,
//                                                     shadows: [
//                                                       BoxShadow(
//                                                           color: Colors.red.withOpacity(.15),
//                                                           offset: Offset(2.0, 2.0),
//                                                           blurRadius: 10),
//                                                     ]),
//                                                 isim.toString() + ' ' + soyisim.toString() + ' Akış',
//                                                 textAlign: TextAlign.center),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                           Container(height: 2, color: Colors.red),
//                           engelledimGetir
//                               ? Center()
//                               : Container(
//                                   child: StreamBuilder<QuerySnapshot>(
//                                       stream: postlarSorgu.snapshots(),
//                                       builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                                         if (asyncSnapshot.hasError) {
//                                           return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                                         } else {
//                                           if (asyncSnapshot.hasData) {
//                                             List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;
//
//                                             return Flexible(
//                                               child: ListView.builder(
//                                                   itemCount: listOfDocumentSnap.length,
//                                                   itemBuilder: (context, index) {
//                                                     var begenKontrol = listOfDocumentSnap[index].get('begen');
//                                                     var email = listOfDocumentSnap[index].get('email');
//                                                     var id = listOfDocumentSnap[index].get('id');
//                                                     var tarih = listOfDocumentSnap[index].get('tarih');
//                                                     var baslik = listOfDocumentSnap[index].get('baslik');
//                                                     var duzenlemeMetin = listOfDocumentSnap[index].get('metin');
//                                                     var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
//                                                     var mapYorumVideo = listOfDocumentSnap[index].get('mapYorum');
//                                                     //var isimVideo = listOfDocumentSnap[index].get('isim');
//                                                     var videoFoto = listOfDocumentSnap[index].get('soyisim');
//                                                     var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
//
//                                                     var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
//
//                                                     var postAydi = listOfDocumentSnap[index].get('postAydi');
//                                                     var update = listOfDocumentSnap[index].reference.update;
//                                                     var bakBegenKontrol = begenKontrol.contains(kullanici.email);
//                                                     var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);
//
//                                                     dynamic profilResmiCikar(email) {
//                                                       return profilResmiGetir(email);
//                                                     }
//
//                                                     dynamic profilIsmiCikar(email) {
//                                                       return profilIsmiGetir(email);
//                                                     }
//
//                                                     dynamic profilSoyIsimCikar(email) {
//                                                       return profilSoyisimGetir(email);
//                                                     }
//
//                                                     dynamic unicCikar(email) {
//                                                       return profilUnicGetir(email);
//                                                     }
//
//                                                     return GestureDetector(
//                                                       onTap: () {
//                                                         puanSa.put('postAydi', postAydi.toString());
//                                                         puanSa.put('email', email.toString());
//                                                         print(postAydi.toString());
//                                                         //Get.to(DoluYorumOku());
//                                                       },
//                                                       child: Card(
//                                                         child: Column(
//                                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                                           mainAxisAlignment: MainAxisAlignment.center,
//                                                           children: [
//                                                             Row(
//                                                               crossAxisAlignment: CrossAxisAlignment.center,
//                                                               mainAxisAlignment: MainAxisAlignment.start,
//                                                               children: [
//                                                                 Padding(
//                                                                   padding: const EdgeInsets.symmetric(
//                                                                       vertical: 2, horizontal: 2),
//                                                                   child: Padding(
//                                                                     padding: const EdgeInsets.only(right: 8),
//                                                                     child: ClipRRect(
//                                                                       borderRadius: BorderRadius.only(
//                                                                         topLeft: Radius.circular(15.0),
//                                                                         bottomRight: Radius.circular(15.0),
//                                                                       ),
//                                                                       child: Container(
//                                                                         //color: Colors.blue,
//                                                                         width: 42.0,
//                                                                         height: 42.0,
//                                                                         child: GestureDetector(
//                                                                           onTap: () async {
//                                                                             // puanSa.put('postAydi', postAydi.toString());
//                                                                             puanSa.put('email', email.toString());
//                                                                             Get.to(ZiyaretciProfilAkis(
//                                                                                 gelenKullaniciEmail: email));
//                                                                           },
//                                                                           child: profilResmiCikar(email.toString()),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                                 Column(
//                                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                                   mainAxisAlignment: MainAxisAlignment.start,
//                                                                   children: [
//                                                                     Row(
//                                                                       children: [
//                                                                         profilIsmiCikar(email),
//                                                                         SizedBox(width: 3),
//                                                                         profilSoyIsimCikar(email),
//                                                                       ],
//                                                                     ),
//                                                                     Row(
//                                                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                                                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                                                       children: [
//                                                                         Text(
//                                                                           '@' + id.substring(5, 15) + ' ',
//                                                                           style: const TextStyle(
//                                                                               fontSize: 12,
//                                                                               //fontFamily: 'Montserrat',
//                                                                               fontWeight: FontWeight.bold,
//                                                                               color: Colors.white70),
//                                                                         ),
//                                                                         Card(
//                                                                           child: unicCikar(email),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                     duzenlemeMetin == ''
//                                                                         ? Text(tarih.toString() + ' ',
//                                                                             textAlign: TextAlign.center,
//                                                                             style: TextStyle(
//                                                                                 //fontWeight: FontWeight.bold,
//                                                                                 color: Colors.white60,
//                                                                                 fontSize: 12))
//                                                                         : GestureDetector(
//                                                                             onTap: () {
//                                                                               puanSa.put(
//                                                                                   'postAydi', postAydi.toString());
//                                                                               puanSa.put('email', email.toString());
//                                                                               //Get.to(DuzenlemeleriGor());
//                                                                             },
//                                                                             child:
//                                                                                 Text(tarih.toString() + '  düzenlendi ',
//                                                                                     textAlign: TextAlign.center,
//                                                                                     style: TextStyle(
//                                                                                         //fontWeight: FontWeight.bold,
//                                                                                         color: Colors.redAccent,
//                                                                                         fontSize: 12)),
//                                                                           ),
//                                                                   ],
//                                                                 ),
//                                                                 //postuDuzenleIconu(email, postAydi),
//                                                               ],
//                                                             ),
//                                                             Row(
//                                                               crossAxisAlignment: CrossAxisAlignment.end,
//                                                               mainAxisAlignment: MainAxisAlignment.center,
//                                                               children: [
//                                                                 Padding(
//                                                                   padding: const EdgeInsets.all(2.0),
//                                                                   child: videoFoto == ''
//                                                                       ? Center()
//                                                                       : ClipRRect(
//                                                                           borderRadius: BorderRadius.only(
//                                                                             topLeft: Radius.circular(15.0),
//                                                                             topRight: Radius.circular(15.0),
//                                                                             bottomRight: Radius.circular(15.0),
//                                                                             bottomLeft: Radius.circular(15.0),
//                                                                           ),
//                                                                           child: SizedBox(
//                                                                             width: 160,
//                                                                             child: GestureDetector(
//                                                                               onTap: () {
//                                                                                 Get.to(VideoFotoGosterSayfasi(
//                                                                                   gelenVideolink: mapYorumVideo,
//                                                                                   gelenFotolink: postFotolinki,
//                                                                                 ));
//                                                                               },
//                                                                               child: Stack(
//                                                                                 //fit: StackFit.expand,
//                                                                                 alignment: Alignment.center,
//                                                                                 children: [
//                                                                                   Image.network(
//                                                                                     videoFoto,
//                                                                                     fit: BoxFit.fill,
//                                                                                   ),
//                                                                                   SizedBox(
//                                                                                       height: 50,
//                                                                                       child: Image.asset(
//                                                                                           'assets/images/png/play.png')),
//                                                                                 ],
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                 ),
//                                                                 Padding(
//                                                                   padding: const EdgeInsets.all(2.0),
//                                                                   child: postFotolinki == 'bos'
//                                                                       ? Center()
//                                                                       : ClipRRect(
//                                                                           borderRadius: BorderRadius.only(
//                                                                             topLeft: Radius.circular(8.0),
//                                                                             topRight: Radius.circular(8.0),
//                                                                             bottomRight: Radius.circular(8.0),
//                                                                             bottomLeft: Radius.circular(8.0),
//                                                                           ),
//                                                                           child: SizedBox(
//                                                                             width: 160,
//                                                                             child: GestureDetector(
//                                                                               onTap: () {
//                                                                                 Get.to(VideoFotoGosterSayfasi(
//                                                                                   gelenVideolink: mapYorumVideo,
//                                                                                   gelenFotolink: postFotolinki,
//                                                                                 ));
//                                                                               },
//                                                                               child: Image.network(
//                                                                                 postFotolinki,
//                                                                                 fit: BoxFit.fill,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                             Padding(
//                                                               padding: const EdgeInsets.all(5.0),
//                                                               child: Text(
//                                                                 '${baslik}',
//                                                                 textAlign: TextAlign.start,
//                                                                 style: const TextStyle(
//                                                                   fontWeight: FontWeight.normal,
//                                                                   fontSize: 14,
//                                                                   color: Colors.green,
//                                                                   fontFamily: 'montserrat',
//                                                                   //fontWeight: FontWeight.w500,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             Card(
//                                                               shape: bakBegenKontrol
//                                                                   ? Border(
//                                                                       bottom: BorderSide(color: Colors.cyan, width: 5))
//                                                                   : Border(
//                                                                       bottom:
//                                                                           BorderSide(color: Colors.white, width: 5)),
//                                                               elevation: 0,
//                                                               child: Column(
//                                                                 children: [
//                                                                   Row(
//                                                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                                                     mainAxisAlignment: MainAxisAlignment.end,
//                                                                     children: [
//                                                                       Padding(
//                                                                           padding: const EdgeInsets.symmetric(
//                                                                               horizontal: 1, vertical: 1),
//                                                                           child: kullanici.email == email.toString()
//                                                                               ? IconButton(
//                                                                                   onPressed: () async {
//                                                                                     puanSa.put('postAydi',
//                                                                                         postAydi.toString());
//                                                                                     puanSa.put(
//                                                                                         'email', email.toString());
//
//                                                                                     await listOfDocumentSnap[index]
//                                                                                         .reference
//                                                                                         .delete();
//                                                                                   },
//                                                                                   icon: const Icon(
//                                                                                     Icons.delete,
//                                                                                     size: 23,
//                                                                                     color: Colors.red,
//                                                                                   ))
//                                                                               : Padding(
//                                                                                   padding: const EdgeInsets.symmetric(
//                                                                                       horizontal: 15, vertical: 2))),
//                                                                       Text(' ${begenMeKontrol.length}',
//                                                                           style: TextStyle(
//                                                                               fontSize: 13, color: Colors.white70)),
//                                                                       IconButton(
//                                                                           onPressed: () async {
//                                                                             final kullanici =
//                                                                                 FirebaseAuth.instance.currentUser!;
//                                                                             final _firestore =
//                                                                                 FirebaseFirestore.instance;
//                                                                             CollectionReference kullanicilar =
//                                                                                 _firestore.collection('Kullanicilar');
//                                                                             var icerik =
//                                                                                 kullanicilar.doc(kullanici.email);
//                                                                             var secim = await icerik.get();
//                                                                             dynamic map = secim.data();
//
//                                                                             dynamic unic = map['unic'];
//
//                                                                             if (unic <= 0) {
//                                                                             } else {
//                                                                               if (email != kullanici.email) {
//                                                                                 if (bakBegenMeKontrol) {
//                                                                                   update({
//                                                                                     'begenMe': FieldValue.arrayRemove(
//                                                                                         [kullanici.email])
//                                                                                   });
//                                                                                   update({
//                                                                                     'unic': FieldValue.increment(1)
//                                                                                   });
//
//                                                                                   await FirebaseFirestore.instance
//                                                                                       .collection("Kullanicilar")
//                                                                                       .doc(email.toString())
//                                                                                       .update({
//                                                                                     "unic": FieldValue.increment(1)
//                                                                                   });
//                                                                                 } else {
//                                                                                   unicCikart();
//                                                                                   update({
//                                                                                     'begenMe': FieldValue.arrayUnion(
//                                                                                         [kullanici.email])
//                                                                                   });
//                                                                                   update({
//                                                                                     'unic': FieldValue.increment(-1)
//                                                                                   });
//
//                                                                                   await FirebaseFirestore.instance
//                                                                                       .collection("Kullanicilar")
//                                                                                       .doc(email.toString())
//                                                                                       .update({
//                                                                                     "unic": FieldValue.increment(-1)
//                                                                                   });
//                                                                                 }
//                                                                               }
//                                                                             }
//                                                                           },
//                                                                           icon: Icon(
//                                                                             Icons.heart_broken,
//                                                                             size: 25,
//                                                                             color: bakBegenMeKontrol
//                                                                                 ? Colors.red
//                                                                                 : Colors.white70,
//                                                                           )),
//                                                                       Text('${begenKontrol.length}',
//                                                                           style: TextStyle(
//                                                                               fontSize: 13, color: Colors.white70)),
//                                                                       IconButton(
//                                                                           onPressed: () async {
//                                                                             await pozitifOyVer(listOfDocumentSnap,
//                                                                                 index, bakBegenKontrol, update, email);
//                                                                           },
//                                                                           icon: Icon(
//                                                                             Icons.thumb_up_alt_rounded,
//                                                                             size: 25,
//                                                                             color: bakBegenKontrol
//                                                                                 ? Colors.cyan
//                                                                                 : Colors.white70,
//                                                                           )),
//                                                                       Text('${yorumSayisi}',
//                                                                           style: TextStyle(
//                                                                               fontSize: 13,
//                                                                               color: Colors.white70,
//                                                                               fontWeight: FontWeight.bold)),
//                                                                       IconButton(
//                                                                           onPressed: () async {
//                                                                             puanSa.put('postAydi', postAydi.toString());
//                                                                             puanSa.put('email', email.toString());
//                                                                             print(postAydi.toString());
//                                                                             //Get.to(DoluYorumOku());
//                                                                           },
//                                                                           icon: Icon(
//                                                                             Icons.mode_comment_sharp,
//                                                                             size: 25,
//                                                                             color: yorumSayisi <= 0
//                                                                                 ? Colors.white70
//                                                                                 : Colors.cyanAccent,
//                                                                           )),
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     );
//                                                   }),
//                                             );
//                                           } else {
//                                             /// yükleniyor bölümü
//                                             return buildDefaultTextStyle();
//                                           }
//                                         }
//                                       }),
//                                 ),
//                         ],
//                       ),
//                       engelledimGetir
//                           ? Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text('Kullanıcı sizi engellemiş!'),
//                               ),
//                             )
//                           : arkadaslarIcindemi
//                               ? BaskasininAkisaMetinGir(gelenKullaniciEmail: widget.gelenKullaniciEmail.toString(),)
//                               : Center(),
//                     ],
//                   );
//                 } else {
//                   /// yükleniyor bölümü
//                   return buildDefaultTextStyle();
//                 }
//               }
//             }),
//       ),
//     );
//   }
//
//   Padding postuDuzenleIconu(email, postAydi) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
//         child: kullanici.email == email.toString()
//             ? IconButton(
//                 onPressed: () async {
//                   puanSa.put('postAydi', postAydi.toString());
//                   puanSa.put('email', email.toString());
//
//                   //Get.to(PostuDuzenle());
//                 },
//                 icon: const Icon(
//                   Icons.edit,
//                   size: 15,
//                   color: Colors.greenAccent,
//                 ))
//             : Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2)));
//   }
//
//   Future<void> engelleFonksiyonu(email) async {
//     final _firestore = FirebaseFirestore.instance;
//     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//     var icerik = kullanicilar.doc(kullanici.email);
//     var secim = await icerik.get();
//     dynamic map = secim.data();
//
//     dynamic unic = map['unic'];
//     dynamic engelledim = map['engelledim'];
//     unicCikar();
//
//     if (unic <= 0) {
//     } else {
//       if (email != kullanici.email) {
//         if (engelledim.contains(email)) {
//           await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
//             'engelledim': FieldValue.arrayRemove([email.toString()])
//           }).whenComplete(() {
//             print('kullanıcı engellendi');
//           });
//           await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
//             "engelleyenler": FieldValue.arrayRemove([kullanici.email.toString()])
//           });
//         } else {
//           await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
//             'engelledim': FieldValue.arrayUnion([email.toString()])
//           }).whenComplete(() {
//             print('kullanıcı engellendi');
//           });
//           await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
//             "engelleyenler": FieldValue.arrayUnion([kullanici.email.toString()])
//           });
//         }
//       }
//     }
//   }
//
//   Future<dynamic> unicCikart() async {
//     final kullanici = FirebaseAuth.instance.currentUser!;
//     final _firestore = FirebaseFirestore.instance;
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
//   ///
// }
