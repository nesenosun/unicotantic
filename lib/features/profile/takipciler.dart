import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/utils/profilResmiGetir.dart';
import 'site.dart';
import 'ziyaretci.dart';

class TakipcilerPage extends StatefulWidget {
  const TakipcilerPage({super.key});

  @override
  State<TakipcilerPage> createState() => _TakipcilerPageState();
}

class _TakipcilerPageState extends State<TakipcilerPage> {
  User? get currentUser => FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        Widget content = Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Takipçiler', style: TextStyle(color: Colors.white, fontSize: 18)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('followers').doc(currentUser!.uid).collection('userFollowers').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return const Center(child: Text('Hata oluştu', style: TextStyle(color: Colors.white)));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.profile_2user, size: 64, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      Text('Henüz takipçin bulunmuyor', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  String followerId = doc.id;

                  return ListTile(
                    onTap: () => Get.to(() => Ziyaretci(gelenKullaniciEmail: followerId)),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: profilResmiGetir(followerId),
                      ),
                    ),
                    title: profilIsmiGetir(followerId),
                    subtitle: const Text('Seni takip ediyor', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: const Icon(Iconsax.arrow_right_3, color: Colors.grey, size: 18),
                  );
                },
              );
            },
          ),
        );

        if (isDesktop) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Row(
              children: [
                const Expanded(flex: 1, child: Site()),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
                        right: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
                      ),
                    ),
                    child: content,
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox()),
              ],
            ),
          );
        }

        return content;
      },
    );
  }
}
