// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:unicotantic/Unic/fonksiyonlar/controllerNet.dart';
// import 'package:unicotantic/Unic/fonksiyonlar/negatifOyVer_pozitifOyVer.dart';
// import 'package:unicotantic/Unic/profil/akisindaOlanlar.dart';
// import 'package:unicotantic/Unic/profil/baskasininAkisi.dart';
//
// import '../BenDrawer.dart';
// import '../buildDefaultTextStyle.dart';
// import '../doluAkis/doluAkisAppBar.dart';
// import '../doluAkis/postuDuzenle.dart';
// import '../fonksiyonlar/altButonlar.dart';
// import '../fonksiyonlar/profilResmiGetir.dart';
// import 'ziyaretciProfilYorumBolumu.dart';
//
// ///////////////////////////////////
// class ZiyaretciProfil extends StatefulWidget {
//   String gelenKullaniciEmail;
//
//   ZiyaretciProfil({required this.gelenKullaniciEmail});
//
//   @override
//   State<ZiyaretciProfil> createState() => _ZiyaretciProfilState();
// }
//
// class _ZiyaretciProfilState extends State<ZiyaretciProfil> {
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
//     var gelenKullaniciEmailPuansa = puanSa.put('email', widget.gelenKullaniciEmail);
//
//     Query postlarSorgu = controllerNet.firestore.collection('postlar').orderBy("zaman", descending: true).limit(100);
//
//     CollectionReference kullaniciSorgu = controllerNet.firestore.collection('Kullanicilar');
//
//     var kullaniciBilgileri = kullaniciSorgu.doc(widget.gelenKullaniciEmail);
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
//                     var uid = asyncSnapshot.data.data()['uid'];
//                     var hakkinda = asyncSnapshot.data.data()['hakkinda'];
//                     var dogumTarihi = asyncSnapshot.data.data()['dogum tarihi'];
//                     var email = asyncSnapshot.data.data()['email'];
//                     var engelleyenler = asyncSnapshot.data.data()['engelleyenler'];
//                     var arkadaslar = asyncSnapshot.data.data()['arkadaslar'];
//                     var begen = asyncSnapshot.data.data()['begen'];
//                     var engelledim = asyncSnapshot.data.data()['engelledim'];
//                     dynamic engelledimGetir = engelledim.contains(kullanici.email);
//
//                     return Column(
//                       children: [
//                         kapat == false
//                             ? GestureDetector(
//                                 onTap: () {
//                                   kapat = true;
//                                   setState(() {});
//                                 },
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         engelledim.contains(kullanici.email)
//                                             ? Center()
//                                             : Expanded(
//                                                 child: GestureDetector(
//                                                   onTap: () async {
//                                                     Get.to(AkisindaOlanlar());
//                                                   },
//                                                   child: Card(
//                                                     color: Colors.deepOrange,
//                                                     child: Padding(
//                                                         padding: const EdgeInsets.all(8.0),
//                                                         child: Text(
//                                                           'Akışdaşları',
//                                                           style: TextStyle(
//                                                               fontFamily: 'Avenir',
//                                                               fontSize: 14,
//                                                               color: Colors.black87,
//                                                               fontWeight: FontWeight.bold),
//                                                           textAlign: TextAlign.center,
//                                                         )),
//                                                   ),
//                                                 ),
//                                               ),
//                                         Expanded(
//                                           child: GestureDetector(
//                                             onTap: () async {
//                                               final _firestore = FirebaseFirestore.instance;
//                                               CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//                                               var icerik = kullanicilar.doc(kullanici.email);
//                                               var secim = await icerik.get();
//                                               dynamic map = secim.data();
//
//                                               dynamic unic = map['unic'];
//                                               dynamic arkadaslar = map['arkadaslar'];
//                                               unicCikar();
//
//                                               if (unic <= 0) {
//                                               } else {
//                                                 if (email != kullanici.email) {
//                                                   if (arkadaslar.contains(email)) {
//                                                     await FirebaseFirestore.instance
//                                                         .collection("Kullanicilar")
//                                                         .doc(kullanici.email)
//                                                         .update({
//                                                       'arkadaslar': FieldValue.arrayRemove([email.toString()])
//                                                     }).whenComplete(() {
//                                                       print('kullanıcı engellendi');
//                                                     });
//                                                     await FirebaseFirestore.instance
//                                                         .collection("Kullanicilar")
//                                                         .doc(email.toString())
//                                                         .update({
//                                                       "begen": FieldValue.arrayRemove([kullanici.email.toString()])
//                                                     });
//                                                   } else {
//                                                     await FirebaseFirestore.instance
//                                                         .collection("Kullanicilar")
//                                                         .doc(kullanici.email)
//                                                         .update({
//                                                       'arkadaslar': FieldValue.arrayUnion([email.toString()])
//                                                     }).whenComplete(() {
//                                                       print('kullanıcı engellendi');
//                                                     });
//                                                     await FirebaseFirestore.instance
//                                                         .collection("Kullanicilar")
//                                                         .doc(email.toString())
//                                                         .update({
//                                                       "begen": FieldValue.arrayUnion([kullanici.email.toString()])
//                                                     });
//                                                   }
//                                                 }
//                                               }
//                                             },
//                                             child: Card(
//                                               color: begen.contains(kullanici.email) ? Colors.green : Colors.black87,
//                                               child: Padding(
//                                                 padding: const EdgeInsets.all(8.0),
//                                                 child: begen.contains(kullanici.email)
//                                                     ? Text(
//                                                         'Akışta',
//                                                         style: TextStyle(
//                                                             fontFamily: 'Avenir',
//                                                             fontSize: 14,
//                                                             color: Colors.black,
//                                                             fontWeight: FontWeight.bold),
//                                                         textAlign: TextAlign.center,
//                                                       )
//                                                     : Text(
//                                                         'Akışa Al',
//                                                         style: TextStyle(
//                                                             fontFamily: 'Avenir',
//                                                             fontSize: 14,
//                                                             color: Colors.white70,
//                                                             fontWeight: FontWeight.normal),
//                                                         textAlign: TextAlign.center,
//                                                       ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           child: GestureDetector(
//                                             onTap: () async {
//                                               await engelleFonksiyonu(email);
//                                             },
//                                             child: Card(
//                                               color:
//                                                   engelleyenler.contains(kullanici.email) ? Colors.red : Colors.black87,
//                                               child: Padding(
//                                                 padding: const EdgeInsets.all(8.0),
//                                                 child: engelleyenler.contains(kullanici.email)
//                                                     ? Text(
//                                                         'Engellendi',
//                                                         style: TextStyle(
//                                                             fontFamily: 'Avenir',
//                                                             fontSize: 14,
//                                                             color: Colors.black,
//                                                             fontWeight: FontWeight.normal),
//                                                         textAlign: TextAlign.center,
//                                                       )
//                                                     : Text(
//                                                         'Engelle',
//                                                         style: TextStyle(
//                                                             fontFamily: 'Avenir',
//                                                             fontSize: 14,
//                                                             color: Colors.white70,
//                                                             fontWeight: FontWeight.normal),
//                                                         textAlign: TextAlign.center,
//                                                       ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Row(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: [
//                                         Expanded(
//                                           flex: 1,
//                                           child: Stack(children: [
//                                             CircleAvatar(
//                                               backgroundColor: Colors.white70,
//                                               radius: 60,
//                                               child: ClipOval(
//                                                 child: Image.network(
//                                                   ziyaretciProfilResmiLinki.toString(),
//                                                   width: 110,
//                                                   height: 110,
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               ),
//                                             ),
//                                           ]),
//                                         ),
//                                         Expanded(
//                                           flex: 2,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(5.0),
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               mainAxisAlignment: MainAxisAlignment.start,
//                                               children: [
//                                                 Padding(
//                                                   padding: const EdgeInsets.all(3.0),
//                                                   child: Text(
//                                                       style: TextStyle(
//                                                           //fontFamily: 'Montserrat',
//                                                           fontSize: 12,
//                                                           color: Colors.greenAccent,
//                                                           fontWeight: FontWeight.bold,
//                                                           shadows: [
//                                                             BoxShadow(
//                                                                 color: Colors.red.withOpacity(.15),
//                                                                 offset: Offset(2.0, 2.0),
//                                                                 blurRadius: 10),
//                                                           ]),
//                                                       '@' +
//                                                           uid.toString().substring(5, 15) +
//                                                           '    ' +
//                                                           'Unic: ' +
//                                                           unic.toString(),
//                                                       textAlign: TextAlign.center),
//                                                 ),
//                                                 Padding(
//                                                   padding: const EdgeInsets.all(3.0),
//                                                   child: Text(
//                                                       style: TextStyle(
//                                                           fontFamily: 'Montserrat',
//                                                           fontSize: 12,
//                                                           color: Colors.greenAccent,
//                                                           fontWeight: FontWeight.bold,
//                                                           shadows: [
//                                                             BoxShadow(
//                                                                 color: Colors.red.withOpacity(.15),
//                                                                 offset: Offset(2.0, 2.0),
//                                                                 blurRadius: 10),
//                                                           ]),
//                                                       isim.toString() + ' ' + soyisim.toString(),
//                                                       textAlign: TextAlign.center),
//                                                 ),
//                                                 Padding(
//                                                   padding: const EdgeInsets.all(3.0),
//                                                   child: Text(
//                                                       style: TextStyle(
//                                                           fontFamily: 'Montserrat',
//                                                           fontSize: 12,
//                                                           color: Colors.greenAccent,
//                                                           fontWeight: FontWeight.bold,
//                                                           shadows: [
//                                                             BoxShadow(
//                                                                 color: Colors.red.withOpacity(.15),
//                                                                 offset: Offset(2.0, 2.0),
//                                                                 blurRadius: 10),
//                                                           ]),
//                                                       sehir.toString() + '       ' + dogumTarihi.toString(),
//                                                       textAlign: TextAlign.center),
//                                                 ),
//                                                 Padding(
//                                                   padding: const EdgeInsets.all(2.0),
//                                                   child: Text(
//                                                       style: TextStyle(
//                                                           fontFamily: 'Montserrat',
//                                                           fontSize: 13,
//                                                           color: Colors.greenAccent,
//                                                           fontWeight: FontWeight.bold,
//                                                           shadows: [
//                                                             BoxShadow(
//                                                                 color: Colors.red.withOpacity(.15),
//                                                                 offset: Offset(2.0, 2.0),
//                                                                 blurRadius: 10),
//                                                           ]),
//                                                       iletisim.toString(),
//                                                       textAlign: TextAlign.center),
//                                                 ),
//                                                 Padding(
//                                                   padding: const EdgeInsets.all(2.0),
//                                                   child: Text(
//                                                       style: TextStyle(
//                                                           fontFamily: 'Montserrat',
//                                                           fontSize: 11,
//                                                           color: Colors.orangeAccent[700],
//                                                           fontWeight: FontWeight.bold,
//                                                           shadows: [
//                                                             BoxShadow(
//                                                                 color: Colors.red.withOpacity(.15),
//                                                                 offset: Offset(2.0, 2.0),
//                                                                 blurRadius: 10),
//                                                           ]),
//                                                       hakkinda.toString(),
//                                                       textAlign: TextAlign.center),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     engelledimGetir
//                                         ? Center()
//                                         : Row(
//                                             crossAxisAlignment: CrossAxisAlignment.center,
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: [
//                                               Expanded(
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     Get.to(ZiyaretciProfilYorumBolumu(
//                                                       gelenKullaniciEmail: puanSa.get('email'),
//                                                     ));
//                                                   },
//                                                   child: Card(
//                                                     color: Colors.cyan,
//                                                     child: Padding(
//                                                       padding: const EdgeInsets.all(8.0),
//                                                       child: Text(
//                                                         'Postlar',
//                                                         style: TextStyle(
//                                                             fontFamily: 'Avenir',
//                                                             fontSize: 14,
//                                                             color: Colors.black87,
//                                                             fontWeight: FontWeight.bold),
//                                                         textAlign: TextAlign.center,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Expanded(
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     Get.to(ZiyaretciProfilYorumBolumu(
//                                                       gelenKullaniciEmail: puanSa.get('email'),
//                                                     ));
//                                                   },
//                                                   child: Card(
//                                                     color: Colors.black87,
//                                                     child: Padding(
//                                                       padding: const EdgeInsets.all(8.0),
//                                                       child: Text(
//                                                         'Yorumlar',
//                                                         style: TextStyle(
//                                                             fontFamily: 'Avenir',
//                                                             fontSize: 14,
//                                                             color: Colors.white70,
//                                                             fontWeight: FontWeight.normal),
//                                                         textAlign: TextAlign.center,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               engelledim.contains(kullanici.email)
//                                                   ? Center()
//                                                   : Expanded(
//                                                       child: GestureDetector(
//                                                         onTap: () {
//                                                           puanSa.put('email', gelenKullaniciEmailPuansa);
//                                                           Get.to(BaskasininAkisi());
//                                                         },
//                                                         child: Card(
//                                                           color: Colors.black87,
//                                                           child: Padding(
//                                                             padding: const EdgeInsets.all(8.0),
//                                                             child: Text(
//                                                               'Akış',
//                                                               style: TextStyle(
//                                                                   fontFamily: 'Avenir',
//                                                                   fontSize: 14,
//                                                                   color: Colors.white70,
//                                                                   fontWeight: FontWeight.normal),
//                                                               textAlign: TextAlign.center,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                             ],
//                                           ),
//                                     Row(
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Expanded(
//                                           child: Card(
//                                             color: Colors.black87,
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(8.0),
//                                               child: Text(
//                                                 'Yalnızca Postları Göster',
//                                                 style: TextStyle(
//                                                     fontFamily: 'Avenir',
//                                                     fontSize: 14,
//                                                     color: Colors.white70,
//                                                     fontWeight: FontWeight.normal),
//                                                 textAlign: TextAlign.center,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         kapat = false;
//                                         setState(() {});
//                                       },
//                                       child: Card(
//                                         color: Colors.transparent,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Text(
//                                               style: TextStyle(
//                                                   fontFamily: 'Montserrat',
//                                                   fontSize: 12,
//                                                   color: Colors.greenAccent,
//                                                   fontWeight: FontWeight.bold,
//                                                   shadows: [
//                                                     BoxShadow(
//                                                         color: Colors.red.withOpacity(.15),
//                                                         offset: Offset(2.0, 2.0),
//                                                         blurRadius: 10),
//                                                   ]),
//                                               isim.toString() + ' ' + soyisim.toString() + ' Postlar',
//                                               textAlign: TextAlign.center),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                         Container(height: 2, color: Colors.red),
//                         engelledimGetir
//                             ? Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text('Kullanıcı sizi engellemiş!'),
//                                 ),
//                               )
//                             : StreamBuilder<QuerySnapshot>(
//                                 stream: postlarSorgu.snapshots(),
//                                 builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                                   if (asyncSnapshot.hasError) {
//                                     return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                                   } else {
//                                     if (asyncSnapshot.hasData) {
//                                       List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;
//
//                                       return Flexible(
//                                         child: ListView.builder(
//                                             itemCount: listOfDocumentSnap.length,
//                                             itemBuilder: (context, index) {
//                                               var email = listOfDocumentSnap[index].get('email');
//                                               var id = listOfDocumentSnap[index].get('id');
//                                               var tarih = listOfDocumentSnap[index].get('tarih');
//                                               var metin = listOfDocumentSnap[index].get('metin');
//                                               var baslik = listOfDocumentSnap[index].get('baslik');
//                                               var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
//                                               var yorumMeKontrol = listOfDocumentSnap[index].get('mapYorum');
//                                               var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
//                                               var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
//                                               var postAydi = listOfDocumentSnap[index].get('postAydi');
//                                               var mapYorum = listOfDocumentSnap[index].get('mapYorum');
//
//                                               var begenKontrol = listOfDocumentSnap[index].get('begen');
//                                               var update = listOfDocumentSnap[index].reference.update;
//                                               var bakBegenKontrol = begenKontrol.contains(kullanici.email);
//                                               var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);
//
//                                               dynamic profilResmiCikar(email) {
//                                                 return profilResmiGetir(email);
//                                               }
//
//                                               dynamic profilIsmiCikar(email) {
//                                                 return profilIsmiGetir(email);
//                                               }
//
//                                               dynamic profilSoyIsimCikar(email) {
//                                                 return profilSoyisimGetir(email);
//                                               }
//
//                                               dynamic unicCikar(email) {
//                                                 return profilUnicGetir(email);
//                                               }
//
//                                               return Container(
//                                                 child: email == widget.gelenKullaniciEmail
//                                                     ? Card(
//                                                         child: Column(
//                                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                                           mainAxisAlignment: MainAxisAlignment.start,
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
//                                                                             Get.to(ZiyaretciProfil(
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
//                                                                     Text(tarih.toString() + ' ',
//                                                                         textAlign: TextAlign.center,
//                                                                         style: TextStyle(
//                                                                             //fontWeight: FontWeight.bold,
//                                                                             color: Colors.white60,
//                                                                             fontSize: 12))
//                                                                   ],
//                                                                 ),
//                                                                 Padding(
//                                                                     padding: const EdgeInsets.symmetric(
//                                                                         horizontal: 10, vertical: 1),
//                                                                     child: kullanici.email == email.toString()
//                                                                         ? IconButton(
//                                                                             onPressed: () async {
//                                                                               puanSa.put(
//                                                                                   'postAydi', postAydi.toString());
//                                                                               puanSa.put('email', email.toString());
//
//                                                                               Get.to(PostuDuzenle());
//                                                                             },
//                                                                             icon: const Icon(
//                                                                               Icons.edit,
//                                                                               size: 15,
//                                                                               color: Colors.greenAccent,
//                                                                             ))
//                                                                         : Padding(
//                                                                             padding: const EdgeInsets.symmetric(
//                                                                                 horizontal: 15, vertical: 2))),
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
//                                                             postFotolinki == 'bos'
//                                                                 ? Center()
//                                                                 : Image.network(
//                                                                     postFotolinki,
//                                                                     fit: BoxFit.fill,
//                                                                   ),
//                                                             altButonlar(
//                                                                 bakBegenKontrol,
//                                                                 listOfDocumentSnap,
//                                                                 index,
//                                                                 email,
//                                                                 postAydi,
//                                                                 begenMeKontrol,
//                                                                 yorumMeKontrol,
//                                                                 yorumSayisi,
//                                                                 bakBegenMeKontrol,
//                                                                 update,
//                                                                 begenKontrol),
//                                                           ],
//                                                         ),
//                                                       )
//                                                     : Center(),
//                                               );
//                                             }),
//                                       );
//                                     } else {
//                                       /// yükleniyor bölümü
//                                       return buildDefaultTextStyle();
//                                     }
//                                   }
//                                 }),
//                       ],
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
//   ///
//
//   ///
// }
