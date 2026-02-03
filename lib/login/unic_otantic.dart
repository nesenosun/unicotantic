import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/akis/anasayfa.dart';

import '../Unic/fonksiyonlar/puan_controller.dart';

class UnicOtantic extends StatefulWidget {
  const UnicOtantic({super.key});

  @override
  State<UnicOtantic> createState() => _UnicOtanticState();
}

class _UnicOtanticState extends State<UnicOtantic> {
  final controller = Get.put(PuanC());
  final puanSa = Hive.box('unicotantic');
  GetStorage getbox = GetStorage();
  final kullanici = FirebaseAuth.instance.currentUser!;
  //final _firestore = FirebaseFirestore.instance;
  //final box = GetStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);

    return const Scaffold(
      body: DoluAkisAnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
