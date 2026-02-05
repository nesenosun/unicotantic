import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/profil/yeniZiyaretciProfil.dart';

import 'altButonlar.dart';

Card postUstBolumFonksiyon(
  email,
  profilResmiCikar(dynamic email),
  profilIsmiCikar(dynamic email),
  profilSoyIsimCikar(dynamic email),
  id,
  unicCikar(dynamic email),
  duzenlemeMetin,
  tarih,
  postAydi,
  mapYorum,
) {
  return Card(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
                width: 42.0,
                height: 42.0,
                child: GestureDetector(
                  onTap: () async {
                    // puanSa.put('postAydi', postAydi.toString());
                    puanSa.put('email', email.toString());
                    Get.to(YeniZiyaretciProfil(gelenKullaniciEmail: email));
                  },
                  child: profilResmiCikar(email.toString()),
                ),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                profilIsmiCikar(email),
                SizedBox(width: 3),
                profilSoyIsimCikar(email),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '@' + id.substring(5, 15) + ' ',
                  style: const TextStyle(
                      fontSize: 12,
                      //fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
                Card(
                  child: unicCikar(email),
                ),
              ],
            ),
            mapYorum == []
                ? Text(tarih.toString() + ' ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        color: Colors.white60,
                        fontSize: 12))
                : GestureDetector(
                    onTap: () {
                      puanSa.put('postAydi', postAydi.toString());
                      puanSa.put('email', email.toString());
                    },
                    child: Text(tarih.toString() + '  düzenlendi ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            fontSize: 12)),
                  ),
          ],
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            child: kullanici.email == email.toString()
                ? IconButton(
                    onPressed: () async {
                      puanSa.put('postAydi', postAydi.toString());
                      puanSa.put('email', email.toString());
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 15,
                      color: Colors.greenAccent,
                    ))
                : Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2))),
      ],
    ),
  );
}
