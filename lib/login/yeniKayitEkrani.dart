import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/login/splash.dart';

import 'email_giris.dart';
import 'my_button.dart';
import 'sifremi_unuttum.dart';

class YeniKayitEkrani extends StatefulWidget {
  const YeniKayitEkrani({super.key});

  @override
  State<YeniKayitEkrani> createState() => _YeniKayitEkraniState();
}

class _YeniKayitEkraniState extends State<YeniKayitEkrani> {
  final _firestore = FirebaseFirestore.instance;
  final puanSa = Hive.box('unicotantic');

  final unicProfilResmiLinki =
      'https://firebasestorage.googleapis.com/v0/b/unic-otantic-e4f32.appspot.com/o/profilresimleri%2Funicotantic%40gmail.com%2F59profilResmi.png?alt=media&token=1cc7483a-308d-4738-bcdd-9de5edf85cc1';
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isimController = TextEditingController();

  //late final FirebaseMessaging messaging;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  GetStorage getbox = GetStorage();

  String dtzaman = DateTime.now().year.toString() +
      DateTime.now().month.toString() +
      DateTime.now().day.toString() +
      DateTime.now().hour.toString() +
      DateTime.now().minute.toString() +
      DateTime.now().second.toString();

  String kullaniciAdi = 'Email';

  Future<void> kayitOl() async {
    final _firestore = FirebaseFirestore.instance;
    Query akisSorgu = _firestore.collection('Kullanicilar').orderBy("isim");

    if (akisSorgu == _isimController.text.trim()) {
    } else {
      getbox.write('profilresmilinki', unicProfilResmiLinki);
      getbox.write('kullaniciAdi', _usernameController);
      getbox.write('sifre', _passwordController);
      getbox.write('isim', _isimController);
      if (_key.currentState!.validate()) {
        showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      }
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      )
          .then((kullanici) {
        FirebaseFirestore.instance
            // ignore: prefer_adjacent_string_concatenation
            .collection("Kullanicilar")
            .doc(_usernameController.text)
            .set({
          "email": _usernameController.text,
          "sifre": '',
          'isim': _isimController.text,
          'id': '.....',
          'uid': 'abcdefghijklmnoprst',
          'kayit tarihi': DateTime.now(),
          'sehir': 'Şehir',
          'soyisim': 'Soyisim',
          'dogum tarihi': 'Doğum Tarihi',
          'hakkinda': 'Hakkında',
          'iletisim': 'İletişim',
          'lazim': 'lazim',
          'unic': 100,
          'metin': 'Metin',
          'bildirim': 0,
          'postSayisi': 0,
          'cuzdan': 'BSC Cüzdan',
          'arkadaslar': ['dvdv@weegfwe.dsvdsv'],
          'engelledim': ['dvdv@weegfwe.dsvdsv'],
          'engelleyenler': ['dvdv@weegfwe.dsvdsv'],
          'begen': ['dvdv@weegfwe.dsvdsv'],
          'begenMe': ['dvdv@weegfwe.dsvdsv'],
          'profilresmilinki': unicProfilResmiLinki,
          'profilGizli': false,
        });
      });
    }

    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(_usernameController.text)
        .update({
      'id': '.....',
      'uid': 'abcdefghijklmnoprst',
    }).whenComplete(() => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Splash()),
            (Route<dynamic> route) => false));
  }

  @override
  void initState() {
    puanSa.put('uygulama25', 26);
    puanSa.put('uygulamaSurumu', 26);
    puanSa.put('yeniAyarlar', 'yeniAyarlar001');
    super.initState();
  }

  void uyelikVarmi() async {
    if (_key.currentState!.validate()) {
      await uyeOlmamissaMaintCalistir(_usernameController.text.trim());
    }
  }

  void maint() async {
    if (_key.currentState!.validate()) {
      await kontrolEtVeKaydet(_usernameController.text.trim());
    }
  }

  Future<String> uyeOlmamissaMaintCalistir(String username) async {
    // Kullanıcı adının benzersiz olup olmadığını kontrol et
    bool isUnique = await kullaniciUyeOlmusmu(username);

    if (isUnique) {
      kullaniciAdi = 'Bu email kayıtlı, şifrenizi değiştirin';
      setState(() {});

      return kullaniciAdi;
    } else {
      maint();
      setState(() {});
      kullaniciAdi = '......';

      return kullaniciAdi;
    }
  }

  Future<String> kontrolEtVeKaydet(String username) async {
    // Kullanıcı adının benzersiz olup olmadığını kontrol et
    bool isUnique = await kullaniciAdiBenzersizMi(username);

    if (isUnique) {
      kullaniciAdi = 'Davetiyeniz Yok';
      setState(() {});

      return kullaniciAdi;
    } else {
      setState(() {});
      kullaniciAdi = 'Tebrikler Davet Edilmişsiniz';

      return kullaniciAdi;
    }
  }

  Future<bool> kullaniciAdiBenzersizMi(String username) async {
    try {
      // Firestore'da usernameCollection koleksiyonunu sorgula
      QuerySnapshot querySnapshot = await _firestore
          .collection('uyeler')
          .where('uyeEmail', isEqualTo: username)
          .get();

      // Eğer sorgu sonucunda hiç belge dönmediyse, kullanıcı adı benzersizdir
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Hata: $e');
      return false; // Hata durumunda false döndür
    }
  }

  Future<bool> kullaniciUyeOlmusmu(String username) async {
    try {
      // Firestore'da usernameCollection koleksiyonunu sorgula
      QuerySnapshot uyeVarMiSnapshot = await _firestore
          .collection('Kullanicilar')
          .where('email', isEqualTo: username)
          .get();

      // Eğer sorgu sonucunda hiç belge dönmediyse, kullanıcı adı benzersizdir
      return uyeVarMiSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Hata: $e');
      return false; // Hata durumunda false döndür
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _key,
          child: SingleChildScrollView(
            child: kullaniciAdi == 'Tebrikler Davet Edilmişsiniz'
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 100,
                          child: GestureDetector(
                            onTap: () {
                              //Get.to(const ReklamAnaSayfa());
                            },
                            child: Image.asset(
                              "assets/images/png/akis.png",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      kullaniciAdi == 'Email'
                          ? Text('Davet Kontrol',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 25,
                                color: kullaniciAdi ==
                                        'Tebrikler Davet Edilmişsiniz'
                                    ? Colors.green
                                    : Colors.red,
                              ))
                          : Text(kullaniciAdi.toString(),
                              style: GoogleFonts.bebasNeue(
                                fontSize: 18,
                                color: Colors.white70,
                              )),

                      const SizedBox(height: 10),
                      // password textfield
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 30),
                        child: Card(
                          color: Colors.black54,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: validatePassword,
                            style: const TextStyle(
                                color: Colors.cyanAccent, fontSize: 16),
                            decoration: InputDecoration(
                              focusColor: Colors.black54,
                              //add prefix icon
                              prefixIcon: const Icon(
                                Icons.lock_outline,
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

                              hintText: "Parola",

                              //make hint text
                              hintStyle: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 16,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),

                              //create lable
                              labelText: 'Parola',
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
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 30),
                        child: Card(
                          color: Colors.black54,
                          child: TextFormField(
                            controller: _isimController,
                            obscureText: false,
                            style: const TextStyle(
                                color: Colors.cyanAccent, fontSize: 16),
                            decoration: InputDecoration(
                              focusColor: Colors.black54,
                              //add prefix icon
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
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

                              hintText: "İsim",

                              //make hint text
                              hintStyle: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 16,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),

                              labelText: 'İsim',
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

                      const SizedBox(height: 10),

                      // forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              Get.to(EmailGiris());
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(18.0),
                              child: Text(
                                'Hesabım var',
                                style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              Get.to(SifremiUnuttum());
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(18.0),
                              child: Text(
                                'Şifremi Unuttum',
                                style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // sign in button
                      MyButton(
                        text: 'Kayıt Ol',
                        onTap: kayitOl,
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
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 100,
                          child: GestureDetector(
                            onTap: () {
                              //Get.to(const ReklamAnaSayfa());
                            },
                            child: Image.asset(
                              "assets/images/png/akis.png",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      kullaniciAdi == 'Email'
                          ? Text('Davet Kontrol',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 25,
                                color: kullaniciAdi ==
                                        'Tebrikler Davet Edilmişsiniz'
                                    ? Colors.green
                                    : Colors.red,
                              ))
                          : Text(kullaniciAdi.toString(),
                              style: GoogleFonts.bebasNeue(
                                fontSize: 18,
                                color: Colors.white70,
                              )),

                      const SizedBox(height: 10),

                      // username textfield
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 30),
                        child: Card(
                          color: Colors.black54,
                          child: TextFormField(
                            controller: _usernameController,
                            obscureText: false,
                            validator: validateEmail,
                            style: const TextStyle(
                                color: Colors.cyanAccent, fontSize: 16),
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
                                borderSide: const BorderSide(
                                    color: Colors.cyanAccent, width: 1.0),
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

                      const SizedBox(height: 10),

                      // forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              Get.to(EmailGiris());
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(18.0),
                              child: Text(
                                'Hesabım var',
                                style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              Get.to(SifremiUnuttum());
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(18.0),
                              child: Text(
                                'Şifremi Unuttum',
                                style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // sign in button
                      MyButton(
                        text: 'Kontrol et',
                        onTap: uyelikVarmi,
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
                  ),
          ),
        ),
      ),
    );
  }

  String? validateEmail(String? formEmail) {
    if (formEmail == null || formEmail.isEmpty) {
      print('''E-mail adresin olmadan nasıl girmeyi düşünüyorsun?''');
      kullaniciAdi = 'E-mail adresi giriniz';
      setState(() {});
      return '';
    }
    String pattern = r'^(\w+[._-\w]+)@(hotmail.com|gmail.com|yahoo.com)$';

    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(formEmail)) {
      setState(() {});

      kullaniciAdi = ''' Email adresini kontrol edin''';
      return '';
    }

    return null;
  }
}

String? validatePassword(String? formPassword) {
  if (formPassword == null || formPassword.isEmpty)
    return 'Sence şifresiz olur mu?';

  String pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';

  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formPassword)) {
    return ''' En az sekiz karakter, bir harf ve bir sayı olacak''';
  }

  return null;
}
