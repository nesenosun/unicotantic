import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:unicotantic/features/feed/anasayfa.dart';

import 'web_helper.dart' as web_helper;

class GoogleGiris extends StatefulWidget {
  const GoogleGiris({super.key});

  @override
  State<GoogleGiris> createState() => _GoogleGirisState();
}

class _GoogleGirisState extends State<GoogleGiris> {
  final puanSa = Hive.box('unicotantic');
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final List<String> _scopes = ['email', 'profile', 'openid'];

  @override
  void initState() {
    puanSa.put('uygulama25', 27);
    puanSa.put('uygulamaSurumu', 27);
    puanSa.put('yeniAyarlar', 'yeniAyarlar001');

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
      final googleAuth = await googleUser.authentication;

      // v7.x Web'de accessToken için yetki istemcisini kontrol ediyoruz.
      // promptIfInteraction: false ile ikinci pencere açılmadan deniyoruz.
      String? accessToken;
      final auth = await googleUser.authorizationClient.authorizationForScopes(_scopes);
      accessToken = auth?.accessToken;

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      await _createUserIfNotExists(userCredential.user!);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Anasayfa()),
          (_) => false,
        );
      }
    } catch (e) {
      debugPrint('Web Giriş Hatası: $e');
    }
  }

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) return null;

    try {
      await _googleSignIn.initialize();

      // v7.x'te signIn() yerine authenticate() kullanılır.
      // scopeHint vererek yetkilendirmenin de aynı pencerede yapılmasını rica ediyoruz.
      final googleUser = await _googleSignIn.authenticate(scopeHint: _scopes);

      final googleAuth = googleUser.authentication;

      // accessToken'ı sessizce (ikinci pencere açmadan) almaya çalışıyoruz.
      String? accessToken;
      final auth = await googleUser.authorizationClient.authorizationForScopes(_scopes);
      accessToken = auth?.accessToken;

      // Eğer accessToken hala yoksa ve Firebase için çok gerekliyse authorizeScopes denenebilir
      // ama bu kesinlikle ikinci bir pencere açacaktır. Genelde idToken yeterlidir.

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      await _createUserIfNotExists(userCredential.user!);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Anasayfa()),
          (_) => false,
        );
      }

      return userCredential.user;
    } catch (e) {
      debugPrint('Mobil Giriş Hatası: $e');
      return null;
    }
  }

  // ================================
  // USER BOOTSTRAP (TEK GERÇEK MERKEZ)
  // ================================

  Future<void> _createUserIfNotExists(User user) async {
    final firestore = FirebaseFirestore.instance;
    final uid = user.uid;
    final email = user.email ?? "";

    final userRef = firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();

    final legacyRef = firestore.collection('users').doc(email);
    final legacyDoc = await legacyRef.get();

    if (userDoc.exists) {
      await userRef.update({
        "lastLogin": FieldValue.serverTimestamp(),
      });
      return;
    }

    String name = user.displayName ?? "Unic Kullanıcısı";
    String photoUrl = user.photoURL ?? "";
    String bio = "";
    String usernameBase = user.email?.split('@')[0].replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '').toLowerCase() ?? "user";
    String username = usernameBase;

    if (legacyDoc.exists) {
      final legacyData = legacyDoc.data()!;
      bio = legacyData['bio'] ?? "";
      username = legacyData['username'] ?? username;
      photoUrl = legacyData['photoUrl'] ?? photoUrl;
      name = legacyData['name'] ?? name;
    }

    bool isUsernameTaken = true;
    int suffix = 1;
    while (isUsernameTaken) {
      final uDoc = await firestore.collection('usernames').doc(username).get();
      if (!uDoc.exists || uDoc.data()?['uid'] == uid) {
        isUsernameTaken = false;
      } else {
        username = "${usernameBase}_$suffix";
        suffix++;
      }
    }

    await firestore.collection('usernames').doc(username).set({'uid': uid});

    await userRef.set({
      'uid': uid,
      'username': username,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'followerCount': 0,
      'followingCount': 0,
      'postCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'unicBalance': 5000,
      "website": "...",
      "isVerified": false,
      "isBanned": false,
      "role": "user"
    });
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
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/png/akis.png", height: 100),
                  const SizedBox(height: 20),
                  Text(
                    'Hoşgeldiniz',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 25,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: kIsWeb
                        ? web_helper.renderGoogleButton()
                        : GestureDetector(
                            onTap: () => signInWithGoogle(),
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(10),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
