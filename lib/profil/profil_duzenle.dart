import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:unicotantic/Unic/fonksiyonlar/kullaniciProfilUstBar.dart';
import 'package:unicotantic/profil/BenDrawer.dart';

class ProfilDuzenle extends StatefulWidget {
  const ProfilDuzenle({super.key});

  @override
  State<ProfilDuzenle> createState() => _ProfilDuzenleState();
}

class _ProfilDuzenleState extends State<ProfilDuzenle> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  final puanSa = Hive.box('unicotantic');
  GetStorage getbox = GetStorage();

  final isimC = TextEditingController();
  final soyadC = TextEditingController();
  final dogumTarihiC = TextEditingController();
  final iletisimC = TextEditingController();
  final hakkindaC = TextEditingController();
  final sehirC = TextEditingController();
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

  Future<void> soyIsimEkle() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update({
      'soyisim': soyadC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic soyisim = map['soyisim'];

    getbox.write('soyisim', soyisim.toString());
    setState(() {});
  }

  Future<void> dogumTarihi() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update({
      'dogum tarihi': dogumTarihiC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic dogumtarihi = map['dogum tarihi'];

    getbox.write('dogum tarihi', dogumtarihi.toString());
    setState(() {});
  }

  Future<void> iletisimEkle() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update({
      'iletisim': iletisimC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic iletisim = map['iletisim'];

    getbox.write('iletisim', iletisim.toString());
    setState(() {});
  }

  Future<void> sehirEkle() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update({
      'sehir': sehirC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic sehir = map['sehir'];

    getbox.write('sehir', sehir.toString());
    setState(() {});
  }

  Future<void> hakkindaEkle() async {
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update({
      'hakkinda': hakkindaC.text,
    });

    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    dynamic map = secim.data();

    dynamic hakkinda = map['hakkinda'];

    getbox.write('hakkinda', hakkinda.toString());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var kullaniciBilgileriSorgu = kullanicilar.doc(kullanici.email);

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

                    textFieldMethod(
                        isimC, Icons.account_circle_outlined, 'isim', isimEkle),
                    textFieldMethod(
                        soyadC, Icons.account_circle, 'Soy isim', soyIsimEkle),
                    textFieldMethod(
                        sehirC, Icons.location_city, 'Şehir', sehirEkle),
                    textFieldMethod(dogumTarihiC, Icons.cake_sharp,
                        'Doğum Tarihi', dogumTarihi),
                    textFieldMethod(iletisimC, Icons.accessibility_new_outlined,
                        'İletişim', iletisimEkle),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              maxLength: 90,
                              maxLines: 3,
                              controller: hakkindaC,
                              obscureText: false,
                              style: const TextStyle(
                                  color: Colors.cyanAccent, fontSize: 16),
                              decoration: InputDecoration(
                                focusColor: Colors.black54,
                                //add prefix icon
                                prefixIcon: const Icon(
                                  Icons.accessibility_new_outlined,
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
                                  fontSize: 16,
                                  fontFamily: "verdana_regular",
                                  fontWeight: FontWeight.w400,
                                ),

                                labelText: 'Hakkımda',

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
                              onPressed: hakkindaEkle,
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

  Padding textFieldMethod(isimC, icon, isim, isimEkle) {
    return Padding(
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
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 16),
              decoration: InputDecoration(
                focusColor: Colors.black54,
                //add prefix icon
                prefixIcon: Icon(
                  icon,
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

                //hintText: "İsim",

                //make hint text
                hintStyle: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 12,
                  fontFamily: "verdana_regular",
                  fontWeight: FontWeight.w400,
                ),

                labelText: isim,

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
              onPressed: isimEkle,
              child: const Text('Ok'),
            ),
          ),
        ],
      ),
    );
  }
}
