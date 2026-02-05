import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'web_helper.dart' as web_helper;
import 'package:hive_flutter/adapters.dart';
import 'package:unicotantic/akis/anasayfa.dart';

class EmailGiris extends StatefulWidget {
  const EmailGiris.GoogleGiris({super.key});

  @override
  State<EmailGiris> createState() => _EmailGirisState();
}

class _EmailGirisState extends State<EmailGiris> {
  final puanSa = Hive.box('unicotantic');
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  void initState() {
    puanSa.put('uygulama25', 27);
    puanSa.put('uygulamaSurumu', 27);
    puanSa.put('yeniAyarlar', 'yeniAyarlar001');

    // Web'de giriş durumunu dinle
    if (kIsWeb) {
      _googleSignIn.authenticationEvents.listen((event) async {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          await _handleFirebaseSignIn(event.user);
        }
      });
      _googleSignIn.initialize();
    }

    super.initState();
  }

  Future<void> _handleFirebaseSignIn(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Access token'ı yetkilendirme istemcisi üzerinden alıyoruz
      final authorization =
          await _googleSignIn.authorizationClient.authorizeScopes([
        'email',
        'profile',
        'openid',
      ]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .set({
            'id': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Ana uygulama için Kullanicilar koleksiyonuna da kaydet (E-posta ID ile)
        final kullaniciDoc = await FirebaseFirestore.instance
            .collection('Kullanicilar')
            .doc(user.email)
            .get();

        if (!kullaniciDoc.exists) {
          await FirebaseFirestore.instance
              .collection('Kullanicilar')
              .doc(user.email)
              .set({
            'email': user.email,
            'isim': user.displayName ?? user.email?.split('@')[0],
            'id': user.uid,
            'uid': user.uid,
            'kayit tarihi': FieldValue.serverTimestamp(),
            'unic': 100, // Varsayılan başlangıç puanı
            'postSayisi': 0,
            'arkadaslar': [],
            'engelledim': [],
            'engelleyenler': [],
            'begen': [],
            'begenMe': [],
            'profilresmilinki': user.photoURL ?? '',
            'profilGizli': false,
            'hakkinda': 'Merhaba! Ben de buradayım.',
          });
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DoluAkisAnaSayfa()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('Firebase Giriş Hatası: $e');
    }
  }

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web'de renderButton kullanıldığı için bu fonksiyon manuel tetiklenmemeli
      return null;
    }

    try {
      // Google Giriş nesnesini al ve başlat
      // Not: v7.x'te GoogleSignIn bir singleton'dır ve initialize() edilmelidir.
      await _googleSignIn.initialize();

      // Google Giriş işlemini başlat (v7.x'te authenticate() kullanılır)
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      // Kimlik doğrulama detaylarını al (v7.x'te authentication property'dir)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Access token'ı yetkilendirme istemcisi üzerinden alıyoruz (v7.x'te yetkilendirme ayrı bir adımdır)
      final authorization =
          await _googleSignIn.authorizationClient.authorizeScopes([
        'email',
        'profile',
        'openid',
      ]);

      // Firebase kimlik bilgilerini oluştur
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase ile giriş yap
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // İlk defa giriş yapıp yapmadığını kontrol et ve Users koleksiyonuna kaydet
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .set({
            'id': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Ana uygulama için Kullanicilar koleksiyonuna da kaydet (E-posta ID ile)
        final kullaniciDoc = await FirebaseFirestore.instance
            .collection('Kullanicilar')
            .doc(user.email)
            .get();

        if (!kullaniciDoc.exists) {
          await FirebaseFirestore.instance
              .collection('Kullanicilar')
              .doc(user.email)
              .set({
            'email': user.email,
            'isim': user.displayName ?? user.email?.split('@')[0],
            'id': user.uid,
            'uid': user.uid,
            'kayit tarihi': FieldValue.serverTimestamp(),
            'unic': 100, // Varsayılan başlangıç puanı
            'postSayisi': 0,
            'arkadaslar': [],
            'engelledim': [],
            'engelleyenler': [],
            'begen': [],
            'begenMe': [],
            'profilresmilinki': user.photoURL ?? '',
            'profilGizli': false,
            'hakkinda': 'Merhaba! Ben de buradayım.',
          });
        }

        // Ana sayfaya yönlendir
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DoluAkisAnaSayfa()),
            (route) => false,
          );
        }
      }

      return user;
    } catch (e) {
      debugPrint('Google Giriş Hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş yapılırken bir hata oluştu: $e')),
        );
      }
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(
          child: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/gif/lemat.gif"),
                  fit: BoxFit.cover),
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

                      const SizedBox(height: 20),

                      // Google Giriş Butonu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: kIsWeb
                            ? Container(
                                alignment: Alignment.center,
                                child: web_helper.renderGoogleButton(),
                              )
                            : GestureDetector(
                                onTap: () => signInWithGoogle(),
                                child: Container(
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
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
    );
  }
}
