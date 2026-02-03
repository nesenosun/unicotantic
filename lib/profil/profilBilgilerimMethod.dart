import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';

Row profilBilgilerimMethod(DocumentReference<Object?> icerik) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      StreamBuilder<DocumentSnapshot>(
          stream: icerik.snapshots(),
          builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
            if (asyncSnapshot.hasError) {
              return const Center(
                  child: Text('Bir hata oluştu tekrar deneyin..'));
            } else {
              if (asyncSnapshot.hasData) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        radius: 60,
                        child: ClipOval(
                          child: Image.network(
                            '${asyncSnapshot.data.data()['profilresmilinki']}',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        BoxShadow(
                                            color: Colors.red.withOpacity(.15),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 10),
                                      ]),
                                  '${asyncSnapshot.data.data()['isim']} ' +
                                      '${asyncSnapshot.data.data()['soyisim']}',
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        BoxShadow(
                                            color: Colors.red.withOpacity(.15),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 10),
                                      ]),
                                  '${asyncSnapshot.data.data()['sehir']} ' +
                                      ' ${asyncSnapshot.data.data()['dogum tarihi']}',
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 13,
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        BoxShadow(
                                            color: Colors.red.withOpacity(.15),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 10),
                                      ]),
                                  '${asyncSnapshot.data.data()['iletisim']}',
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 11,
                                      color: Colors.orangeAccent[700],
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        BoxShadow(
                                            color: Colors.red.withOpacity(.15),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 10),
                                      ]),
                                  '${asyncSnapshot.data.data()['hakkinda']}',
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                /// yükleniyor bölümü
                return buildDefaultTextStyle();
              }
            }
          }),
    ],
  );
}
