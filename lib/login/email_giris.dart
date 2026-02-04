import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grock/grock.dart';
import 'package:hive_flutter/adapters.dart';

import 'my_button.dart';
import 'sifremi_unuttum.dart';
import 'splash.dart';
import 'yeniKayitEkrani.dart';

class EmailGiris extends StatefulWidget {
  const EmailGiris({super.key});

  @override
  State<EmailGiris> createState() => _EmailGirisState();
}

class _EmailGirisState extends State<EmailGiris> {
  final puanSa = Hive.box('unicotantic');

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String errorMessage = '';

  Future<void> girisYap() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      debugPrint("Email/Password Sign-In starting for: ${_usernameController.text.trim()}");
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      )
          .then((userCredential) {
        debugPrint("Email/Password Sign-In successful!");
        //Get.off(YazilarAkisVeMetinGir());
        Get.to(Splash());
      });
    } on FirebaseAuthException catch (error) {
      debugPrint("FirebaseAuthException: ${error.code} - ${error.message}");
      Get.back(); // Loading dialogu kapat

      String message = 'Bir hata oluştu.';
      if (error.code == 'user-not-found') {
        message = 'Bu e-posta için kullanıcı bulunamadı.';
      } else if (error.code == 'wrong-password') {
        message = 'Bu kullanıcı için parola yanlış.';
      } else {
        message = error.message ?? 'Bilinmeyen bir hata.';
      }

      Grock.snackBar(
        title: 'Hata',
        description: message,
        position: SnackbarPosition.top,
      );
    } catch (e) {
      debugPrint("Generic Sign-In Error: $e");
      Get.back();
      Grock.snackBar(
        title: 'Hata',
        description: 'Beklenmedik bir sorun oluştu: $e',
        position: SnackbarPosition.top,
      );
    }
  }

  Future<void> googleGirisYap() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      debugPrint("Google Sign-In starting...");
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '1001866780856-59h73p7at795igq9lliu7ajdsloe5m6q.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("Google Sign-In cancelled by user.");
        Get.back();
        return;
      }

      debugPrint("Google User: ${googleUser.email}");
      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        debugPrint("Firebase Sign-In with credential starting...");
        await FirebaseAuth.instance.signInWithCredential(credential).then((v) {
          debugPrint("Firebase Sign-In successful!");
          Get.to(Splash());
        });
      } else {
        debugPrint("Google Auth is null!");
        Get.back(); // Dialogu kapat
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      Get.back(); // Dialogu kapat
      Grock.snackBar(
        title: 'Hata',
        description: 'Google ile giriş yapılırken bir hata oluştu: $e',
        position: SnackbarPosition.top,
      );
    }
  }

  @override
  void initState() {
    puanSa.put('uygulama25', 27);
    puanSa.put('uygulamaSurumu', 27);
    puanSa.put('yeniAyarlar', 'yeniAyarlar001');
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Form(
          key: _key,
          child: Center(
            child: Container(
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/images/gif/lemat.gif"), fit: BoxFit.cover),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 100,
                            child: GestureDetector(
                              onTap: () {
                                //Get.off(const ReklamAnaSayfa());
                              },
                              child: Image.asset(
                                "assets/images/png/akis.png",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text('Hoşgeldiniz',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 25,
                              color: Colors.white70,
                            )),

                        const SizedBox(height: 20),

                        // username textfield
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                          child: Card(
                            color: Colors.black54,
                            child: TextFormField(
                              controller: _usernameController,
                              obscureText: false,
                              validator: validateEmail,
                              style: const TextStyle(color: Colors.cyanAccent, fontSize: 16),
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
                                  borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.0),
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
                        Center(
                          child: Text(errorMessage),
                        ),

                        const SizedBox(height: 10),

                        // password textfield
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                          child: Card(
                            color: Colors.black54,
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              validator: validatePassword,
                              style: const TextStyle(color: Colors.cyanAccent, fontSize: 16),
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
                                  borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.0),
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

                        const SizedBox(height: 30),

                        // forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Get.to(YeniKayitEkrani());
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(18.0),
                                child: Text(
                                  'Kayıt Ol',
                                  style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            GestureDetector(
                              onTap: () async {
                                Get.to(SifremiUnuttum());
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(18.0),
                                child: Text(
                                  'Şifremi Unuttum',
                                  style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // sign in button
                        MyButton(
                          text: 'Bağlan',
                          onTap: girisYap,
                        ),

                        const SizedBox(height: 20),

                        // Google Giriş Butonu
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: GestureDetector(
                            onTap: googleGirisYap,
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/png/google.png",
                                    height: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Google ile Devam Et',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // or continue with
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Row(
                            children: const [
                              SizedBox(height: 10),
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
            ),
          ),
        ),
      ),
    );
  }
}

String? validateEmail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty) {
    return '''E-mail adresin olmadan nasıl girmeyi düşünüyorsun?''';
  }
  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail)) return '''Email adresini bi kontrol eder misin canım.''';

  return null;
}

String? validatePassword(String? formPassword) {
  if (formPassword == null || formPassword.isEmpty) return 'Sence şifresiz olur mu?';

  String pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';

  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formPassword)) {
    return '''
      En az sekiz karakter, en az bir harf ve bir sayı
      ''';
  }

  return null;
}
