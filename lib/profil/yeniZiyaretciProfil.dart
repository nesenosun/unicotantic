import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';
import 'package:unicotantic/Unic/fonksiyonlar/altButonlar.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:unicotantic/Unic/fonksiyonlar/controllerNet.dart';
import 'package:unicotantic/Unic/fonksiyonlar/negatifOyVer_pozitifOyVer.dart';
import 'package:unicotantic/Unic/fonksiyonlar/profilResmiGetir.dart';
import 'package:unicotantic/Unic/fonksiyonlar/videoPlayrFlick.dart';
import 'package:unicotantic/profil/BenDrawer.dart';
import 'package:unicotantic/profil/akisindaOlanlar.dart';
import 'package:unicotantic/profil/baskaAkisaMetinGirYeni.dart';
import 'package:unicotantic/profil/davetEdilenler.dart';
import 'package:unicotantic/profil/postaYorumOku.dart';
import 'package:unicotantic/profil/ziyaretciyeGidisYolu.dart';

///////////////////////////////////
class YeniZiyaretciProfil extends StatefulWidget {
  String gelenKullaniciEmail;

  YeniZiyaretciProfil({required this.gelenKullaniciEmail});

  @override
  State<YeniZiyaretciProfil> createState() => _YeniZiyaretciProfilState();
}

class _YeniZiyaretciProfilState extends State<YeniZiyaretciProfil> {
  final controllerNet = Get.put(ControllerNet());

  bool kapat = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference kullaniciSorgu = controllerNet.firestore.collection('Kullanicilar');

    var kullaniciBilgileri = kullaniciSorgu.doc(widget.gelenKullaniciEmail);

    CollectionReference uyeler = controllerNet.firestore.collection('uyeler');

    var uyelerBilgileri = uyeler.doc(widget.gelenKullaniciEmail);

    Query postlarSorgu = controllerNet.firestore
        .collection('postlar')
        .where('email', isEqualTo: widget.gelenKullaniciEmail)
        .orderBy("zaman", descending: true)
        .limit(100);

    return SafeArea(
      child: Scaffold(
        appBar: akisAppBar(),
        drawer: const BenDrawer(),
        body: Container(
          child: StreamBuilder<DocumentSnapshot>(
              stream: kullaniciBilgileri.snapshots(),
              builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                if (asyncSnapshot.hasError) {
                  return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                } else {
                  if (asyncSnapshot.hasData) {
                    var ziyaretciProfilResmiLinki = asyncSnapshot.data.data()['profilresmilinki'];
                    var isim = asyncSnapshot.data.data()['isim'];
                    var soyisim = asyncSnapshot.data.data()['soyisim'];
                    var sehir = asyncSnapshot.data.data()['sehir'];
                    var iletisim = asyncSnapshot.data.data()['iletisim'];
                    var unic = asyncSnapshot.data.data()['unic'];
                    var arkadaslarUzunluk = asyncSnapshot.data.data()['arkadaslar'].length;
                    var id = asyncSnapshot.data.data()['id'];
                    var hakkinda = asyncSnapshot.data.data()['hakkinda'];
                    var dogumTarihi = asyncSnapshot.data.data()['dogum tarihi'];
                    var email = asyncSnapshot.data.data()['email'];
                    var engelleyenler = asyncSnapshot.data.data()['engelleyenler'];
                    var arkadaslar = asyncSnapshot.data.data()['arkadaslar'];
                    var begen = asyncSnapshot.data.data()['begen'];
                    var engelledim = asyncSnapshot.data.data()['engelledim'];
                    var profilGizli = asyncSnapshot.data.data()['profilGizli'];
                    dynamic arkadaslarIcindemi = arkadaslar.contains(kullanici.email);
                    dynamic engelledimGetir = engelledim.contains(kullanici.email);

                    return Center(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              kapat == false
                                  ? GestureDetector(
                                      onTap: () {
                                        kapat = true;
                                        setState(() {});
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: davetlilerDavetEden(engelledimGetir, arkadaslarIcindemi,
                                                    uyelerBilgileri, email, engelleyenler),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    Get.to(DavetEdilenler(
                                                      gelenKullaniciEmail: widget.gelenKullaniciEmail.toString(),
                                                    ));
                                                  },
                                                  child: Card(
                                                    //color: Colors.white12,
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                                        child: Text(
                                                          'Davet \nettikleri',
                                                          style: TextStyle(
                                                              fontFamily: 'Avenir',
                                                              fontSize: 14,
                                                              color: Colors.white70,
                                                              fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        )),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: profilFotoVeBilgiler(
                                                ziyaretciProfilResmiLinki,
                                                id,
                                                unic,
                                                isim,
                                                soyisim,
                                                profilGizli,
                                                arkadaslar,
                                                sehir,
                                                dogumTarihi,
                                                iletisim,
                                                hakkinda,
                                                engelledimGetir,
                                                email,
                                                engelleyenler),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                            child: Text(
                                                style: golgeliMetinText(),
                                                hakkinda.toString(),
                                                textAlign: TextAlign.start),
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              engelledim.contains(kullanici.email)
                                                  ? Center()
                                                  : profilGizli == true
                                                      ? arkadaslar.contains(kullanici.email)
                                                          ? akisindaOlanlar(arkadaslarUzunluk)
                                                          : Center()
                                                      : akisindaOlanlar(arkadaslarUzunluk),
                                              akisaEkle(email, begen),
                                            ],
                                          ),
                                          yalnizcaAkisiGoster(),
                                        ],
                                      ),
                                    )
                                  : Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: bilmemKiminAkisi(isim, soyisim),
                                        ),
                                      ],
                                    ),
                              Container(height: 2, color: Colors.red),
                              engelledimGetir
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Kullanıcı sizi engellemiş!'),
                                      ),
                                    )
                                  : Container(
                                      child: profilGizli == true
                                          ? arkadaslar.contains(kullanici.email)
                                              ? StreamBuilder<QuerySnapshot>(
                                                  stream: postlarSorgu.snapshots(),
                                                  builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                                                    if (asyncSnapshot.hasError) {
                                                      return const Center(
                                                          child: Text('Bir hata oluştu tekrar deneyin..'));
                                                    } else {
                                                      if (asyncSnapshot.hasData) {
                                                        List<DocumentSnapshot> listOfDocumentSnap =
                                                            asyncSnapshot.data.docs;

                                                        return ziyaretciAkisaGelenPostlar(listOfDocumentSnap);
                                                      } else {
                                                        /// yükleniyor bölümü
                                                        return buildDefaultTextStyle();
                                                      }
                                                    }
                                                  })
                                              : Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text('Profil Gizli!'),
                                                  ),
                                                )
                                          : StreamBuilder<QuerySnapshot>(
                                              stream: postlarSorgu.snapshots(),
                                              builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                                                if (asyncSnapshot.hasError) {
                                                  return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                                                } else {
                                                  if (asyncSnapshot.hasData) {
                                                    List<DocumentSnapshot> listOfDocumentSnap = asyncSnapshot.data.docs;

                                                    return ziyaretciAkisaGelenPostlar(listOfDocumentSnap);
                                                  } else {
                                                    /// yükleniyor bölümü
                                                    return buildDefaultTextStyle();
                                                  }
                                                }
                                              }),
                                    ),
                            ],
                          ),
                          engelledimGetir
                              ? Center()
                              : arkadaslarIcindemi
                                  ? BaskaAkisaMetinGirYeni(
                                      gelenKullaniciEmail: widget.gelenKullaniciEmail,
                                    )
                                  : Center(),
                        ],
                      ),
                    );
                  } else {
                    /// yükleniyor bölümü
                    return buildDefaultTextStyle();
                  }
                }
              }),
        ),
      ),
    );
  }

  GestureDetector bilmemKiminAkisi(isim, soyisim) {
    return GestureDetector(
      onTap: () {
        kapat = false;
        setState(() {});
      },
      child: Card(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    BoxShadow(color: Colors.red.withOpacity(.15), offset: Offset(2.0, 2.0), blurRadius: 10),
                  ]),
              isim.toString() + ' ' + soyisim.toString() + ' Akışı',
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Row profilFotoVeBilgiler(ziyaretciProfilResmiLinki, id, unic, isim, soyisim, profilGizli, arkadaslar, sehir,
      dogumTarihi, iletisim, hakkinda, engelledimGetir, email, engelleyenler) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white70,
                radius: 55,
                child: ClipOval(
                  child: Image.network(
                    ziyaretciProfilResmiLinki.toString(),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(style: golgeliMetinText(), '@' + id.toString(), textAlign: TextAlign.center),
              ),
              GestureDetector(
                onTap: () async {
                  await engelleFonksiyonu(email);
                  setState(() {});
                },
                child: Card(
                  color: Colors.white12,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: engelleyenler.contains(kullanici.email)
                        ? Text(
                            'Engellendi',
                            style: TextStyle(
                                fontFamily: 'Avenir', fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            'Engelle',
                            style: TextStyle(
                                fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        engelledimGetir
            ? Center()
            : Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: profilGizli == true
                      ? arkadaslar.contains(kullanici.email)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                      style: golgeliMetinText(),
                                      isim.toString() + ' ' + soyisim.toString(),
                                      textAlign: TextAlign.start),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                      style: golgeliMetinText(),
                                      'Unic: ' + unic.toString(),
                                      textAlign: TextAlign.start),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                    style: golgeliMetinText(),
                                    sehir.toString(),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                    style: golgeliMetinText(),
                                    dogumTarihi.toString(),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child:
                                      Text(style: golgeliMetinText(), iletisim.toString(), textAlign: TextAlign.start),
                                ),
                              ],
                            )
                          : Center()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                  style: golgeliMetinText(),
                                  isim.toString() + ' ' + soyisim.toString(),
                                  textAlign: TextAlign.start),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                  style: golgeliMetinText(), 'Unic: ' + unic.toString(), textAlign: TextAlign.start),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                style: golgeliMetinText(),
                                sehir.toString(),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                style: golgeliMetinText(),
                                dogumTarihi.toString(),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(style: golgeliMetinText(), iletisim.toString(), textAlign: TextAlign.start),
                            ),
                          ],
                        ),
                ),
              ),
      ],
    );
  }

  Padding sehirDogumTarihi(sehir, dogumTarihi) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Text(
          style: golgeliMetinText(), sehir.toString() + '       ' + dogumTarihi.toString(), textAlign: TextAlign.start),
    );
  }

  Center davetlilerDavetEden(
      engelledimGetir, arkadaslarIcindemi, DocumentReference<Object?> uyelerBilgileri, email, engelleyenler) {
    return Center(
      child: engelledimGetir
          ? Center()
          : Container(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: uyelerBilgileri.snapshots(),
                  builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                    if (asyncSnapshot.hasError) {
                      return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                    } else {
                      if (asyncSnapshot.hasData) {
                        dynamic ekleyenKisi = asyncSnapshot.data.data()['ekleyenKisi'];

                        return Container(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15.0),
                                                bottomRight: Radius.circular(15.0),
                                              ),
                                              child: Container(
                                                //color: Colors.blue,
                                                width: 40.0,
                                                height: 40.0,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    Get.to(ZiyaretciProfilAkiseGidis(gelenKullaniciEmail: ekleyenKisi));
                                                  },
                                                  child: profilResmiGetir(ekleyenKisi.toString()),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            profilIsmiGetir(ekleyenKisi.toString()),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                profilIdGetir(ekleyenKisi.toString()),
                                                profilUnicGetir(ekleyenKisi.toString()),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        /// yükleniyor bölümü
                        return buildDefaultTextStyle();
                      }
                    }
                  }),
            ),
    );
  }

  Row yalnizcaAkisiGoster() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Card(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Yalnızca Akışı Göster',
                style:
                    TextStyle(fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Expanded engelleButonu(email, engelleyenler) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          await engelleFonksiyonu(email);
          setState(() {});
        },
        child: Card(
          color: Colors.white12,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: engelleyenler.contains(kullanici.email)
                ? Text(
                    'Engellendi',
                    style:
                        TextStyle(fontFamily: 'Avenir', fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    'Engelle',
                    style: TextStyle(
                        fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }

  Expanded akisaEkle(email, begen) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final _firestore = FirebaseFirestore.instance;
          CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
          var icerik = kullanicilar.doc(kullanici.email);
          var secim = await icerik.get();
          dynamic map = secim.data();

          dynamic unic = map['unic'];
          dynamic arkadaslar = map['arkadaslar'];
          unicCikar();

          if (unic <= 0) {
          } else {
            if (email != kullanici.email) {
              if (arkadaslar.contains(email)) {
                await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
                  'arkadaslar': FieldValue.arrayRemove([email.toString()])
                }).whenComplete(() {
                  print('kullanıcı engellendi');
                });
                await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
                  "begen": FieldValue.arrayRemove([kullanici.email.toString()])
                });
              } else {
                await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
                  'arkadaslar': FieldValue.arrayUnion([email.toString()])
                }).whenComplete(() {
                  print('kullanıcı engellendi');
                });
                await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
                  "begen": FieldValue.arrayUnion([kullanici.email.toString()])
                });
              }
            }
          }
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: begen.contains(kullanici.email)
                ? Column(
                    children: [
                      Text(
                        'Ekleyen',
                        style: TextStyle(
                            fontFamily: 'Avenir', fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        begen.length.toString() + ' Kişi',
                        style: TextStyle(
                            fontFamily: 'Avenir', fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        'Ekle',
                        style: TextStyle(
                            fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '',
                        style: TextStyle(
                            fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Expanded akisindaOlanlar(arkadaslarUzunluk) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          Get.to(AkisindaOlanlar(
            gelenKullaniciEmail: widget.gelenKullaniciEmail.toString(),
          ));
        },
        child: Card(
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Text(
                    'Akışta',
                    style: TextStyle(
                        fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    arkadaslarUzunluk.toString() + ' Kişi',
                    style: TextStyle(
                        fontFamily: 'Avenir', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Flexible ziyaretciAkisaGelenPostlar(List<DocumentSnapshot<Object?>> listOfDocumentSnap) {
    return Flexible(
      child: ListView.builder(
          itemCount: listOfDocumentSnap.length,
          itemBuilder: (context, index) {
            var begenKontrol = listOfDocumentSnap[index].get('begen');
            var email = listOfDocumentSnap[index].get('email');
            var tarih = listOfDocumentSnap[index].get('tarih');
            var baslik = listOfDocumentSnap[index].get('baslik');
            var begenMeKontrol = listOfDocumentSnap[index].get('begenMe');
            var postVideoLinki = listOfDocumentSnap[index].get('postVideoLinki');
            var yorumSayisi = listOfDocumentSnap[index].get('yorumSayisi');

            var postFotolinki = listOfDocumentSnap[index].get('postFotolinki');

            var postAydi = listOfDocumentSnap[index].get('postAydi');
            var update = listOfDocumentSnap[index].reference.update;
            var bakBegenKontrol = begenKontrol.contains(kullanici.email);
            var bakBegenMeKontrol = begenMeKontrol.contains(kullanici.email);

            return GestureDetector(
              onTap: () {
                puanSa.put('postAydi', postAydi.toString());
                puanSa.put('email', email.toString());
                print(postAydi.toString());
                //Get.to(DoluYorumOku());
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                                      width: 50.0,
                                      height: 50.0,
                                      child: GestureDetector(
                                        onTap: () async {
                                          Get.to(ZiyaretciProfilAkiseGidis(gelenKullaniciEmail: email));
                                        },
                                        child: profilResmiGetir(email.toString()),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  profilIsmiGetir(email),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      profilIdGetir(email),
                                      profilUnicGetir(email),
                                    ],
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(tarih.toString() + ' ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              //fontWeight: FontWeight.bold,
                                              color: Colors.white60,
                                              fontSize: 10))),
                                ],
                              ),
                            ],
                          ),
                          kullanici.email == email.toString()
                              ? IconButton(
                                  onPressed: () async {
                                    Get.defaultDialog(
                                      title: "Uyarı",
                                      content: Center(),
                                      actions: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("Gönderiyi sil "),
                                            TextButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                                                  child: kullanici.email == email.toString()
                                                      ? IconButton(
                                                          onPressed: () async {
                                                            await listOfDocumentSnap[index].reference.delete();
                                                            Get.back();
                                                          },
                                                          icon: const Icon(
                                                            semanticLabel: 'Naber',
                                                            CupertinoIcons.delete,
                                                            size: 20,
                                                            color: Colors.red,
                                                          ))
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(horizontal: 15, vertical: 2))),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: Text("Vazgeç"),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.more_vert,
                                    size: 20,
                                    color: Colors.red,
                                  ))
                              : Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2)),
                          //postuDuzenleIconu(email, postAydi),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        '${baslik}',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: Colors.white60,
                          //fontFamily: 'montserrat',
                          //fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Card(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: postVideoLinki == ''
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
                                        width: 160,
                                        child: GestureDetector(
                                          onTap: () {
                                            Get.to(VideoFotoGosterSayfasi(
                                              gelenVideolink: postVideoLinki,
                                              gelenFotolink: postFotolinki,
                                            ));
                                          },
                                          child: Stack(
                                            //fit: StackFit.expand,
                                            alignment: Alignment.center,
                                            children: [
                                              Image.network(
                                                postFotolinki,
                                                fit: BoxFit.fill,
                                              ),
                                              SizedBox(height: 50, child: Image.asset('assets/images/png/play.png')),
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
                                        width: 160,
                                        child: GestureDetector(
                                          onTap: () {
                                            Get.to(VideoFotoGosterSayfasi(
                                              gelenVideolink: postVideoLinki,
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
                    SizedBox(
                      height: 35,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    await negatifOyVer(email, bakBegenMeKontrol, update);
                                  },
                                  icon: Icon(
                                    bakBegenMeKontrol ? Icons.heart_broken : CupertinoIcons.heart_slash,
                                    size: 20,
                                    color: bakBegenMeKontrol ? Colors.red : Colors.white70,
                                  )),
                              Text(' ${begenMeKontrol.length}',
                                  style:
                                      TextStyle(fontSize: 13, color: bakBegenMeKontrol ? Colors.red : Colors.white70)),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    await pozitifOyVer(listOfDocumentSnap, index, bakBegenKontrol, update, email);
                                  },
                                  icon: Icon(
                                    bakBegenKontrol ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                    size: 20,
                                    color: bakBegenKontrol ? Colors.green : Colors.white70,
                                  )),
                              Text('${begenKontrol.length}',
                                  style:
                                      TextStyle(fontSize: 13, color: bakBegenKontrol ? Colors.green : Colors.white70)),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    print(postAydi.toString());
                                    Get.to(PostaYorumOku(
                                      gelenKullaniciEmail: widget.gelenKullaniciEmail.toString(),
                                      postAydi: postAydi.toString(),
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
            );
          }),
    );
  }

  TextStyle golgeliMetinText() {
    return TextStyle(fontFamily: 'Avenir', fontSize: 17, color: Colors.white70, fontWeight: FontWeight.bold, shadows: [
      BoxShadow(color: Colors.red.withOpacity(.15), offset: Offset(2.0, 2.0), blurRadius: 10),
    ]);
  }

  Future<dynamic> unicCikart() async {
    final kullanici = FirebaseAuth.instance.currentUser!;
    final _firestore = FirebaseFirestore.instance;
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic unic = map['unic'];

    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update(unic >= 1 ? {"unic": FieldValue.increment(-1)} : {"unic": 0});
    return unic;
  }

  Future<void> engelleFonksiyonu(email) async {
    final _firestore = FirebaseFirestore.instance;
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic unic = map['unic'];
    dynamic engelledim = map['engelledim'];
    unicCikar();

    if (unic <= 0) {
    } else {
      if (email != kullanici.email) {
        if (engelledim.contains(email)) {
          await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
            'engelledim': FieldValue.arrayRemove([email.toString()])
          }).whenComplete(() {});
          await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
            "engelleyenler": FieldValue.arrayRemove([kullanici.email.toString()])
          });
        } else {
          await FirebaseFirestore.instance.collection("Kullanicilar").doc(kullanici.email).update({
            'engelledim': FieldValue.arrayUnion([email.toString()])
          }).whenComplete(() {});
          await FirebaseFirestore.instance.collection("Kullanicilar").doc(email.toString()).update({
            "engelleyenler": FieldValue.arrayUnion([kullanici.email.toString()])
          });
        }
      }
    }
    setState(() {});
  }

  ///

  ///
}
