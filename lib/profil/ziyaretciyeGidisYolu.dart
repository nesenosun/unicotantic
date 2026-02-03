// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/Unic/doluAkis/doluAkisAppBar.dart';
import 'package:unicotantic/profil/BenDrawer.dart';
import 'package:unicotantic/profil/yeniZiyaretciProfil.dart';

class ZiyaretciProfilAkiseGidis extends StatefulWidget {
  String gelenKullaniciEmail;

  ZiyaretciProfilAkiseGidis({required this.gelenKullaniciEmail});

  @override
  State<ZiyaretciProfilAkiseGidis> createState() => _ZiyaretciProfilAkiseGidisState();
}

class _ZiyaretciProfilAkiseGidisState extends State<ZiyaretciProfilAkiseGidis> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(microseconds: 100), () {
      Get.off(YeniZiyaretciProfil(
        gelenKullaniciEmail: widget.gelenKullaniciEmail,
      ));

      // if (puanSa.get('email') == 0) {
      //   Get.to(ZiyaretciProfilAkis(
      //     gelenKullaniciEmail: widget.gelenKullaniciEmail,
      //   ));
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: akisAppBar(),
        drawer: const BenDrawer(),
        body: Container(),
      ),
    );
  }

  ///
}
