import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicotantic/Unic/fonksiyonlar/reklamAnasayfa.dart';
import 'package:unicotantic/login/splash.dart';

AppBar reklamBuildAppBar() {
  //Timer timer;

  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 70,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
        bottom: Radius.circular(20),
      ),
    ),
    actions: <Widget>[
      Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Card(
            color: Colors.black26,
            child: Center(
              child: Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Image.asset('assets/images/icon/icon256.png'),
                  //onTap: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          ),
        ),
      ),
      Expanded(
          flex: 2,
          child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Card(
                color: Colors.black26,
                child: GestureDetector(
                  onTap: () {
                    Get.to(const Splash());
                  },
                  onLongPress: () {
                    Get.to(const ReklamAnaSayfa());
                  },
                  child: Image.asset('assets/images/png/akis.png'),
                ),
              ))),
      Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Card(
            color: Colors.black26,
            child: GestureDetector(
              onTap: () {
                Get.off(const ReklamAnaSayfa());
              },
              child: Center(
                child: Image.asset('assets/images/png/anasayfa.png'),
              ),
            ),
          ),
        ),
      ),
    ],
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  );
}
