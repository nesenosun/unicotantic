import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/features/profile/site.dart';

class ReklamAnaSayfa extends StatefulWidget {
  const ReklamAnaSayfa({super.key});

  @override
  State<ReklamAnaSayfa> createState() => _ReklamAnaSayfaState();
}

class _ReklamAnaSayfaState extends State<ReklamAnaSayfa> {
  //final kullanici = FirebaseAuth.instance.currentUser!;

  final puanSa = Hive.box('unicotantic');

  Future<void> saveTokenToFirestore() async {
    final String? token =
        await getTokenFromSomewhere(); // Burada cihazdan tokenı alma kodunu çağırman gerekiyor
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('uyeOlmayanToken')
          .doc(token)
          .set({'token': token}, SetOptions(merge: true));
    }
  }

  Future<String?> getTokenFromSomewhere() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Firebase Messaging token'ı al
    String? token = await messaging.getToken();

    // Firebase Messaging token'ı varsa, geri dön
    if (token != null) {
      return token;
    }
    print('token : ' + token!);

    // Firebase Messaging token'ı yoksa, hata mesajı göster ve null geri dön
    print('Firebase Messaging tokenı alınamadı');
    return null;
  }

  @override
  initState() {
    super.initState();

    saveTokenToFirestore();
    //reklam();
  }

  @override
  Widget build(BuildContext context) {
    print('uygulamaSurumu: ' +
        puanSa.get('uygulamaSurumu',
            defaultValue: 'uygulama surumu yuklenmedi'));
    return puanSa.get('uygulamaSurumu') == 'bir'
        ? SafeArea(
            child: Scaffold(
              drawer: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Site();
                  } else {
                    return const Center();
                  }
                },
              ),
              //backgroundColor: Colors.blueGrey,
              body: Column(
                children: [
                  Expanded(
                    child: Card(
                        color: Colors.transparent,
                        child: SizedBox(
                          height: 50,
                          width: 50,
                        )),
                  ),
                ],
              ),
            ),
          )
        : SafeArea(
            child: Scaffold(
              body: Center(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Uygulamanın yeni sürümü yayınlandı... Lütfen onu indiriniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () => Get.to(const ReklamAnaSayfa()),
                      child: Text('Anasayfa'))
                ],
              )),
            ),
          );
  }
}
