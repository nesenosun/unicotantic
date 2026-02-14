import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'buildDefaultTextStyle.dart';

StreamBuilder<DocumentSnapshot<Object?>> profilResmiGetir(email) {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference users = _firestore.collection('users');
  var icerik = users.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData && asyncSnapshot.data.exists) {
            final data = asyncSnapshot.data.data() as Map<String, dynamic>?;
            // users koleksiyonunda genellikle photoUrl veya profilresmilinki kullanılır.
            // Eğer profilresmilinki boş dönerse photoUrl'i dene.
            final link = data?['profilresmilinki'] ?? data?['photoUrl'];
            if (link == null || link == 'bos') {
              return const Icon(Icons.person, color: Colors.white);
            }
            return Image.network(
              '$link',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: Colors.cyanAccent,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.person, color: Colors.white54, size: 30),
                );
              },
            );
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> profilUnicGetir(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference users = _firestore.collection('users');
  var icerik = users.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData && asyncSnapshot.data.exists) {
            final data = asyncSnapshot.data.data() as Map<String, dynamic>?;
            String username = "";
            if (data != null) {
              if (data['username'] != null) {
                username = data['username'].toString();
              } else if (data['uid'] != null) {
                String uidStr = data['uid'].toString();
                username = uidStr.length > 5 ? uidStr.substring(0, 5) : uidStr;
              }
            }
            if (username.isEmpty) {
              username = email.toString().split('@')[0];
            }

            return Row(
              children: [
                if (username.isNotEmpty)
                  Text('@$username ',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent, fontSize: 11)),
                Text('${data?['unicBalance'] ?? 0}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 11)),
                const Text(' Unic ',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white60, fontSize: 11)),
              ],
            );
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> profilIdGetir(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference users = _firestore.collection('users');
  var icerik = users.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData && asyncSnapshot.data.exists) {
            final data = asyncSnapshot.data.data() as Map<String, dynamic>?;
            final username = data?['username'] ?? data?['id'] ?? data?['uid'] ?? '.....';
            return Text('@${username == '.....' ? 'kullanıcı adı alınmadı' : username}',
                textAlign: TextAlign.end,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 11));
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> profilIsmiGetir(authorID) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference users = _firestore.collection('users');
  var icerik = users.doc(authorID.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot profilIsmiGetir) {
        if (profilIsmiGetir.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (profilIsmiGetir.hasData && profilIsmiGetir.data.exists) {
            final data = profilIsmiGetir.data.data() as Map<String, dynamic>?;
            return Text(
              '${data?['name'] ?? data?['isim'] ?? data?['username'] ?? ''}',
              textAlign: TextAlign.start,
              style: GoogleFonts.aBeeZee(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white70,
                //fontFamily: 'montserrat',
                //fontWeight: FontWeight.w500,
              ),
            );
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> profilIletisimGetir(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference users = _firestore.collection('users');
  var icerik = users.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot profilIsmiGetir) {
        if (profilIsmiGetir.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (profilIsmiGetir.hasData && profilIsmiGetir.data.exists) {
            final data = profilIsmiGetir.data.data() as Map<String, dynamic>?;
            return Text(
              '${data?['email'] ?? ''}',
              textAlign: TextAlign.start,
              style: GoogleFonts.aBeeZee(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white60,
                //fontFamily: 'montserrat',
                //fontWeight: FontWeight.w500,
              ),
            );
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> profilEmailGetir(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference users = _firestore.collection('users');
  var icerik = users.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot profilIsmiGetir) {
        if (profilIsmiGetir.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (profilIsmiGetir.hasData && profilIsmiGetir.data.exists) {
            final data = profilIsmiGetir.data.data() as Map<String, dynamic>?;
            return Text(
              '${data?['email'] ?? ''}',
              textAlign: TextAlign.start,
              style: GoogleFonts.aBeeZee(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white60,
                //fontFamily: 'montserrat',
                //fontWeight: FontWeight.w500,
              ),
            );
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> profilHakkinda(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference users = _firestore.collection('users');
  var icerik = users.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot profilIsmiGetir) {
        if (profilIsmiGetir.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (profilIsmiGetir.hasData && profilIsmiGetir.data.exists) {
            final data = profilIsmiGetir.data.data() as Map<String, dynamic>?;
            return Text(
              '${data?['hakkinda'] ?? data?['bio'] ?? ''}',
              textAlign: TextAlign.start,
              style: GoogleFonts.aBeeZee(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white60,
                //fontFamily: 'montserrat',
                //fontWeight: FontWeight.w500,
              ),
            );
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

Future<dynamic> unicCikart() async {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  CollectionReference users = _firestore.collection('users');
  var icerik = users.doc(kullanici.uid);
  var secim = await icerik.get();
  dynamic map = secim.data();

  dynamic unic = map['unicBalance'];

  await FirebaseFirestore.instance
      .collection("users")
      .doc(kullanici.uid)
      .update(unic >= 1 ? {"unicBalance": FieldValue.increment(-1)} : {"unicBalance": 0});
  return unic;
}
