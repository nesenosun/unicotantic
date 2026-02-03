import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';
import 'package:unicotantic/Unic/doluAkis/yorumaMetinGirDaktilo.dart';
import 'package:unicotantic/Unic/doluAkis/yorumaYorum.dart';
import 'package:unicotantic/Unic/fonksiyonlar/altButonlar.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:unicotantic/Unic/fonksiyonlar/controllerFnksiyon.dart';
import 'package:unicotantic/Unic/fonksiyonlar/controllerNet.dart';
import 'package:unicotantic/Unic/fonksiyonlar/doluYorumFonksiyonlari.dart';
import 'package:unicotantic/Unic/fonksiyonlar/negatifOyVer_pozitifOyVer.dart';
import 'package:unicotantic/Unic/fonksiyonlar/postSabitleri.dart';
import 'package:unicotantic/Unic/fonksiyonlar/profilResmiGetir.dart';
import 'package:unicotantic/Unic/fonksiyonlar/videoPlayrFlick.dart';
import 'package:unicotantic/profil/BenDrawer.dart';
import 'package:unicotantic/profil/yeniZiyaretciProfil.dart';

class DoluYorumOku extends StatefulWidget {
  final gelenKullaniciEmail;
  final postAydi;

  DoluYorumOku({required this.gelenKullaniciEmail, required this.postAydi});

  @override
  State<DoluYorumOku> createState() => _DoluYorumOkuState();
}

class _DoluYorumOkuState extends State<DoluYorumOku> {
  final controllerNet = Get.put(ControllerNet());
  final controllerFonk = Get.put(ControllerFonksiyon());

  TextEditingController yorumController = TextEditingController();
  bool kapat = false;

  final box = GetStorage();
  double gozetop = Get.height / 5;
  double gozeleft = Get.width / 4;
  GetStorage getbox = GetStorage();
  String galeri = '......';
  @override
  void initState() {
    kapat = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Query postaYorumSorgu = controllerNet.firestore.collection('postaYorum').orderBy("zaman", descending: false);
    CollectionReference postlar = controllerNet.firestore.collection('postlar');
    var postIcerik = postlar.doc(widget.postAydi.toString());

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: akisAppBar(),
        drawer: const BenDrawer(),
        body: Stack(
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: postIcerik.snapshots(),
                builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                  if (asyncSnapshot.hasError) {
                    return Scaffold(body: Center(child: Text('Bir hata oluştu tekrar deneyin..')));
                  } else {
                    if (asyncSnapshot.hasData) {
                      var postBegen = asyncSnapshot.data.data()?['begen'];
                      if (postBegen == null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(height: 30, child: Center(child: Text('Bu Posta ulaşılamıyor...'))),
                            Container(color: Colors.blue, height: 2),
                            yorumStream(postaYorumSorgu),
                          ],
                        );
                      }

                      var postuAtanEmail = asyncSnapshot.data.data()['email'];
                      var postTarih = asyncSnapshot.data.data()['tarih'];
                      var postBaslik = asyncSnapshot.data.data()['baslik'];
                      var postBegenMe = asyncSnapshot.data.data()['begenMe'];
                      var postFotolinki = asyncSnapshot.data.data()['postFotolinki'];
                      var postAydi = asyncSnapshot.data.data()['postAydi'];
                      var videoFoto = asyncSnapshot.data.data()['postVideoLinki'];

                      var bakBegenKontrol = postBegen.contains(controllerNet.kullanici.email);
                      var bakBegenMeKontrol = postBegenMe.contains(controllerNet.kullanici.email);

                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            kapat == true
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Card(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(15.0),
                                                    bottomRight: Radius.circular(15.0),
                                                  ),
                                                  child: Container(
                                                    //color: Colors.blue,
                                                    width: 35.0,
                                                    height: 35.0,
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        // puanSa.put('postAydi', postAydi.toString());
                                                        puanSa.put('email', postuAtanEmail.toString());
                                                        Get.to(
                                                            YeniZiyaretciProfil(gelenKullaniciEmail: postuAtanEmail));
                                                      },
                                                      child: profilResmiGetir(postuAtanEmail.toString()),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                profilIsmiGetirKucuk(postuAtanEmail),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    profilIdGetirKucuk(postuAtanEmail),
                                                    profilUnicGetirKucuk(postuAtanEmail),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 2),
                                                  child: Text(postTarih.toString() + ' ',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          //fontWeight: FontWeight.bold,
                                                          color: Colors.white60,
                                                          fontSize: 7)),
                                                ),
                                              ],
                                            ),
                                            //postuDuzenleIconu(email, postAydi),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text(
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          '${postBaslik}',
                                          textAlign: TextAlign.start,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                            color: Colors.white60,
                                            //fontFamily: 'montserrat',
                                            //fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Card(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(2.0),
                                                  child: videoFoto == ''
                                                      ? Center()
                                                      : PinchZoom(
                                                          onZoomStart: () {},
                                                          onZoomEnd: () {},
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(15.0),
                                                              topRight: Radius.circular(15.0),
                                                              bottomRight: Radius.circular(15.0),
                                                              bottomLeft: Radius.circular(15.0),
                                                            ),
                                                            child: SizedBox(
                                                              height: 90,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  Get.to(VideoFotoGosterSayfasi(
                                                                    gelenVideolink: videoFoto,
                                                                    gelenFotolink: postFotolinki,
                                                                  ));
                                                                },
                                                                child: Stack(
                                                                  //fit: StackFit.expand,
                                                                  alignment: Alignment.center,
                                                                  children: [
                                                                    Image.network(
                                                                      videoFoto,
                                                                      fit: BoxFit.fill,
                                                                    ),
                                                                    SizedBox(
                                                                        height: 50,
                                                                        child:
                                                                            Image.asset('assets/images/png/play.png')),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(2.0),
                                                  child: postFotolinki == 'bos'
                                                      ? Center()
                                                      : PinchZoom(
                                                          onZoomStart: () {},
                                                          onZoomEnd: () {},
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(8.0),
                                                              topRight: Radius.circular(8.0),
                                                              bottomRight: Radius.circular(8.0),
                                                              bottomLeft: Radius.circular(8.0),
                                                            ),
                                                            child: SizedBox(
                                                              height: 90,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  Get.to(VideoFotoGosterSayfasi(
                                                                    gelenVideolink: videoFoto,
                                                                    gelenFotolink: postFotolinki,
                                                                  ));
                                                                },
                                                                child: Image.network(
                                                                  postFotolinki,
                                                                  fit: BoxFit.fill,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          kapat = false;
                                          setState(() {});
                                        },
                                        child: Card(
                                          child: Container(
                                            height: 40,
                                            // color: Colors.black45,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2)),
                                                Text(
                                                  ' ${postBegenMe.length}',
                                                  style: TextStyle(fontSize: 13, color: Colors.white70),
                                                ),
                                                IconButton(
                                                    onPressed: () async {
                                                      var KullaniciUnicSayisi =
                                                          await KullaniciUnicSayisiGetirFonksiyonu();

                                                      if (KullaniciUnicSayisi <= 0) {
                                                      } else {
                                                        if (postuAtanEmail != controllerNet.kullanici.email) {
                                                          if (bakBegenMeKontrol) {
                                                            await postBegenMedenEmailCikarFonksiyonu(postAydi);
                                                            await poostSahibineUnicEkle(postuAtanEmail);
                                                          } else {
                                                            await postBegeneMEyeEmailEkleFonksiyonu(postAydi);
                                                            await kullanicidanUnicCikar(KullaniciUnicSayisi);
                                                            await postSahibinidenUnicCikar(postuAtanEmail);
                                                          }
                                                        }
                                                      }
                                                    },
                                                    icon: Icon(
                                                      bakBegenMeKontrol
                                                          ? Icons.heart_broken
                                                          : CupertinoIcons.heart_slash,
                                                      size: 20,
                                                      color: postBegenMe.contains(kullanici.email)
                                                          ? Colors.red
                                                          : Colors.white70,
                                                    )),
                                                Text('${postBegen.length}',
                                                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                                                IconButton(
                                                    onPressed: () async {
                                                      var KullaniciUnicSayisi =
                                                          await KullaniciUnicSayisiGetirFonksiyonu();

                                                      if (KullaniciUnicSayisi <= 0) {
                                                      } else {
                                                        if (postuAtanEmail != controllerNet.kullanici.email) {
                                                          if (bakBegenKontrol) {
                                                            await postBegendenEmailCikarFonksiyonu(postAydi);

                                                            await postSahibinidenUnicCikar(postuAtanEmail);
                                                          } else {
                                                            await postBegeneEmailEkleFonksiyonu(postAydi);
                                                            await kullanicidanUnicCikar(KullaniciUnicSayisi);
                                                            await poostSahibineUnicEkle(postuAtanEmail);
                                                          }
                                                        }
                                                      }
                                                    },
                                                    icon: Icon(
                                                      bakBegenKontrol
                                                          ? CupertinoIcons.heart_fill
                                                          : CupertinoIcons.heart,
                                                      size: 20,
                                                      color: bakBegenKontrol ? Colors.green : Colors.white70,
                                                    )),
                                                Card(
                                                  color: Colors.black38,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                                    child: Center(
                                                      child: Text('Gönderiyi Kapat',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white70,
                                                              fontSize: 11)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      kapat = true;
                                      setState(() {});
                                    },
                                    child: Card(
                                      color: Colors.black26,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Center(
                                              child: Text('Gönderiye bak',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white70,
                                                      fontSize: 13)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            Container(color: Colors.blue, height: 2),
                            yorumStream(postaYorumSorgu),
                          ],
                        ),
                      );
                    } else {
                      /// yükleniyor bölümü
                      return buildDefaultTextStyle();
                    }
                  }
                }),
            YorumaMetinGirDaktilo(gelenKullaniciEmail: widget.gelenKullaniciEmail, postAydi: widget.postAydi),
          ],
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> yorumStream(Query<Object?> postaYorumSorgu) {
    return StreamBuilder<QuerySnapshot>(
        stream: postaYorumSorgu.snapshots(),
        builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
          } else {
            if (asyncSnapshot.hasData) {
              List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;

              return Flexible(
                child: ListView.builder(
                    itemCount: listOfDocumentSnap.length,
                    itemBuilder: (context, index) {
                      var begenKontrol = listOfDocumentSnap[index].get('begen');
                      var email = listOfDocumentSnap[index].get('email');
                      var tarih = listOfDocumentSnap[index].get('tarih');
                      var baslik = listOfDocumentSnap[index].get('metin');
                      var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
                      var videoFoto = listOfDocumentSnap[index].get('postVideoLinki');
                      var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');
                      var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');
                      var postAydi = listOfDocumentSnap[index].get('postAydi');
                      var update = listOfDocumentSnap[index].reference.update;
                      var bakBegenKontrol = begenKontrol.contains(kullanici.email);
                      var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);

                      return Container(
                        child: postAydi == widget.postAydi
                            ? GestureDetector(
                                onTap: () async {
                                  var postaYorumId = listOfDocumentSnap[index].reference.id;
                                  print(postaYorumId.toString() + '        f               postaYorumId');
                                  puanSa.put('postaYorumId', postaYorumId.toString());
                                  puanSa.put('postAydi', postAydi.toString());
                                  puanSa.put('email', email.toString());

                                  print(postAydi.toString() + '        f               postAydi');
                                  print(email.toString() + '        f               email');
                                  Get.to(YorumaYorum(
                                    gelenKullaniciEmail: email.toString(),
                                    postAydi: widget.postAydi,
                                    postYorumID: postaYorumId.toString(),
                                  ));
                                },
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ustBolumKullaniciKimligi(postAydi, email, tarih, listOfDocumentSnap, index),
                                      ikinciBolumText(baslik),
                                      ucuncuBolumVideoFotograf(videoFoto, postFotolinki),
                                      SizedBox(
                                        height: 35,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () async {
                                                      final kullanici = FirebaseAuth.instance.currentUser!;
                                                      final _firestore = FirebaseFirestore.instance;
                                                      CollectionReference kullanicilar =
                                                          _firestore.collection('Kullanicilar');
                                                      var icerik = kullanicilar.doc(kullanici.email);
                                                      var secim = await icerik.get();
                                                      dynamic map = secim.data();

                                                      dynamic unic = map['unic'];

                                                      if (unic <= 0) {
                                                      } else {
                                                        if (email != kullanici.email) {
                                                          if (bakBegenMeKontrol) {
                                                            update({
                                                              'begenMe': FieldValue.arrayRemove([kullanici.email])
                                                            });
                                                            update({'unic': FieldValue.increment(1)});

                                                            await FirebaseFirestore.instance
                                                                .collection("Kullanicilar")
                                                                .doc(email.toString())
                                                                .update({"unic": FieldValue.increment(1)});
                                                          } else {
                                                            controllerFonk.unicCikart();
                                                            update({
                                                              'begenMe': FieldValue.arrayUnion([kullanici.email])
                                                            });
                                                            update({'unic': FieldValue.increment(-1)});

                                                            await FirebaseFirestore.instance
                                                                .collection("Kullanicilar")
                                                                .doc(email.toString())
                                                                .update({"unic": FieldValue.increment(-1)});
                                                          }
                                                        }
                                                      }
                                                    },
                                                    icon: Icon(
                                                      bakBegenMeKontrol
                                                          ? Icons.heart_broken
                                                          : CupertinoIcons.heart_slash,
                                                      size: 20,
                                                      color: bakBegenMeKontrol ? Colors.red : Colors.white70,
                                                    )),
                                                Text(' ${begenMeKontrol.length}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: bakBegenMeKontrol ? Colors.red : Colors.white70,
                                                    )),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () async {
                                                      await pozitifOyVer(
                                                          listOfDocumentSnap, index, bakBegenKontrol, update, email);
                                                    },
                                                    icon: Icon(
                                                      bakBegenKontrol
                                                          ? CupertinoIcons.heart_fill
                                                          : CupertinoIcons.heart,
                                                      size: 20,
                                                      color: bakBegenKontrol ? Colors.green : Colors.white70,
                                                    )),
                                                Text('${begenKontrol.length}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: bakBegenKontrol ? Colors.green : Colors.white70,
                                                    )),
                                              ],
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                    onPressed: () async {
                                                      var postaYorumId = listOfDocumentSnap[index].reference.id;
                                                      print(postaYorumId.toString() + ' print postaYorumId');
                                                      puanSa.put('postaYorumId', postaYorumId.toString());
                                                      puanSa.put('postAydi', postAydi.toString());
                                                      puanSa.put('email', email.toString());

                                                      print(postAydi.toString() + 'print postAydi');
                                                      print(email.toString() + 'print email');
                                                      Get.to(YorumaYorum(
                                                        gelenKullaniciEmail: email.toString(),
                                                        postAydi: widget.postAydi,
                                                        postYorumID: postaYorumId.toString(),
                                                      ));
                                                    },
                                                    icon: Icon(
                                                      CupertinoIcons.conversation_bubble,
                                                      size: 20,
                                                      color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
                                                    )),
                                                Text('${yorumSayisi}' + '  ',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
                                                        fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Center(),
                      );
                    }),
              );
            } else {
              /// yükleniyor bölümü
              return buildDefaultTextStyle();
            }
          }
        });
  }

  ///
}
