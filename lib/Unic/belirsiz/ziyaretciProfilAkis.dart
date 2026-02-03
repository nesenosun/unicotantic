// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pinch_zoom/pinch_zoom.dart';
// import 'package:unicotantic/Unic/fonksiyonlar/controllerNet.dart';
// import 'package:unicotantic/Unic/fonksiyonlar/negatifOyVer_pozitifOyVer.dart';
// import 'package:unicotantic/Unic/profil/akisindaOlanlar.dart';
// import 'package:unicotantic/Unic/profil/baskasininAkisaMetinGir.dart';
// import 'package:unicotantic/Unic/profil/davetEdilenler.dart';
// import 'package:unicotantic/Unic/profil/ziyaretciyeGidisYolu.dart';
//
// import '../doluAkis/doluAkisAppBar.dart';
// import '../duzenlemeler/duzenlemeleriGor.dart';
// import '../fonksiyonlar/altButonlar.dart';
// import '../fonksiyonlar/buildDefaultTextStyle.dart';
// import '../fonksiyonlar/profilResmiGetir.dart';
// import '../fonksiyonlar/videoPlayrFlick.dart';
// import 'BenDrawer.dart';
//
// ///////////////////////////////////
// class ZiyaretciProfilAkis extends StatefulWidget {
//   String gelenKullaniciEmail;
//
//   ZiyaretciProfilAkis({required this.gelenKullaniciEmail});
//
//   @override
//   State<ZiyaretciProfilAkis> createState() => _ZiyaretciProfilAkisState();
// }
//
// class _ZiyaretciProfilAkisState extends State<ZiyaretciProfilAkis> {
//   final controllerNet = Get.put(ControllerNet());
//
//   bool kapat = false;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     CollectionReference kullaniciSorgu = controllerNet.firestore.collection('Kullanicilar');
//
//     var kullaniciBilgileri = kullaniciSorgu.doc(widget.gelenKullaniciEmail);
//
//     CollectionReference uyeler = controllerNet.firestore.collection('uyeler');
//
//     var uyelerBilgileri = uyeler.doc(widget.gelenKullaniciEmail);
//
//     Query postlarSorgu = controllerNet.firestore
//         .collection('Kullanicilar')
//         .doc(widget.gelenKullaniciEmail)
//         .collection('bireyselAkis')
//         .orderBy("zaman", descending: true)
//         .limit(100);
//     bool buyut = true;
//
//     return SafeArea(
//       child: Scaffold(
//         appBar: DoluAkisAppBar(),
//         drawer: const BenDrawer(),
//         body: Container(
//           child: StreamBuilder<DocumentSnapshot>(
//               stream: kullaniciBilgileri.snapshots(),
//               builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                 if (asyncSnapshot.hasError) {
//                   return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                 } else {
//                   if (asyncSnapshot.hasData) {
//                     var ziyaretciProfilResmiLinki = asyncSnapshot.data.data()['profilresmilinki'];
//                     var isim = asyncSnapshot.data.data()['isim'];
//                     var soyisim = asyncSnapshot.data.data()['soyisim'];
//                     var sehir = asyncSnapshot.data.data()['sehir'];
//                     var iletisim = asyncSnapshot.data.data()['iletisim'];
//                     var unic = asyncSnapshot.data.data()['unic'];
//                     // var uid = asyncSnapshot.data.data()['uid'];
//                     var id = asyncSnapshot.data.data()['id'];
//                     var hakkinda = asyncSnapshot.data.data()['hakkinda'];
//                     var dogumTarihi = asyncSnapshot.data.data()['dogum tarihi'];
//                     var email = asyncSnapshot.data.data()['email'];
//                     var engelleyenler = asyncSnapshot.data.data()['engelleyenler'];
//                     var arkadaslar = asyncSnapshot.data.data()['arkadaslar'];
//                     var begen = asyncSnapshot.data.data()['begen'];
//                     var engelledim = asyncSnapshot.data.data()['engelledim'];
//                     var profilGizli = asyncSnapshot.data.data()['profilGizli'];
//                     dynamic arkadaslarIcindemi = arkadaslar.contains(kullanici.email);
//                     dynamic engelledimGetir = engelledim.contains(kullanici.email);
//                     return Center(
//                       child: Stack(
//                         children: [
//                           Column(
//                             children: [
//                               kapat == false
//                                   ? GestureDetector(
//                                       onTap: () {
//                                         kapat = true;
//                                         setState(() {});
//                                       },
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         children: [
//                                           profilFotoVeBilgiler(ziyaretciProfilResmiLinki, id, unic, isim, soyisim,
//                                               profilGizli, arkadaslar, sehir, dogumTarihi, iletisim, hakkinda),
//                                           davetlilerDavetEden(engelledimGetir, arkadaslarIcindemi, uyelerBilgileri),
//                                           Row(
//                                             crossAxisAlignment: CrossAxisAlignment.center,
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: [
//                                               engelledim.contains(kullanici.email)
//                                                   ? Center()
//                                                   : profilGizli == true
//                                                       ? arkadaslar.contains(kullanici.email)
//                                                           ? akisindaOlanlar()
//                                                           : Center()
//                                                       : akisindaOlanlar(),
//                                               akisaEkle(email, begen),
//                                               engelleButonu(email, engelleyenler),
//                                             ],
//                                           ),
//                                           yalnizcaAkisiGoster(),
//                                         ],
//                                       ),
//                                     )
//                                   : Row(
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Expanded(
//                                           child: GestureDetector(
//                                             onTap: () {
//                                               kapat = false;
//                                               setState(() {});
//                                             },
//                                             child: Card(
//                                               color: Colors.transparent,
//                                               child: Padding(
//                                                 padding: const EdgeInsets.all(8.0),
//                                                 child: Text(
//                                                     style: TextStyle(
//                                                         fontFamily: 'Montserrat',
//                                                         fontSize: 12,
//                                                         color: Colors.greenAccent,
//                                                         fontWeight: FontWeight.bold,
//                                                         shadows: [
//                                                           BoxShadow(
//                                                               color: Colors.red.withOpacity(.15),
//                                                               offset: Offset(2.0, 2.0),
//                                                               blurRadius: 10),
//                                                         ]),
//                                                     isim.toString() + ' ' + soyisim.toString() + ' Akışı',
//                                                     textAlign: TextAlign.center),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                               Container(height: 2, color: Colors.red),
//                               engelledimGetir
//                                   ? Center(
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Text('Kullanıcı sizi engellemiş!'),
//                                       ),
//                                     )
//                                   : Container(
//                                       child: profilGizli == true
//                                           ? arkadaslar.contains(kullanici.email)
//                                               ? StreamBuilder<QuerySnapshot>(
//                                                   stream: postlarSorgu.snapshots(),
//                                                   builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                                                     if (asyncSnapshot.hasError) {
//                                                       return const Center(
//                                                           child: Text('Bir hata oluştu tekrar deneyin..'));
//                                                     } else {
//                                                       if (asyncSnapshot.hasData) {
//                                                         List<DocumentSnapshot> listOfDocumentSnap =
//                                                             asyncSnapshot.data.docs;
//
//                                                         return ziyaretciAkisaGelenPostlar(listOfDocumentSnap);
//                                                       } else {
//                                                         /// yükleniyor bölümü
//                                                         return buildDefaultTextStyle();
//                                                       }
//                                                     }
//                                                   })
//                                               : Center(
//                                                   child: Padding(
//                                                     padding: const EdgeInsets.all(8.0),
//                                                     child: Text('Profil Gizli!'),
//                                                   ),
//                                                 )
//                                           : StreamBuilder<QuerySnapshot>(
//                                               stream: postlarSorgu.snapshots(),
//                                               builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                                                 if (asyncSnapshot.hasError) {
//                                                   return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                                                 } else {
//                                                   if (asyncSnapshot.hasData) {
//                                                     List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;
//
//                                                     return ziyaretciAkisaGelenPostlar(listOfDocumentSnap);
//                                                   } else {
//                                                     /// yükleniyor bölümü
//                                                     return buildDefaultTextStyle();
//                                                   }
//                                                 }
//                                               }),
//                                     ),
//                             ],
//                           ),
//                           engelledimGetir
//                               ? Center()
//                               : arkadaslarIcindemi
//                                   ? BaskasininAkisaMetinGir(
//                                       gelenKullaniciEmail: widget.gelenKullaniciEmail,
//                                     )
//                                   : Center(),
//                         ],
//                       ),
//                     );
//                   } else {
//                     /// yükleniyor bölümü
//                     return buildDefaultTextStyle();
//                   }
//                 }
//               }),
//         ),
//       ),
//     );
//   }
//
//   Row profilFotoVeBilgiler(ziyaretciProfilResmiLinki, id, unic, isim, soyisim, profilGizli, arkadaslar, sehir,
//       dogumTarihi, iletisim, hakkinda) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 1,
//           child: Stack(children: [
//             CircleAvatar(
//               backgroundColor: Colors.white70,
//               radius: 60,
//               child: ClipOval(
//                 child: Image.network(
//                   ziyaretciProfilResmiLinki.toString(),
//                   width: 110,
//                   height: 110,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ]),
//         ),
//         Expanded(
//           flex: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(5.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(3.0),
//                   child: Text(
//                       style: golgeliMetinText(),
//                       '@' + id.toString() + '    ' + 'Unic: ' + unic.toString(),
//                       textAlign: TextAlign.center),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(3.0),
//                   child: Text(
//                       style: golgeliMetinText(),
//                       isim.toString() + ' ' + soyisim.toString(),
//                       textAlign: TextAlign.center),
//                 ),
//                 profilGizli == true
//                     ? arkadaslar.contains(kullanici.email)
//                         ? Padding(
//                             padding: const EdgeInsets.all(3.0),
//                             child: Text(
//                                 style: golgeliMetinText(),
//                                 sehir.toString() + '       ' + dogumTarihi.toString(),
//                                 textAlign: TextAlign.center),
//                           )
//                         : Center()
//                     : Padding(
//                         padding: const EdgeInsets.all(3.0),
//                         child: Text(
//                             style: golgeliMetinText(),
//                             sehir.toString() + '       ' + dogumTarihi.toString(),
//                             textAlign: TextAlign.center),
//                       ),
//                 profilGizli == true
//                     ? arkadaslar.contains(kullanici.email)
//                         ? Padding(
//                             padding: const EdgeInsets.all(2.0),
//                             child: Text(style: golgeliMetinText(), iletisim.toString(), textAlign: TextAlign.center),
//                           )
//                         : Center()
//                     : Padding(
//                         padding: const EdgeInsets.all(2.0),
//                         child: Text(style: golgeliMetinText(), iletisim.toString(), textAlign: TextAlign.center),
//                       ),
//                 Padding(
//                   padding: const EdgeInsets.all(2.0),
//                   child: Text(style: golgeliMetinText(), hakkinda.toString(), textAlign: TextAlign.center),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Center davetlilerDavetEden(engelledimGetir, arkadaslarIcindemi, DocumentReference<Object?> uyelerBilgileri) {
//     return Center(
//       child: engelledimGetir
//           ? Center()
//           : arkadaslarIcindemi
//               ? Container(
//                   child: StreamBuilder<DocumentSnapshot>(
//                       stream: uyelerBilgileri.snapshots(),
//                       builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                         if (asyncSnapshot.hasError) {
//                           return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                         } else {
//                           if (asyncSnapshot.hasData) {
//                             dynamic ekleyenKisi = asyncSnapshot.data.data()['ekleyenKisi'];
//
//                             return Container(
//                               child: Card(
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () async {
//                                         Get.to(DavetEdilenler(
//                                           gelenKullaniciEmail: widget.gelenKullaniciEmail.toString(),
//                                         ));
//                                       },
//                                       child: Card(
//                                         color: Colors.white12,
//                                         child: Padding(
//                                             padding: const EdgeInsets.all(5),
//                                             child: Text(
//                                               'Davet \nettikleri',
//                                               style: TextStyle(
//                                                   fontFamily: 'Avenir',
//                                                   fontSize: 14,
//                                                   color: Colors.white70,
//                                                   fontWeight: FontWeight.bold),
//                                               textAlign: TextAlign.center,
//                                             )),
//                                       ),
//                                     ),
//                                     // Text('Davet Eden'),
//                                     Row(
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(right: 8),
//                                             child: ClipRRect(
//                                               borderRadius: BorderRadius.only(
//                                                 topLeft: Radius.circular(15.0),
//                                                 bottomRight: Radius.circular(15.0),
//                                               ),
//                                               child: Container(
//                                                 //color: Colors.blue,
//                                                 width: 40.0,
//                                                 height: 40.0,
//                                                 child: GestureDetector(
//                                                   onTap: () async {
//                                                     Get.to(ZiyaretciProfilAkiseGidis(gelenKullaniciEmail: ekleyenKisi));
//                                                   },
//                                                   child: profilResmiGetir(ekleyenKisi.toString()),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           mainAxisAlignment: MainAxisAlignment.start,
//                                           children: [
//                                             profilIsmiGetir(ekleyenKisi),
//                                             Row(
//                                               crossAxisAlignment: CrossAxisAlignment.center,
//                                               mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                               children: [
//                                                 profilIdGetir(ekleyenKisi),
//                                                 profilUnicGetir(ekleyenKisi),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           } else {
//                             /// yükleniyor bölümü
//                             return buildDefaultTextStyle();
//                           }
//                         }
//                       }),
//                 )
//               : Center(),
//     );
//   }
//
//   Row yalnizcaAkisiGoster() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Expanded(
//           child: Card(
//             color: Colors.black54,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Yalnızca Akışı Göster',
//                 style:
//                     TextStyle(fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Expanded engelleButonu(email, engelleyenler) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () async {
//           await engelleFonksiyonu(email);
//         },
//         child: Card(
//           color: Colors.white12,
//           child: Padding(
//             padding: const EdgeInsets.all(5.0),
//             child: engelleyenler.contains(kullanici.email)
//                 ? Text(
//                     'Engellendi',
//                     style:
//                         TextStyle(fontFamily: 'Avenir', fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   )
//                 : Text(
//                     'Engelle',
//                     style: TextStyle(
//                         fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Expanded akisaEkle(email, begen) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () async {
//           final _firestore = FirebaseFirestore.instance;
//           CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//           var icerik = kullanicilar.doc(kullanici.email);
//           var secim = await icerik.get();
//           dynamic map = secim.data();
//
//           dynamic unic = map['unic'];
//           dynamic arkadaslar = map['arkadaslar'];
//           unicCikar();
//
//           if (unic <= 0) {
//           } else {
//             if (email != kullanici.email) {
//               if (arkadaslar.contains(email)) {
//                 await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
//                   'arkadaslar': FieldValue.arrayRemove([email.toString()])
//                 }).whenComplete(() {
//                   print('kullanıcı engellendi');
//                 });
//                 await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
//                   "begen": FieldValue.arrayRemove([kullanici.email.toString()])
//                 });
//               } else {
//                 await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
//                   'arkadaslar': FieldValue.arrayUnion([email.toString()])
//                 }).whenComplete(() {
//                   print('kullanıcı engellendi');
//                 });
//                 await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
//                   "begen": FieldValue.arrayUnion([kullanici.email.toString()])
//                 });
//               }
//             }
//           }
//         },
//         child: Card(
//           color: Colors.white12,
//           child: Padding(
//             padding: const EdgeInsets.all(5.0),
//             child: begen.contains(kullanici.email)
//                 ? Text(
//                     'Akışta',
//                     style:
//                         TextStyle(fontFamily: 'Avenir', fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   )
//                 : Text(
//                     'Ekle',
//                     style: TextStyle(
//                         fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Expanded akisindaOlanlar() {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () async {
//           Get.to(AkisindaOlanlar(
//             gelenKullaniciEmail: widget.gelenKullaniciEmail.toString(),
//           ));
//         },
//         child: Card(
//           color: Colors.white12,
//           child: Padding(
//               padding: const EdgeInsets.all(5),
//               child: Text(
//                 'Akışındakiler',
//                 style:
//                     TextStyle(fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               )),
//         ),
//       ),
//     );
//   }
//
//   Flexible ziyaretciAkisaGelenPostlar(List<DocumentSnapshot<Object?>> listOfDocumentSnap) {
//     return Flexible(
//       child: ListView.builder(
//           itemCount: listOfDocumentSnap.length,
//           itemBuilder: (context, index) {
//             var begenKontrol = listOfDocumentSnap[index].get('begen');
//             var email = listOfDocumentSnap[index].get('email');
//             var id = listOfDocumentSnap[index].get('id');
//             var tarih = listOfDocumentSnap[index].get('tarih');
//             var baslik = listOfDocumentSnap[index].get('baslik');
//             var duzenlemeMetin = listOfDocumentSnap[index].get('metin');
//             var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
//             var mapYorumVideo = listOfDocumentSnap[index].get('mapYorum');
//             //var isimVideo = listOfDocumentSnap[index].get('isim');
//             var videoFoto = listOfDocumentSnap[index].get('soyisim');
//             var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
//
//             var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
//
//             var postAydi = listOfDocumentSnap[index].get('postAydi');
//             var update = listOfDocumentSnap[index].reference.update;
//             var bakBegenKontrol = begenKontrol.contains(kullanici.email);
//             var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);
//
//             dynamic profilResmiCikar(email) {
//               return profilResmiGetir(email);
//             }
//
//             dynamic profilIsmiCikar(email) {
//               return profilIsmiGetir(email);
//             }
//
//             dynamic unicCikar(email) {
//               return profilUnicGetir(email);
//             }
//
//             dynamic profilIdGetire(email) {
//               return profilIdGetir(email);
//             }
//
//             return GestureDetector(
//               onTap: () {
//                 puanSa.put('postAydi', postAydi.toString());
//                 puanSa.put('email', email.toString());
//                 print(postAydi.toString());
//                 //Get.to(DoluYorumOku());
//               },
//               child: Card(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Card(
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                             child: Padding(
//                               padding: const EdgeInsets.only(right: 8),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(15.0),
//                                   bottomRight: Radius.circular(15.0),
//                                 ),
//                                 child: Container(
//                                   //color: Colors.blue,
//                                   width: 50.0,
//                                   height: 50.0,
//                                   child: GestureDetector(
//                                     onTap: () async {
//                                       // puanSa.put('postAydi', postAydi.toString());
//                                       puanSa.put('email', email.toString());
//                                       print(puanSa.get('email'));
//
//                                       Get.to(ZiyaretciProfilAkiseGidis(gelenKullaniciEmail: email));
//                                     },
//                                     child: profilResmiCikar(email.toString()),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               profilIsmiCikar(email),
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                 children: [
//                                   // Text(
//                                   //   '@' + id.substring(5, 15) + ' ',
//                                   //   style: const TextStyle(
//                                   //       fontSize: 12,
//                                   //       //fontFamily: 'Montserrat',
//                                   //       fontWeight: FontWeight.bold,
//                                   //       color: Colors.white60),
//                                   // ),
//                                   Card(
//                                     child: profilIdGetire(email),
//                                   ),
//                                   Card(
//                                     child: unicCikar(email),
//                                   ),
//                                 ],
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(bottom: 2),
//                                 child: duzenlemeMetin == ''
//                                     ? Text(tarih.toString() + ' ',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             //fontWeight: FontWeight.bold,
//                                             color: Colors.white60,
//                                             fontSize: 10))
//                                     : GestureDetector(
//                                         onTap: () {
//                                           puanSa.put('postAydi', postAydi.toString());
//                                           puanSa.put('email', email.toString());
//                                           Get.to(DuzenlemeleriGor());
//                                         },
//                                         child: Text(tarih.toString() + '  düzenlendi ',
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                                 //fontWeight: FontWeight.bold,
//                                                 color: Colors.redAccent,
//                                                 fontSize: 12)),
//                                       ),
//                               ),
//                             ],
//                           ),
//                           //postuDuzenleIconu(email, postAydi),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: Text(
//                         '${baslik}',
//                         textAlign: TextAlign.start,
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.normal,
//                           fontSize: 14,
//                           color: Colors.white60,
//                           //fontFamily: 'montserrat',
//                           //fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     Card(
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(2.0),
//                             child: videoFoto == ''
//                                 ? Center()
//                                 : PinchZoom(
//                                     onZoomStart: () {},
//                                     onZoomEnd: () {},
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(15.0),
//                                         topRight: Radius.circular(15.0),
//                                         bottomRight: Radius.circular(15.0),
//                                         bottomLeft: Radius.circular(15.0),
//                                       ),
//                                       child: SizedBox(
//                                         width: 160,
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             Get.to(VideoFotoGosterSayfasi(
//                                               gelenVideolink: mapYorumVideo,
//                                               gelenFotolink: postFotolinki,
//                                             ));
//                                           },
//                                           child: Stack(
//                                             //fit: StackFit.expand,
//                                             alignment: Alignment.center,
//                                             children: [
//                                               Image.network(
//                                                 videoFoto,
//                                                 fit: BoxFit.fill,
//                                               ),
//                                               SizedBox(height: 50, child: Image.asset('assets/images/png/play.png')),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(2.0),
//                             child: postFotolinki == 'bos'
//                                 ? Center()
//                                 : PinchZoom(
//                                     onZoomStart: () {},
//                                     onZoomEnd: () {},
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(8.0),
//                                         topRight: Radius.circular(8.0),
//                                         bottomRight: Radius.circular(8.0),
//                                         bottomLeft: Radius.circular(8.0),
//                                       ),
//                                       child: SizedBox(
//                                         width: 160,
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             Get.to(VideoFotoGosterSayfasi(
//                                               gelenVideolink: mapYorumVideo,
//                                               gelenFotolink: postFotolinki,
//                                             ));
//                                           },
//                                           child: Image.network(
//                                             postFotolinki,
//                                             fit: BoxFit.fill,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: 35,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
//                               child: kullanici.email == email.toString()
//                                   ? IconButton(
//                                       onPressed: () async {
//                                         puanSa.put('postAydi', postAydi.toString());
//                                         puanSa.put('email', email.toString());
//
//                                         await listOfDocumentSnap[index].reference.delete();
//                                       },
//                                       icon: const Icon(
//                                         Icons.delete,
//                                         size: 20,
//                                         color: Colors.red,
//                                       ))
//                                   : Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2))),
//                           Row(
//                             children: [
//                               IconButton(
//                                   onPressed: () async {
//                                     final kullanici = FirebaseAuth.instance.currentUser!;
//                                     final _firestore = FirebaseFirestore.instance;
//                                     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//                                     var icerik = kullanicilar.doc(kullanici.email);
//                                     var secim = await icerik.get();
//                                     dynamic map = secim.data();
//
//                                     dynamic unic = map['unic'];
//
//                                     if (unic <= 0) {
//                                     } else {
//                                       if (email != kullanici.email) {
//                                         if (bakBegenMeKontrol) {
//                                           update({
//                                             'begenMe': FieldValue.arrayRemove([kullanici.email])
//                                           });
//                                           update({'unic': FieldValue.increment(1)});
//
//                                           await FirebaseFirestore.instance
//                                               .collection("Kullanicilar")
//                                               .doc(email.toString())
//                                               .update({"unic": FieldValue.increment(1)});
//                                         } else {
//                                           unicCikart();
//                                           update({
//                                             'begenMe': FieldValue.arrayUnion([kullanici.email])
//                                           });
//                                           update({'unic': FieldValue.increment(-1)});
//
//                                           await FirebaseFirestore.instance
//                                               .collection("Kullanicilar")
//                                               .doc(email.toString())
//                                               .update({"unic": FieldValue.increment(-1)});
//                                         }
//                                       }
//                                     }
//                                   },
//                                   icon: Icon(
//                                     Icons.heart_broken,
//                                     size: 20,
//                                     color: bakBegenMeKontrol ? Colors.red : Colors.white70,
//                                   )),
//                               Text(' ${begenMeKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               IconButton(
//                                   onPressed: () async {
//                                     await pozitifOyVer(listOfDocumentSnap, index, bakBegenKontrol, update, email);
//                                   },
//                                   icon: Icon(
//                                     Icons.thumb_up_alt_rounded,
//                                     size: 20,
//                                     color: bakBegenKontrol ? Colors.cyan : Colors.white70,
//                                   )),
//                               Text('${begenKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               IconButton(
//                                   onPressed: () async {
//                                     puanSa.put('postAydi', postAydi.toString());
//                                     puanSa.put('email', email.toString());
//                                     print(postAydi.toString());
//                                     //Get.to(DoluYorumOku());
//                                   },
//                                   icon: Icon(
//                                     Icons.mode_comment_sharp,
//                                     size: 20,
//                                     color: yorumSayisi <= 0 ? Colors.white70 : Colors.cyanAccent,
//                                   )),
//                               Text('${yorumSayisi}',
//                                   style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//     );
//   }
//
//   TextStyle golgeliMetinText() {
//     return TextStyle(fontFamily: 'Avenir', fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold, shadows: [
//       BoxShadow(color: Colors.red.withOpacity(.15), offset: Offset(2.0, 2.0), blurRadius: 10),
//     ]);
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
//           }).whenComplete(() {});
//           await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
//             "engelleyenler": FieldValue.arrayRemove([kullanici.email.toString()])
//           });
//         } else {
//           await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
//             'engelledim': FieldValue.arrayUnion([email.toString()])
//           }).whenComplete(() {});
//           await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
//             "engelleyenler": FieldValue.arrayUnion([kullanici.email.toString()])
//           });
//         }
//       }
//     }
//   }
//
//   ///
//
//   ///
// }
