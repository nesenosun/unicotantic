import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicotantic/Unic/fonksiyonlar/altButonlar.dart';

import 'buildDefaultTextStyle.dart';

StreamBuilder<DocumentSnapshot<Object?>> engellenenleriGetir(email) {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData) {
            var gelenEngellenenler = asyncSnapshot.data.data()['engellenenler'];
            var gelenEngellenenlerC = gelenEngellenenler.contains(kullanici.email);
            return gelenEngellenenlerC;
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> profilResmiGetir(email) {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData) {
            return Image.network(
              '${asyncSnapshot.data.data()['profilresmilinki']}',
              fit: BoxFit.fill,
            );
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> engelleyenleriGetir(email) {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData) {
            var engelleyenler = asyncSnapshot.data.data()['engelleyenler'];
            var engelleyenlerIcindemi = engelleyenler.contains(kullanici.email);

            print(engelleyenler);

            return engelleyenler;
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> profilUnicGetir(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData) {
            return Row(
              children: [
                Text(' ' + '${asyncSnapshot.data.data()['unic']}',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 11)),
                Text(' Unic ',
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

StreamBuilder<DocumentSnapshot<Object?>> profilUnicGetirKucuk(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData) {
            return Row(
              children: [
                Text(' ' + '${asyncSnapshot.data.data()['unic']}',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 8)),
                Text(' Unic ',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white60, fontSize: 8)),
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
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData) {
            return Text(
                '@${asyncSnapshot.data.data()['id'] == '.....' ? 'kullanıcı adı alınmadı' : asyncSnapshot.data.data()['id']}',
                textAlign: TextAlign.end,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 11));
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> profilIdGetirKucuk(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData) {
            return Text(
                '@${asyncSnapshot.data.data()['id'] == '.....' ? 'kullanıcı adı alınmadı' : asyncSnapshot.data.data()['id']}',
                textAlign: TextAlign.end,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 8));
          } else {
            /// yükleniyor bölümü
            return buildDefaultTextStyle();
          }
        }
      });
}

StreamBuilder<DocumentSnapshot<Object?>> profilSoyisimGetir(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (asyncSnapshot.hasData) {
            return Text(
              '${asyncSnapshot.data.data()['soyisim']}',
              textAlign: TextAlign.start,
              style: GoogleFonts.aBeeZee(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
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

StreamBuilder<DocumentSnapshot<Object?>> profilIsmiGetir(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot profilIsmiGetir) {
        if (profilIsmiGetir.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (profilIsmiGetir.hasData) {
            return Text(
              '${profilIsmiGetir.data.data()['isim']}' + ' ' + '${profilIsmiGetir.data.data()['soyisim']}',
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

StreamBuilder<DocumentSnapshot<Object?>> profilIsmiGetirKucuk(email) {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot profilIsmiGetir) {
        if (profilIsmiGetir.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (profilIsmiGetir.hasData) {
            return Text(
              '${profilIsmiGetir.data.data()['isim']}' + ' ' + '${profilIsmiGetir.data.data()['soyisim']}',
              textAlign: TextAlign.start,
              style: GoogleFonts.aBeeZee(
                fontWeight: FontWeight.bold,
                fontSize: 11,
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

StreamBuilder<DocumentSnapshot<Object?>> ekleyenIsmiGetirKucuk(email) {
  var ekleyenKisi = ekleyenKisiGetirFonksiyonu(email);
  final _firestore = FirebaseFirestore.instance;
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(ekleyenKisi.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot profilIsmiGetir) {
        if (profilIsmiGetir.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (profilIsmiGetir.hasData) {
            return Text(
              '${profilIsmiGetir.data.data()['isim']}' + ' ' + '${profilIsmiGetir.data.data()['soyisim']}',
              textAlign: TextAlign.start,
              style: GoogleFonts.aBeeZee(
                fontWeight: FontWeight.bold,
                fontSize: 11,
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
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot profilIsmiGetir) {
        if (profilIsmiGetir.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (profilIsmiGetir.hasData) {
            return Text(
              '${profilIsmiGetir.data.data()['iletisim']}',
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
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot profilIsmiGetir) {
        if (profilIsmiGetir.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (profilIsmiGetir.hasData) {
            return Text(
              '${profilIsmiGetir.data.data()['email']}',
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
  CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
  var icerik = kullanicilar.doc(email.toString());

  return StreamBuilder<DocumentSnapshot>(
      stream: icerik.snapshots(),
      builder: (BuildContext context, AsyncSnapshot profilIsmiGetir) {
        if (profilIsmiGetir.hasError) {
          return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
        } else {
          if (profilIsmiGetir.hasData) {
            return Text(
              '${profilIsmiGetir.data.data()['hakkinda']}',
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

Future<dynamic> ekleyenKisiGetirFonksiyonu(email) async {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  CollectionReference kullanicilar = _firestore.collection('uyeler');
  var icerik = kullanicilar.doc(email.toString());
  var secim = await icerik.get();
  dynamic map = secim.data();

  dynamic ekleyenKisi = map['ekleyenKisi'];
  puanSa.put('ekleyenKisi', ekleyenKisi);

  return ekleyenKisi.toString();
}

///
// GestureDetector(
//   onTap: () {
//     // Başka bir uygulamaya yönlendirecek URL
//     String url = "https://www.youtube.com";
//
//     // URL'yi açmak için URL Launcher kütüphanesini kullanma
//     launch(url);
//   },
//   child: Text(
//     "Başka Uygulamaya Git",
//     style: TextStyle(
//       color: Colors.blue,
//       decoration: TextDecoration.underline,
//     ),
//   ),
// ),
