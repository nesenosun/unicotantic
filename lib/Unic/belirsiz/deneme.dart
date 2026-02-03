// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:grock/grock.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:unicotantic/Unic/profil/profilYorumOku.dart';
//
// import '../doluAkis/doluAkisAppBar.dart';
// import '../doluAkis/doluYorumOku.dart';
// import '../fonksiyonlar/buildDefaultTextStyle.dart';
// import 'profilYorumBolumu.dart';
// import 'profil_duzenle.dart';
// import 'profil_fotograf_degistir.dart';
//
// ///////////////////////////////////
// class DenemeSilver extends StatefulWidget {
//   const DenemeSilver({super.key});
//
//   @override
//   State<DenemeSilver> createState() => _DenemeSilverState();
// }
//
// class _DenemeSilverState extends State<DenemeSilver> {
//   final kullanici = FirebaseAuth.instance.currentUser!;
//   final _firestore = FirebaseFirestore.instance;
//   late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
//   ProfilFotografiDegistir getir = const ProfilFotografiDegistir();
//   String? indirmeBaglantisi;
//
//   final getbox = GetStorage();
//   GetStorage box = GetStorage();
//   dynamic puanSa = Hive.box('unicotantic');
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
//   galeridenYukle() async {
//     // ignore: deprecated_member_use
//     var alinanDosya = await ImagePicker().pickImage(source: ImageSource.gallery);
//     setState(() {
//       yuklenecekDosya = File(alinanDosya!.path);
//     });
//
//     Reference referansYol = FirebaseStorage.instance
//         .ref()
//         .child('profilresimleri')
//         .child(kullanici.email.toString())
//         .child('${DateTime.now().minute}profilResmi.png');
//     UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
//     String url = await (await yuklemeGorevi).ref.getDownloadURL();
//     setState(() {
//       indirmeBaglantisi = url;
//       getbox.write('profilresmilinki', indirmeBaglantisi.toString());
//
//       FirebaseFirestore.instance.collection('Kullanicilar').doc(kullanici.email.toString()).update({
//         'profilresmilinki': indirmeBaglantisi.toString(),
//       });
//
//       FirebaseFirestore.instance.collection('Yazilar').doc(kullanici.email.toString()).update({
//         'profilresmilinki': indirmeBaglantisi.toString(),
//       });
//     });
//   }
//
//   firebaseIndirHiveYukleFonksiyonu() {
//     //Query profilBilgilerim = _firestore.collection('Kullanicilar').where('email', isEqualTo: kullanici.email);
//     Query getkullaniciEmail = _firestore.collection('Kullanicilar').orderBy("email");
//
//     //CollectionReference getkullaniciEmaili = _firestore.collection('Kullanicilar');
//     //var profilBilgilerimDoc = getkullaniciEmaili.doc(kullanici.email);
//
//     if (getkullaniciEmail.isNotEmpty) {
//       puanSa.put('getkullaniciEmail', getkullaniciEmail.toString());
//     } else {
//       puanSa.put('getkullaniciEmail', 'getkullaniciEmail');
//     }
//   }
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
//     Query akisSorgu = _firestore.collection('postlar').orderBy("zaman", descending: true).limit(100);
//
//     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//     var icerik = kullanicilar.doc(kullanici.email);
//     final double coverHeight = 190;
//
//     return SafeArea(
//       child: Scaffold(
//         appBar: DoluAkisAppBar(),
//         //drawer: const BenDrawer(),
//         body: CustomScrollView(
//           slivers: [
//             SliverAppBar(
//               automaticallyImplyLeading: false,
//
//               floating: true,
//               //centerTitle: true,
//               //title: Text('naber'),
//               expandedHeight: coverHeight,
//               flexibleSpace: FlexibleSpaceBar(
//                 background: StreamBuilder<DocumentSnapshot>(
//                     stream: icerik.snapshots(),
//                     builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                       if (asyncSnapshot.hasError) {
//                         return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                       } else {
//                         if (asyncSnapshot.hasData) {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     flex: 2,
//                                     child: Stack(children: [
//                                       CircleAvatar(
//                                         backgroundColor: Colors.white70,
//                                         radius: 60,
//                                         child: ClipOval(
//                                           child: Image.network(
//                                             '${asyncSnapshot.data.data()['profilresmilinki']}',
//                                             width: 110,
//                                             height: 110,
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         left: 80,
//                                         top: 80,
//                                         child: GestureDetector(
//                                           onTap: () async {
//                                             //SystemNavigator.pop();
//                                             Get.to(const ProfilDuzenle());
//
//                                             setState(() {});
//                                           },
//                                           child: SizedBox(
//                                             child: Image.asset('assets/images/png/arti.png'),
//                                             height: 35,
//                                           ),
//                                         ),
//                                       ),
//                                     ]),
//                                   ),
//                                   Expanded(
//                                     flex: 3,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(5.0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.all(3.0),
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
//                                                 '${asyncSnapshot.data.data()['isim']} ' +
//                                                     '${asyncSnapshot.data.data()['soyisim']}',
//                                                 textAlign: TextAlign.center),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(3.0),
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
//                                                 '${asyncSnapshot.data.data()['sehir']} ' +
//                                                     ' ${asyncSnapshot.data.data()['dogum tarihi']}',
//                                                 textAlign: TextAlign.center),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(2.0),
//                                             child: Text(
//                                                 style: TextStyle(
//                                                     fontFamily: 'Montserrat',
//                                                     fontSize: 13,
//                                                     color: Colors.greenAccent,
//                                                     fontWeight: FontWeight.bold,
//                                                     shadows: [
//                                                       BoxShadow(
//                                                           color: Colors.red.withOpacity(.15),
//                                                           offset: Offset(2.0, 2.0),
//                                                           blurRadius: 10),
//                                                     ]),
//                                                 '${asyncSnapshot.data.data()['iletisim']}',
//                                                 textAlign: TextAlign.center),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(2.0),
//                                             child: Text(
//                                                 style: TextStyle(
//                                                     fontFamily: 'Montserrat',
//                                                     fontSize: 11,
//                                                     color: Colors.orangeAccent[700],
//                                                     fontWeight: FontWeight.bold,
//                                                     shadows: [
//                                                       BoxShadow(
//                                                           color: Colors.red.withOpacity(.15),
//                                                           offset: Offset(2.0, 2.0),
//                                                           blurRadius: 10),
//                                                     ]),
//                                                 '${asyncSnapshot.data.data()['hakkinda']}',
//                                                 textAlign: TextAlign.center),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   // Expanded(
//                                   //   child: GestureDetector(
//                                   //     onTap: () {
//                                   //       Get.to(ProfilDuzenle());
//                                   //     },
//                                   //     child: Card(
//                                   //       child: Padding(
//                                   //         padding: EdgeInsets.all(8.0),
//                                   //         child: Text(
//                                   //           'Düzenle',
//                                   //           style: TextStyle(
//                                   //               fontFamily: 'Avenir',
//                                   //               fontSize: 14,
//                                   //               color: Colors.white70,
//                                   //               fontWeight: FontWeight.normal),
//                                   //           textAlign: TextAlign.center,
//                                   //         ),
//                                   //       ),
//                                   //     ),
//                                   //   ),
//                                   // ),
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () {},
//                                       child: Card(
//                                         color: Colors.transparent,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Text(
//                                             'Postlar',
//                                             style: TextStyle(
//                                                 fontFamily: 'Avenir',
//                                                 fontSize: 14,
//                                                 color: Colors.white70,
//                                                 fontWeight: FontWeight.normal),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         Get.to(ProfilYorumBolumu());
//
//                                         setState(() {});
//                                       },
//                                       child: Card(
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Text(
//                                             'Yorumlar',
//                                             style: TextStyle(
//                                                 fontFamily: 'Avenir',
//                                                 fontSize: 14,
//                                                 color: Colors.white70,
//                                                 fontWeight: FontWeight.normal),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           );
//                         } else {
//                           /// yükleniyor bölümü
//                           return buildDefaultTextStyle();
//                         }
//                       }
//                     }),
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: Container(
//                 height: 450,
//                 child: StreamBuilder<QuerySnapshot>(
//                     stream: akisSorgu.snapshots(),
//                     builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                       if (asyncSnapshot.hasError) {
//                         return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                       } else {
//                         if (asyncSnapshot.hasData) {
//                           List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;
//
//                           return Flexible(
//                             child: ListView.builder(
//                                 itemCount: listOfDocumentSnap.length,
//                                 itemBuilder: (context, index) {
//                                   var begenKontrol = listOfDocumentSnap[index].get('begen');
//                                   var isim = listOfDocumentSnap[index].get('isim');
//                                   var soyisim = listOfDocumentSnap[index].get('soyisim');
//                                   var email = listOfDocumentSnap[index].get('email');
//                                   var id = listOfDocumentSnap[index].get('id');
//                                   var tarih = listOfDocumentSnap[index].get('tarih');
//                                   var baslik = listOfDocumentSnap[index].get('baslik');
//                                   var sehir = listOfDocumentSnap[index].get('sehir');
//                                   var iletisim = listOfDocumentSnap[index].get('iletisim');
//                                   var hakkinda = listOfDocumentSnap[index].get('hakkinda');
//                                   var dogumtarihi = listOfDocumentSnap[index].get('dogum tarihi');
//                                   var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
//                                   var yorumMeKontrol = listOfDocumentSnap[index].get('mapYorum');
//                                   var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
//                                   var bildirim = listOfDocumentSnap[index].get('bildirim');
//                                   var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
//                                   var profilresmilinki = listOfDocumentSnap[index].get('profilresmilinki');
//                                   var postAydi = listOfDocumentSnap[index].get('postAydi');
//                                   var update = listOfDocumentSnap[index].reference.update;
//                                   var bakBegenKontrol = begenKontrol.contains(kullanici.email);
//                                   var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);
//
//                                   dynamic profilResmiCikar(email) {
//                                     final kullanici = FirebaseAuth.instance.currentUser!;
//                                     final _firestore = FirebaseFirestore.instance;
//                                     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//                                     var icerik = kullanicilar.doc(email.toString());
//
//                                     return StreamBuilder<DocumentSnapshot>(
//                                         stream: icerik.snapshots(),
//                                         builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                                           if (asyncSnapshot.hasError) {
//                                             return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                                           } else {
//                                             if (asyncSnapshot.hasData) {
//                                               return Image.network(
//                                                 '${asyncSnapshot.data.data()['profilresmilinki']}',
//                                                 fit: BoxFit.contain,
//                                               );
//                                             } else {
//                                               /// yükleniyor bölümü
//                                               return buildDefaultTextStyle();
//                                             }
//                                           }
//                                         });
//                                   }
//
//                                   dynamic profilIsmiCikar(email) {
//                                     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//                                     var icerik = kullanicilar.doc(email.toString());
//
//                                     return StreamBuilder<DocumentSnapshot>(
//                                         stream: icerik.snapshots(),
//                                         builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                                           if (asyncSnapshot.hasError) {
//                                             return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                                           } else {
//                                             if (asyncSnapshot.hasData) {
//                                               return Text('${asyncSnapshot.data.data()['isim']}',
//                                                   textAlign: TextAlign.start,
//                                                   style: TextStyle(
//                                                       fontWeight: FontWeight.bold,
//                                                       color: Colors.blueAccent,
//                                                       fontSize: 13));
//                                             } else {
//                                               /// yükleniyor bölümü
//                                               return buildDefaultTextStyle();
//                                             }
//                                           }
//                                         });
//                                   }
//
//                                   dynamic profilSoyIsimCikar(email) {
//                                     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//                                     var icerik = kullanicilar.doc(email.toString());
//
//                                     return StreamBuilder<DocumentSnapshot>(
//                                         stream: icerik.snapshots(),
//                                         builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//                                           if (asyncSnapshot.hasError) {
//                                             return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
//                                           } else {
//                                             if (asyncSnapshot.hasData) {
//                                               return Text('${asyncSnapshot.data.data()['soyisim']}',
//                                                   textAlign: TextAlign.start,
//                                                   style: TextStyle(
//                                                       fontWeight: FontWeight.bold,
//                                                       color: Colors.blueAccent,
//                                                       fontSize: 13));
//                                             } else {
//                                               /// yükleniyor bölümü
//                                               return buildDefaultTextStyle();
//                                             }
//                                           }
//                                         });
//                                   }
//
//                                   return Container(
//                                     child: listOfDocumentSnap[index].get('email') == kullanici.email
//                                         ? Card(
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               children: [
//                                                 Card(
//                                                   child: Row(
//                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                     mainAxisAlignment: MainAxisAlignment.start,
//                                                     children: [
//                                                       Padding(
//                                                         padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                                                         child: Padding(
//                                                           padding: const EdgeInsets.only(right: 8),
//                                                           child: ClipRRect(
//                                                             borderRadius: BorderRadius.only(
//                                                               topLeft: Radius.circular(15.0),
//                                                               bottomRight: Radius.circular(15.0),
//                                                             ),
//                                                             child: Container(
//                                                               //color: Colors.blue,
//                                                               width: 42.0,
//                                                               height: 42.0,
//                                                               child: GestureDetector(
//                                                                 onTap: () async {
//                                                                   //Get.to(ZiyaretciProfil(gelenKullaniciEmail: email));
//                                                                 },
//                                                                 child: profilResmiCikar(email.toString()),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Column(
//                                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                                         mainAxisAlignment: MainAxisAlignment.start,
//                                                         children: [
//                                                           Row(
//                                                             children: [
//                                                               profilIsmiCikar(email),
//                                                               SizedBox(width: 3),
//                                                               profilSoyIsimCikar(email),
//                                                             ],
//                                                           ),
//                                                           Text(
//                                                             '@' + id.substring(5, 15) + ' ',
//                                                             style: const TextStyle(
//                                                                 fontSize: 12,
//                                                                 //fontFamily: 'Montserrat',
//                                                                 fontWeight: FontWeight.bold,
//                                                                 color: Colors.white70),
//                                                           ),
//                                                           Text(tarih.toString() + ' ',
//                                                               textAlign: TextAlign.center,
//                                                               style: TextStyle(
//                                                                   //fontWeight: FontWeight.bold,
//                                                                   color: Colors.white60,
//                                                                   fontSize: 12)),
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 //isimTarihEnUstBolum(isim, soyisim, tarih, id),
//
//                                                 Padding(
//                                                   padding: const EdgeInsets.all(5.0),
//                                                   child: Text(
//                                                     '${baslik}',
//                                                     textAlign: TextAlign.start,
//                                                     style: const TextStyle(
//                                                       fontWeight: FontWeight.normal,
//                                                       fontSize: 14,
//                                                       color: Colors.green,
//                                                       fontFamily: 'montserrat',
//                                                       //fontWeight: FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 // profilFotoBaslikAcilanProfilBilgileri(context, isim, soyisim, profilresmilinki, id,
//                                                 //     sehir, iletisim, hakkinda, dogumtarihi, baslik),
//                                                 postFotolinki == 'bos'
//                                                     ? Center()
//                                                     : Image.network(
//                                                         postFotolinki,
//                                                         fit: BoxFit.fill,
//                                                       ),
//                                                 altButonlar(
//                                                     bakBegenKontrol,
//                                                     listOfDocumentSnap,
//                                                     index,
//                                                     email,
//                                                     postAydi,
//                                                     begenMeKontrol,
//                                                     yorumMeKontrol,
//                                                     yorumSayisi,
//                                                     bakBegenMeKontrol,
//                                                     update,
//                                                     begenKontrol),
//                                               ],
//                                             ),
//                                           )
//                                         : Center(),
//                                   );
//                                 }),
//                           );
//                         } else {
//                           /// yükleniyor bölümü
//                           return buildDefaultTextStyle();
//                         }
//                       }
//                     }),
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: Container(
//                 height: 200,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Card buildCard(BuildContext context, yazi) {
//     return Card(
//       elevation: 5,
//       margin: const EdgeInsets.symmetric(horizontal: 5),
//       color: Colors.black54,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               yazi,
//               style: const TextStyle(
//                   fontFamily: 'Montserrat', fontSize: 15, color: Colors.greenAccent, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Card buildCard2(BuildContext context, yazi) {
//     return Card(
//       elevation: 5,
//       margin: const EdgeInsets.symmetric(horizontal: 5),
//       color: Colors.black26,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               yazi,
//               style: TextStyle(
//                   fontFamily: 'Montserrat',
//                   fontSize: 15,
//                   color: Colors.greenAccent,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     BoxShadow(color: Colors.red.withOpacity(.15), offset: Offset(2.0, 2.0), blurRadius: 10),
//                   ]),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   AlertDialog buildAlertDialog(List<DocumentSnapshot<Object?>> listOfDocumentSnap, int index, BuildContext context) {
//     return AlertDialog(
//       title: SizedBox(
//         height: 250,
//         width: 250,
//         child: Image.network(
//           listOfDocumentSnap[index].get('profilresmilinki').toString(),
//           fit: BoxFit.cover,
//         ),
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Card(
//                 color: Colors.black12,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     listOfDocumentSnap[index].get('isim').toString(),
//                     style: const TextStyle(fontSize: 18, fontFamily: 'Montserrat'),
//                   ),
//                 )),
//             Card(
//                 color: Colors.black12,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     listOfDocumentSnap[index].get('iletisim').toString(),
//                     style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
//                   ),
//                 )),
//             Card(
//                 color: Colors.black12,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     listOfDocumentSnap[index].get('sehir').toString(),
//                     style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
//                   ),
//                 )),
//             Card(
//                 color: Colors.black12,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     listOfDocumentSnap[index].get('dogum tarihi').toString(),
//                     style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
//                   ),
//                 )),
//             Card(
//                 color: Colors.black12,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     listOfDocumentSnap[index].get('hakkinda').toString(),
//                     style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
//                   ),
//                 )),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () => Navigator.pop(context, 'OK'),
//           child: const Text('OK'),
//         ),
//       ],
//     );
//   }
//
//   Card imzaYerineEmail(contains, List<DocumentSnapshot<Object?>> listOfDocumentSnap, int index) {
//     return Card(
//       shadowColor: contains ? Colors.cyanAccent : Colors.green,
//       elevation: 5,
//       child: Column(
//         children: [
//           Text('${listOfDocumentSnap[index].get('email')}',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: contains ? Colors.cyanAccent : Colors.green,
//               )),
//         ],
//       ),
//     );
//   }
//
//   Row profilFotoveMetin(BuildContext context, List<DocumentSnapshot<Object?>> listOfDocumentSnap, int index, metin) {
//     return Row(
//       children: [
//         Expanded(
//           child: Card(
//             elevation: 0,
//             child: GestureDetector(
//               onTap: () async {
//                 showDialog<String>(
//                   context: context,
//                   builder: (BuildContext context) => buildAlertDialog(listOfDocumentSnap, index, context),
//                 );
//
//                 await listOfDocumentSnap[index].get('email');
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 8, top: 3),
//                 child: Image.network(
//                   listOfDocumentSnap[index].get('profilresmilinki'),
//                   fit: BoxFit.fill,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 3,
//           child: Card(
//             elevation: 0,
//             child:
//                 Text('${metin}', style: const TextStyle(fontSize: 17, color: Colors.white70, fontFamily: 'montserrat')),
//           ),
//         ),
//       ],
//     );
//   }
//
//   SizedBox ustButonlar(contains, List<DocumentSnapshot<Object?>> listOfDocumentSnap, int index, begenMeKontrol,
//       yorumMeKontrol, yorumSayisi, containsBegenme, Future<void> update(Map<Object, Object?> data), begenKontrol) {
//     CollectionReference yorumSorgu = _firestore.collection('yorumlar');
//     print(yorumSorgu.toString() + '  yorumSorgu 01');
//
//     var yicerik = yorumSorgu.doc();
//     print(yicerik.toString() + '  yicerik 02');
//
//     return SizedBox(
//       height: 45,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 1, top: 2, left: 10, right: 10),
//         child: Card(
//           shadowColor: contains ? Colors.cyanAccent : Colors.white70,
//           elevation: 3,
//           child: Row(
//             children: [
//               Expanded(
//                 child: kullanici.email == listOfDocumentSnap[index].get('email')
//                     ? IconButton(
//                         onPressed: () async {
//                           await listOfDocumentSnap[index].reference.delete();
//                         },
//                         icon: const Icon(
//                           Icons.delete,
//                           size: 20,
//                           color: Colors.red,
//                         ))
//                     : IconButton(
//                         onPressed: () async {
//                           await listOfDocumentSnap[index].get('email');
//                         },
//                         icon: const Center()),
//               ),
//               Expanded(
//                 child: Row(
//                   children: [
//                     Text('${begenMeKontrol.length}', style: TextStyle(fontSize: 15, color: Colors.white70)),
//                     IconButton(
//                         onPressed: () async {
//                           CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//                           var icerik = kullanicilar.doc(kullanici.email);
//                           var secim = await icerik.get();
//                           dynamic map = secim.data();
//
//                           dynamic unic = map['unic'];
//
//                           if (unic <= 0) {
//                           } else {
//                             if (listOfDocumentSnap[index].get('email') != kullanici.email) {
//                               if (containsBegenme) {
//                                 update({
//                                   'begenMe': FieldValue.arrayRemove([kullanici.email])
//                                 });
//                                 update({'unic': FieldValue.increment(1)});
//
//                                 await FirebaseFirestore.instance
//                                     .collection("Kullanicilar")
//                                     .doc(listOfDocumentSnap[index].get('email'))
//                                     .update({"unic": FieldValue.increment(1)});
//                               } else {
//                                 unicCikar();
//                                 update({
//                                   'begenMe': FieldValue.arrayUnion([kullanici.email])
//                                 });
//                                 update({'unic': FieldValue.increment(-1)});
//
//                                 await FirebaseFirestore.instance
//                                     .collection("Kullanicilar")
//                                     .doc(listOfDocumentSnap[index].get('email'))
//                                     .update({"unic": FieldValue.increment(-1)});
//                               }
//                             }
//                           }
//                         },
//                         icon: Icon(
//                           Icons.arrow_circle_down,
//                           size: 20,
//                           color: containsBegenme ? Colors.redAccent : Colors.white70,
//                         )),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Row(
//                   children: [
//                     Text('${begenKontrol.length}', style: TextStyle(fontSize: 15, color: Colors.white70)),
//                     IconButton(
//                         onPressed: () async {
//                           CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//                           var icerik = kullanicilar.doc(kullanici.email);
//                           var secim = await icerik.get();
//                           dynamic map = secim.data();
//
//                           dynamic unic = map['unic'];
//
//                           if (unic <= 0) {
//                           } else {
//                             if (listOfDocumentSnap[index].get('email') != kullanici.email) {
//                               if (contains) {
//                                 update({
//                                   'begen': FieldValue.arrayRemove([kullanici.email])
//                                 });
//                                 update({'unic': FieldValue.increment(-1)});
//
//                                 await FirebaseFirestore.instance
//                                     .collection("Kullanicilar")
//                                     .doc(listOfDocumentSnap[index].get('email'))
//                                     .update({"unic": FieldValue.increment(-1)});
//                               } else {
//                                 unicCikar();
//
//                                 update({
//                                   'begen': FieldValue.arrayUnion([kullanici.email]),
//                                 });
//                                 update({'unic': FieldValue.increment(1)});
//
//                                 await FirebaseFirestore.instance
//                                     .collection("Kullanicilar")
//                                     .doc(listOfDocumentSnap[index].get('email'))
//                                     .update({"unic": FieldValue.increment(1)});
//                               }
//                             }
//                           }
//                         },
//                         icon: Icon(
//                           Icons.favorite,
//                           size: 20,
//                           color: contains ? Colors.cyanAccent : Colors.white70,
//                         )),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Row(
//                   children: [
//                     Text(yorumSayisi.toString(), style: TextStyle(fontSize: 15, color: Colors.white70)),
//                     IconButton(
//                         onPressed: () async {
//                           puanSa.put('postAydi', listOfDocumentSnap[index].get('postAydi').toString());
//                           print(listOfDocumentSnap[index].get('postAydi').toString());
//                           Get.to(ProfilYorumOku());
//                         },
//                         icon: Icon(
//                           Icons.message_outlined,
//                           size: 20,
//                           color: yorumSayisi <= 1 ? Colors.white70 : Colors.blue,
//                         )),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> pozitifOyVer(List<DocumentSnapshot<Object?>> listOfDocumentSnap, int index, contains,
//       Future<void> update(Map<Object, Object?> data), email) async {
//     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//     var icerik = kullanicilar.doc(kullanici.email);
//     var secim = await icerik.get();
//     dynamic map = secim.data();
//
//     dynamic unic = map['unic'];
//
//     if (unic <= 0) {
//     } else {
//       if (listOfDocumentSnap[index].get('email') != kullanici.email) {
//         if (contains) {
//           update({
//             'begen': FieldValue.arrayRemove([kullanici.email])
//           });
//           update({'unic': FieldValue.increment(-1)});
//
//           await FirebaseFirestore.instance
//               .collection("Kullanicilar")
//               .doc(email.toString())
//               .update({"unic": FieldValue.increment(-1)});
//         } else {
//           unicCikar();
//
//           update({
//             'begen': FieldValue.arrayUnion([kullanici.email]),
//           });
//           update({'unic': FieldValue.increment(1)});
//
//           await FirebaseFirestore.instance
//               .collection("Kullanicilar")
//               .doc(email.toString())
//               .update({"unic": FieldValue.increment(1)});
//         }
//       }
//     }
//   }
//
//   ///
//
//   ///
//
//   Future<void> negatifOyVer(email, containsBegenme, Future<void> update(Map<Object, Object?> data)) async {
//     CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
//     var icerik = kullanicilar.doc(kullanici.email);
//     var secim = await icerik.get();
//     dynamic map = secim.data();
//
//     dynamic unic = map['unic'];
//
//     if (unic <= 0) {
//     } else {
//       if (email != kullanici.email) {
//         if (containsBegenme) {
//           update({
//             'begenMe': FieldValue.arrayRemove([kullanici.email])
//           });
//           update({'unic': FieldValue.increment(1)});
//
//           await FirebaseFirestore.instance
//               .collection("Kullanicilar")
//               .doc(email.toString())
//               .update({"unic": FieldValue.increment(1)});
//         } else {
//           unicCikar();
//           update({
//             'begenMe': FieldValue.arrayUnion([kullanici.email])
//           });
//           update({'unic': FieldValue.increment(-1)});
//
//           await FirebaseFirestore.instance
//               .collection("Kullanicilar")
//               .doc(email.toString())
//               .update({"unic": FieldValue.increment(-1)});
//         }
//       }
//     }
//   }
//
//   SizedBox altButonlar(
//       contains,
//       List<DocumentSnapshot<Object?>> listOfDocumentSnap,
//       int index,
//       email,
//       postAydi,
//       begenMeKontrol,
//       yorumMeKontrol,
//       yorumSayisi,
//       containsBegenme,
//       Future<void> update(Map<Object, Object?> data),
//       begenKontrol) {
//     return SizedBox(
//       // height: 150,
//       child: Card(
//         //color: Colors.blueGrey[700],
//         //shadowColor: contains ? Colors.greenAccent : Colors.yellow,
//         shape: contains
//             ? Border(bottom: BorderSide(color: Colors.cyan, width: 5))
//             : Border(bottom: BorderSide(color: Colors.white, width: 5)),
//         elevation: 0,
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
//                     child: kullanici.email == email.toString()
//                         ? IconButton(
//                             onPressed: () async {
//                               await listOfDocumentSnap[index].reference.delete();
//                             },
//                             icon: const Icon(
//                               Icons.delete,
//                               size: 23,
//                               color: Colors.red,
//                             ))
//                         : Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2))),
//                 Text(' ${begenMeKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
//                 IconButton(
//                     onPressed: () async {
//                       await negatifOyVer(email, containsBegenme, update);
//                     },
//                     icon: Icon(
//                       Icons.heart_broken,
//                       size: 25,
//                       color: containsBegenme ? Colors.red : Colors.white70,
//                     )),
//                 Text('${begenKontrol.length}', style: TextStyle(fontSize: 13, color: Colors.white70)),
//                 IconButton(
//                     onPressed: () async {
//                       await pozitifOyVer(listOfDocumentSnap, index, contains, update, email);
//                     },
//                     icon: Icon(
//                       Icons.thumb_up_alt_rounded,
//                       size: 25,
//                       color: contains ? Colors.cyan : Colors.white70,
//                     )),
//                 Text('${yorumSayisi}',
//                     style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold)),
//                 IconButton(
//                     onPressed: () async {
//                       puanSa.put('postAydi', postAydi.toString());
//                       puanSa.put('email', email.toString());
//                       print(postAydi.toString());
//                       Get.to(DoluYorumOku());
//                     },
//                     icon: Icon(
//                       Icons.mode_comment_sharp,
//                       size: 25,
//                       color: yorumSayisi <= 0 ? Colors.white70 : Colors.cyanAccent,
//                     )),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
