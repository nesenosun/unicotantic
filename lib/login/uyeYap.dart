import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';

import '../Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import '../Unic/fonksiyonlar/doluYorumFonksiyonlari.dart';
import 'my_button.dart';

class UyeYap extends StatefulWidget {
  const UyeYap({super.key});

  @override
  State<UyeYap> createState() => _UyeYapState();
}

class _UyeYapState extends State<UyeYap> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  final puanSa = Hive.box('unicotantic');
  String? indirmeBaglantisi;
  GetStorage getbox = GetStorage();
  String galeri = '';
  String kullaniciAdi = 'adresi girin';
  final unicProfilResmiLinki =
      'https://firebasestorage.googleapis.com/v0/b/unic-otantic-e4f32.appspot.com/o/profilresimleri%2Funicotantic%40gmail.com%2F59profilResmi.png?alt=media&token=1cc7483a-308d-4738-bcdd-9de5edf85cc1';

  final isimC = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  kacKullaniciEklenmis() async {
    final kullanici = FirebaseAuth.instance.currentUser!;
    final _firestore = FirebaseFirestore.instance;
    CollectionReference kullanicilar = _firestore.collection('uygulamaAyarlari');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    bool uyeEklemeLimiti = map['uyeEklemeLimiti'];
    return uyeEklemeLimiti;
  }

  Future<bool> isUsernameUnique(String username) async {
    try {
      // Firestore'da usernameCollection koleksiyonunu sorgula
      QuerySnapshot querySnapshot = await _firestore.collection('uyeler').where('uyeEmail', isEqualTo: username).get();

      // Eğer sorgu sonucunda hiç belge dönmediyse, kullanıcı adı benzersizdir
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Hata: $e');
      return false; // Hata durumunda false döndür
    }
  }

  Future<void> saveUsernameToFirestore(String username) async {
    try {
      // Firestore'da usernameCollection koleksiyonuna yeni bir belge ekle

      await _firestore.collection('uyeler').doc(kullanici.email.toString()).update({
        'uyeEmail': kullanici.email.toString(),
        'ekleyenKisi': kullanici.email.toString(),
        'ekledigiUyeler': FieldValue.arrayUnion([username.trim().toString()]),
      });

      await _firestore.collection('uyeler').doc(username.trim().toString()).set({
        'uyeEmail': username.trim(),
        'ekleyenKisi': kullanici.email.toString(),
        'ekledigiUyeler': FieldValue.arrayUnion([username.trim()]),
      });

      await _firestore.collection('Kullanicilar').doc(username.trim().toString()).set({
        'profilresmilinki': unicProfilResmiLinki,
        'isim': 'Kullanıcı Henüz Üye Olmadı',
        'soyisim': '',
        'iletisim': '',
        'unic': '',
        'id': '',
        'email': '',
      });
    } catch (e) {
      print('Hata: $e');
    }
    kullaniciAdi = 'Başarıyla kaydedildi';
    setState(() {});
  }

// Kullanıcı adını kontrol et ve Firestore'a kaydet
  Future<String> checkAndSaveUsername(String username) async {
    // Kullanıcı adının benzersiz olup olmadığını kontrol et
    bool isUnique = await isUsernameUnique(username);

    if (isUnique) {
      // Firestore'da kullanıcı adını sakla
      await saveUsernameToFirestore(username);
      setState(() {});
      //kullaniciAdi = 'Değiştirildi';

      print('Kullanıcı adı benzersiz, Firestore\'a kaydedildi.');

      print(kullaniciAdi.toString() + '                                1');

      return kullaniciAdi;
    } else {
      setState(() {});
      kullaniciAdi = 'Bu kullancı daha önce kayıt edilmiş';

      return kullaniciAdi;
    }
  }

  void maint() async {
    if (_key.currentState!.validate()) {
      await checkAndSaveUsername(isimC.text.trim());
      print('isimler Eşit');
    }
  }

  Future<void> kayitOl() async {
    final _firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot =
        await _firestore.collection('Kullanicilar').where('email', isEqualTo: isimC.text.trim()).get();

    if (querySnapshot == isimC.text.trim()) {
      print('Var bu email');
    } else {
      if (_key.currentState!.validate()) {
        print('isimler Eşit');
      }
    }
  }

  @override
  void initState() {
    kacKullaniciEklenmis();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference uygulamaAyarlari = controllerNet.firestore.collection('uygulamaAyarları');
    var uygulamaAyarlariSorgu = uygulamaAyarlari.doc('guncellemeler');
    CollectionReference uyeler = controllerNet.firestore.collection('uyeler');
    var uyelerSorgu = uyeler.doc(kullanici.email);
    return SafeArea(
      child: Scaffold(
        appBar: akisAppBar(),
        body: Form(
          key: _key,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: StreamBuilder<DocumentSnapshot>(
                    stream: uygulamaAyarlariSorgu.snapshots(),
                    builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      if (asyncSnapshot.hasError) {
                        return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                      } else {
                        if (asyncSnapshot.hasData) {
                          dynamic uyeEklemeLimiti = asyncSnapshot.data.data()['uyeEklemeLimiti'];

                          // dynamic arkadaslarIcindemi = arkadaslar.contains(kullanici.email);
                          // dynamic engelledimGetir = engelledim.contains(kullanici.email);

                          return StreamBuilder<DocumentSnapshot>(
                              stream: uyelerSorgu.snapshots(),
                              builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                                if (asyncSnapshot.hasError) {
                                  return const Center(child: Text('Bir hata oluştu tekrar deneyin..'));
                                } else {
                                  if (asyncSnapshot.hasData) {
                                    int ekledigiUyelerUzunluk = asyncSnapshot.data.data()['ekledigiUyeler'].length;

                                    // dynamic arkadaslarIcindemi = arkadaslar.contains(kullanici.email);
                                    // dynamic engelledimGetir = engelledim.contains(kullanici.email);

                                    return ekledigiUyelerUzunluk >= uyeEklemeLimiti
                                        ? Center(
                                            child: Text(
                                              'Yeni Kullanıcı ekleme limitini doldurdunuz',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 28,
                                                color: Colors.deepPurpleAccent[100],
                                              ),
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(15.0),
                                                child: Text(
                                                  'Kurallar',
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                    color: Colors.deepPurpleAccent[100],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child:
                                                      Text(ekledigiUyelerUzunluk.toString() + ' kullanıcı eklediniz.'),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(15.0),
                                                child: Text(
                                                  '1. Yalnızca Hotmail ve Gmail adresi kabul edilir.'
                                                  '\n2. Eklediğiniz kişinin profilinde onu sizin eklediğiniz '
                                                  'daimi olarak görünecektir. \n3. En fazla ${uyeEklemeLimiti} kullanıcı ekleyebilirsiniz.',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white70,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                                                child: Card(
                                                  color: Colors.black54,
                                                  child: TextFormField(
                                                    controller: isimC,
                                                    obscureText: false,
                                                    validator: validateEmail,
                                                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 16),
                                                    decoration: InputDecoration(
                                                      focusColor: Colors.black54,
                                                      //add prefix icon
                                                      prefixIcon: const Icon(
                                                        Icons.email_outlined,
                                                        color: Colors.cyanAccent,
                                                        size: 30,
                                                      ),

                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                      ),

                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(color: Colors.cyanAccent, width: 1.0),
                                                        borderRadius: BorderRadius.circular(10.0),
                                                      ),
                                                      fillColor: Colors.black54,

                                                      hintText: "Email",

                                                      //make hint text
                                                      hintStyle: const TextStyle(
                                                        color: Colors.cyanAccent,
                                                        fontSize: 16,
                                                        fontFamily: "verdana_regular",
                                                        fontWeight: FontWeight.w400,
                                                      ),

                                                      labelText: 'Email',
                                                      //lable style
                                                      labelStyle: const TextStyle(
                                                        color: Colors.cyanAccent,
                                                        fontSize: 16,
                                                        fontFamily: "verdana_regular",
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(kullaniciAdi.toString()),

                                              const SizedBox(height: 30),

                                              // sign in button
                                              MyButton(
                                                text: 'Kullanıcı Ekle',
                                                onTap: maint,
                                              ),

                                              const SizedBox(height: 30),

                                              // or continue with
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                                child: Row(
                                                  children: const [
                                                    SizedBox(height: 20),
                                                  ],
                                                ),
                                              ),

                                              // apple + google sign in

                                              const SizedBox(height: 1),

                                              // not a member? register now
                                            ],
                                          );
                                  } else {
                                    /// yükleniyor bölümü
                                    return buildDefaultTextStyle();
                                  }
                                }
                              });
                        } else {
                          /// yükleniyor bölümü
                          return buildDefaultTextStyle();
                        }
                      }
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateEmail(String? formEmail) {
    if (formEmail == null || formEmail.isEmpty) {
      print('''E-mail adresin olmadan nasıl girmeyi düşünüyorsun?''');
      kullaniciAdi = 'E-mail adresi olmadan üye ekleyemezsiniz';
      setState(() {});
      return '';
    }
    String pattern = r'^(\w+[._-\w]+)@(hotmail.com|gmail.com|yahoo.com)$';
    //String pattern = r'\w+@\w+\.\w+';

    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(formEmail)) {
      setState(() {});

      kullaniciAdi = ''' Email adresini kontrol edin''';
      return '';
    }

    return null;
  }
}
