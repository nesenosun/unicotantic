import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';

class ZamanDenemeler extends StatefulWidget {
  const ZamanDenemeler({super.key});

  @override
  State<ZamanDenemeler> createState() => _ZamanDenemelerState();
}

class _ZamanDenemelerState extends State<ZamanDenemeler> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  late Timestamp zaman;

  @override
  void initState() {
    super.initState();

    final timestamp =
        FirebaseFirestore.instance.collection('Kullanicilar').doc(kullanici.email).collection('oyun').doc('tarla');
    timestamp.get().then((snapshot) {
      zaman = snapshot.data()?['zaman'] as Timestamp;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = zaman.toDate();
    final formatZaman = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    print(zaman.toString());
    print(formatZaman.toString());

    return Scaffold(
      appBar: akisAppBar(),
      body: Center(
        child: Column(
          children: [
            Text(formatZaman.toString()),
            ElevatedButton(
                onPressed: () {
                  var ref = firestore.collection('Kullanicilar').doc(kullanici.email).collection('oyun').doc('tarla');
                  ref.update({'zaman': FieldValue.serverTimestamp()});

                  ref.get().then((snapshot) {
                    zaman = snapshot.data()?['zaman'];
                  });
                  setState(() {});
                },
                child: Text(' Update')),
          ],
        ),
      ),
    );
  }
}
