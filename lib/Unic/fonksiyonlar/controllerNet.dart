import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ControllerNet extends GetxController {
  final kullanici = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  final puanSa = Hive.box('unicotantic');
}
