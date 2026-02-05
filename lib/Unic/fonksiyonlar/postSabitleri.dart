import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:unicotantic/Unic/fonksiyonlar/videoPlayrFlick.dart';
import 'package:unicotantic/akis/post_ayrintilari.dart';
import 'package:unicotantic/profil/yeniZiyaretciProfil.dart';

import 'altButonlar.dart';
import 'negatifOyVer_pozitifOyVer.dart';
import 'profilResmiGetir.dart';

Card ustBolumKullaniciKimligi(
  postAydi,
  email,
  tarih,
  listOfDocumentSnap,
  index,
) {
  return Card(
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
                        Get.to(YeniZiyaretciProfil(gelenKullaniciEmail: email));
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
                  children: [profilIdGetir(email), profilUnicGetir(email)],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    tarih.toString() + ' ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        kullanici.email == email.toString()
            ? IconButton(
                onPressed: () async {
                  Get.defaultDialog(
                    title: "Gönderiyi Sil",
                    middleText: "Bu gönderiyi silmek istediğinizden emin misiniz?",
                    backgroundColor: Colors.grey[900],
                    titleStyle: const TextStyle(color: Colors.white),
                    middleTextStyle: const TextStyle(color: Colors.white70),
                    textConfirm: "Sil",
                    textCancel: "Vazgeç",
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: () async {
                      Get.back();
                      try {
                        await listOfDocumentSnap[index].reference.delete();
                      } catch (e) {
                        Get.snackbar(
                          "Hata",
                          "Silme işlemi başarısız: $e",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                  );
                },
                icon: const Icon(Icons.more_vert, size: 20, color: Colors.red),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 2,
                ),
              ),
        //postuDuzenleIconu(email, postAydi),
      ],
    ),
  );
}

Card ustBolumKullaniciKimligiYorumaYorum(
  postYorumIDe,
  postAydi,
  email,
  tarih,
  listOfDocumentSnap,
  index,
) {
  return Card(
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
                        Get.to(YeniZiyaretciProfil(gelenKullaniciEmail: email));
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
                  children: [profilIdGetir(email), profilUnicGetir(email)],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    tarih.toString() + ' ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        kullanici.email == email.toString()
            ? IconButton(
                onPressed: () async {
                  Get.defaultDialog(
                    title: "Yorumu Sil",
                    middleText: "Bu yorumu silmek istediğinizden emin misiniz?",
                    backgroundColor: Colors.grey[900],
                    titleStyle: const TextStyle(color: Colors.white),
                    middleTextStyle: const TextStyle(color: Colors.white70),
                    textConfirm: "Sil",
                    textCancel: "Vazgeç",
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: () async {
                      try {
                        await listOfDocumentSnap[index].reference.delete();
                        Get.back();
                        // Ana postun yorum sayısını azalt
                        await FirebaseFirestore.instance.collection("postlar").doc(postAydi.toString()).update({
                          "yorumSayisi": FieldValue.increment(-1),
                        });
                        Get.snackbar(
                          "Başarılı",
                          "Yorum silindi",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        Get.snackbar(
                          "Hata",
                          "Silme işlemi başarısız: $e",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                  );
                },
                icon: const Icon(Icons.more_vert, size: 20, color: Colors.red),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 2,
                ),
              ),
        //postuDuzenleIconu(email, postAydi),
      ],
    ),
  );
}

Padding ikinciBolumText(baslik) {
  return Padding(
    padding: const EdgeInsets.all(3.0),
    child: Text(
      '${baslik}',
      textAlign: TextAlign.start,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        fontSize: 15,
        color: Colors.white60,
      ),
    ),
  );
}

Card ucuncuBolumVideoFotograf(postVideoLinki, postFotolinki) {
  return Card(
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
                          Get.to(
                            VideoFotoGosterSayfasi(
                              gelenVideolink: postVideoLinki,
                              gelenFotolink: postFotolinki,
                            ),
                          );
                        },
                        child: Stack(
                          //fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: [
                            Image.network(postFotolinki, fit: BoxFit.fill),
                            SizedBox(
                              height: 50,
                              child: Image.asset('assets/images/png/play.png'),
                            ),
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
                          Get.to(
                            VideoFotoGosterSayfasi(
                              gelenVideolink: postVideoLinki,
                              gelenFotolink: postFotolinki,
                            ),
                          );
                        },
                        child: Image.network(postFotolinki, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    ),
  );
}

SizedBox DorduncuBolumAltBar(
  email,
  List<DocumentSnapshot<Object?>> listOfDocumentSnap,
  int index,
  bakBegenMeKontrol,
  Future<void> update(Map<Object, Object?> data),
  begenMeKontrol,
  bakBegenKontrol,
  begenKontrol,
  postAydi,
  yorumSayisi,
) {
  return SizedBox(
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
              ),
            ),
            Text(
              ' ${begenMeKontrol.length}',
              style: TextStyle(
                fontSize: 13,
                color: bakBegenMeKontrol ? Colors.red : Colors.white70,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                await pozitifOyVer(
                  listOfDocumentSnap,
                  index,
                  bakBegenKontrol,
                  update,
                  email,
                );
              },
              icon: Icon(
                bakBegenKontrol ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: 20,
                color: bakBegenKontrol ? Colors.green : Colors.white70,
              ),
            ),
            Text(
              '${begenKontrol.length}',
              style: TextStyle(
                fontSize: 13,
                color: bakBegenKontrol ? Colors.green : Colors.white70,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () async {
                // puanSa.put('postAydi', postAydi.toString());
                // puanSa.put('email', email.toString());
                print(postAydi.toString());
                Get.to(
                  PostAyrintilari(
                    postID: postAydi,
                  ),
                );
              },
              icon: Icon(
                CupertinoIcons.conversation_bubble,
                size: 20,
                color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
              ),
            ),
            Text(
              '${yorumSayisi}' + '  ',
              style: TextStyle(
                fontSize: 13,
                color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

SizedBox DorduncuBolumAltBarPostaYorum(
  email,
  List<DocumentSnapshot<Object?>> listOfDocumentSnap,
  int index,
  bakBegenMeKontrol,
  Future<void> update(Map<Object, Object?> data),
  begenMeKontrol,
  bakBegenKontrol,
  begenKontrol,
  postAydi,
  yorumSayisi,
) {
  return SizedBox(
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
              ),
            ),
            Text(
              ' ${begenMeKontrol.length}',
              style: TextStyle(
                fontSize: 13,
                color: bakBegenMeKontrol ? Colors.red : Colors.white70,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                await pozitifOyVer(
                  listOfDocumentSnap,
                  index,
                  bakBegenKontrol,
                  update,
                  email,
                );
              },
              icon: Icon(
                bakBegenKontrol ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: 20,
                color: bakBegenKontrol ? Colors.green : Colors.white70,
              ),
            ),
            Text(
              '${begenKontrol.length}',
              style: TextStyle(
                fontSize: 13,
                color: bakBegenKontrol ? Colors.green : Colors.white70,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () async {
                // puanSa.put('postAydi', postAydi.toString());
                // puanSa.put('email', email.toString());
                print(postAydi.toString());
                Get.to(
                  PostAyrintilari(
                    postID: postAydi,
                  ),
                );
              },
              icon: Icon(
                CupertinoIcons.conversation_bubble,
                size: 20,
                color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
              ),
            ),
            Text(
              '${yorumSayisi}' + '  ',
              style: TextStyle(
                fontSize: 13,
                color: yorumSayisi <= 0 ? Colors.white70 : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
