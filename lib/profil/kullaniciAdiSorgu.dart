import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:unicotantic/Unic/fonksiyonlar/kullaniciProfilUstBar.dart';
import 'package:unicotantic/profil/BenDrawer.dart';

class KullaniciAdiSorgu extends StatefulWidget {
  const KullaniciAdiSorgu({super.key});

  @override
  State<KullaniciAdiSorgu> createState() => _KullaniciAdiSorguState();
}

class _KullaniciAdiSorguState extends State<KullaniciAdiSorgu> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  final puanSa = Hive.box('unicotantic');
  late File yuklenecekDosya = 'assets/images/icon/icon256.png' as File;
  String? indirmeBaglantisi;
  GetStorage getbox = GetStorage();
  String galeri = '';
  String kullaniciAdi = 'Kullanıcı';

  final isimC = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  Future<void> isimEkle() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update({
      'isim': isimC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic isim = map['isim'];

    puanSa.put('isim', isim.toString());
    setState(() {});
  }

// Kullanıcı adlarını saklamak için kullanılacak koleksiyon adı
  final String usernameCollection = 'usernames';

  Future<bool> isUsernameUnique(String username) async {
    try {
      // Firestore'da usernameCollection koleksiyonunu sorgula
      QuerySnapshot querySnapshot = await _firestore
          .collection('Kullanicilar')
          .where('id', isEqualTo: username)
          .get();

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
      await _firestore.collection('Kullanicilar').doc(kullanici.email).update({
        'id': username,
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

// Kullanıcı adını kontrol et ve Firestore'a kaydet
  Future<String> checkAndSaveUsername(String username) async {
    // Kullanıcı adının benzersiz olup olmadığını kontrol et
    bool isUnique = await isUsernameUnique(username);

    if (isUnique) {
      // Firestore'da kullanıcı adını sakla
      await saveUsernameToFirestore(username);
      setState(() {});
      kullaniciAdi = 'Değiştirildi';
      print('Kullanıcı adı benzersiz, Firestore\'a kaydedildi.');
      print(kullaniciAdi.toString() + '                                1');

      return kullaniciAdi;
    } else {
      setState(() {});
      kullaniciAdi = 'Kullanılıyor';
      print('Kullanıcı adı zaten kullanılıyor.');
      print(kullaniciAdi.toString() + '                                2');

      return kullaniciAdi;
    }
  }

  void maint() async {
    // Kullanıcı adını kontrol et ve Firestore'a kaydet
    await checkAndSaveUsername(isimC.text);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var kullaniciBilgileriSorgu = kullanicilar.doc(kullanici.email);

    print(kullaniciAdi.toString() +
        '                                kullaniciAdir');

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 200,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
              bottom: Radius.circular(20),
            ),
          ),
          actions: <Widget>[
            Expanded(
                flex: 4,
                child: Column(
                  children: [
                    kullaniciProfilUstBar(kullaniciBilgileriSorgu),
                  ],
                )),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        drawer: BenDrawer(),
        body: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Card(
              //color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              maxLength: 15,
                              maxLines: 1,
                              controller: isimC,
                              obscureText: false,
                              style: const TextStyle(
                                  color: Colors.cyanAccent, fontSize: 16),
                              decoration: InputDecoration(
                                focusColor: Colors.black54,
                                //add prefix icon
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.cyanAccent,
                                  size: 30,
                                ),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.cyanAccent, width: 1.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                fillColor: Colors.black54,

                                //hintText: "İsim",

                                //make hint text
                                hintStyle: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 12,
                                  fontFamily: "verdana_regular",
                                  fontWeight: FontWeight.w400,
                                ),

                                labelText: kullaniciAdi,

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
                          Expanded(
                            child: TextButton(
                              onPressed: maint,
                              child: const Text('Ok'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 1),

                    // not a member? register now
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
