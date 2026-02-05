import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

import '../Unic/fonksiyonlar/puan_controller.dart';
import '../models/post_model.dart';

class MetinGir extends StatefulWidget {
  final String? parentID;
  final String? rootID;

  const MetinGir({Key? key, this.parentID, this.rootID}) : super(key: key);

  @override
  State<MetinGir> createState() => _MetinGirState();
}

class _MetinGirState extends State<MetinGir> {
  final kullanici = FirebaseAuth.instance.currentUser!;
  late File yuklenecekDosya;
  late File yuklenecekgetThumbnailDosya;
  String? indirmeBaglantisi;
  String? indirmeBaglantisiThumbnail;

  final _firestore = FirebaseFirestore.instance;
  TextEditingController metinController = TextEditingController();
  TextEditingController baslikController = TextEditingController();
  final box = GetStorage();
  final controller = Get.put(PuanC());
  double gozetop = Get.height / 5;
  double gozeleft = Get.width / 4;
  GetStorage getbox = GetStorage();
  String alinanDosya = 'assets/images/png/dactylo.png';
  String alinanDosyaVideo = 'assets/images/png/dactylo.png';
  String galeri = '.....';

  galeridenYukle() async {
    if (getbox.read('postVideolinki').toString().length > 5) {
      Get.snackbar('Kısıtlama', 'Video seçiliyken fotoğraf ekleyemezsiniz.');
      return;
    }
    var alinan = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (alinan == null) return;

    File resimDosyasi = File(alinan.path);
    int boyut = await resimDosyasi.length();
    const maksimumBoyut = 4 * 1024 * 1024;

    if (boyut > maksimumBoyut) {
      setState(() {
        galeri = 'Dosya Boyutu Çok Büyük!';
      });
    } else {
      setState(() {
        yuklenecekDosya = resimDosyasi;
        galeri = 'Yükleniyor...';
      });

      Reference referansYol = FirebaseStorage.instance
          .ref()
          .child('postFotoları')
          .child(kullanici.email.toString())
          .child('${DateTime.now().microsecondsSinceEpoch}postFoto.gif');

      UploadTask yuklemeGorevi = referansYol.putFile(resimDosyasi);
      String url = await (await yuklemeGorevi).ref.getDownloadURL();

      setState(() {
        indirmeBaglantisi = url;
        getbox.write('postFotolinki', indirmeBaglantisi.toString());
        galeri = 'Yüklendi.. ileti girin.';
      });
    }
  }

  Future<void> metinEkle() async {
    String text = baslikController.text;
    String getfoto = getbox.read("postFotolinki") ?? 'bos';
    String getVideo = getbox.read("postVideolinki") ?? '';

    var dtNow = DateTime.now();
    var postID = _firestore.collection('postlar').doc().id;

    var mediaUrl =
        getVideo.length > 5 ? getVideo : (getfoto != 'bos' ? getfoto : null);
    var mediaType =
        getVideo.length > 5 ? 'video' : (getfoto != 'bos' ? 'image' : 'text');

    PostModel newPost = PostModel(
      postID: postID,
      authorID: kullanici.uid,
      text: text,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      createdAt: dtNow,
      parentID: widget.parentID,
      rootID: widget.rootID ?? postID,
      email: kullanici.email.toString(),
    );

    var postData = newPost.toMap();

    await FirebaseFirestore.instance
        .collection("postlar")
        .doc(postID)
        .set(postData);
  }

  Future<void> galeridenVideoYukle() async {
    if (getbox.read('postFotolinki') != 'bos') {
      Get.snackbar('Kısıtlama', 'Fotoğraf seçiliyken video ekleyemezsiniz.');
      return;
    }
    var alinan = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (alinan == null) return;

    setState(() {
      galeri = 'Video işleniyor...';
    });

    var compressVideoFilePath = await VideoCompress.compressVideo(alinan.path,
        quality: VideoQuality.LowQuality);
    var compressVideoFilePathFile = compressVideoFilePath!.file;
    var getThumbnail = await VideoCompress.getFileThumbnail(alinan.path);

    int yuklenecekDosyab = await compressVideoFilePathFile!.length();
    const maksimumBoyut = 40 * 1024 * 1024;

    if (yuklenecekDosyab > maksimumBoyut) {
      setState(() {
        galeri = 'Video Boyutu Çok Büyük!';
      });
    } else {
      var dtNow = DateTime.now().microsecondsSinceEpoch;

      Reference referansYol = FirebaseStorage.instance
          .ref()
          .child('postVideolari')
          .child(kullanici.email.toString())
          .child('${dtNow}postVideo.mp4');
      Reference referansYolFoto = FirebaseStorage.instance
          .ref()
          .child('postVideolari')
          .child(kullanici.email.toString())
          .child('${dtNow}postFoto.jpg');

      UploadTask yuklemeGorevi = referansYol.putFile(compressVideoFilePathFile);
      UploadTask yuklemeGoreviThumbnail =
          referansYolFoto.putFile(File(getThumbnail.path));

      String url = await (await yuklemeGorevi).ref.getDownloadURL();
      String urlyuklemeGoreviThumbnail =
          await (await yuklemeGoreviThumbnail).ref.getDownloadURL();

      setState(() {
        indirmeBaglantisi = url;
        indirmeBaglantisiThumbnail = urlyuklemeGoreviThumbnail;
        getbox.write('postVideolinki', indirmeBaglantisi.toString());
        getbox.write('getThumbnail', indirmeBaglantisiThumbnail.toString());
        galeri = 'Yüklendi....';
      });
    }
  }

  Future<dynamic> unicCikar() async {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);
    var secim = await icerik.get();
    Map<String, dynamic>? data = secim.data() as Map<String, dynamic>?;
    num unic = data?['unic'] ?? 0;

    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(kullanici.email)
        .update(unic >= 1 ? {"unic": FieldValue.increment(-1)} : {"unic": 0});
    return unic;
  }

  @override
  void initState() {
    getbox.write('postFotolinki', 'bos');
    getbox.write('postVideolinki', '');
    getbox.write('getThumbnail', '');
    controller.acilGoze = false.obs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference kullanicilar = _firestore.collection('Kullanicilar');
    var icerik = kullanicilar.doc(kullanici.email);

    return Positioned(
      top: gozetop,
      left: gozeleft,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            gozetop = max(-300, gozetop + details.delta.dy);
            gozeleft = max(-200, gozeleft + details.delta.dx);
          });
        },
        child: SizedBox(
          height: 300,
          width: 300,
          child: Obx(
            () => GestureDetector(
              onTap: () async {
                getbox.write('postFotolinki', 'bos');
                getbox.write('postVideolinki', '');
                var secim = await icerik.get();
                Map<String, dynamic>? data =
                    secim.data() as Map<String, dynamic>?;
                num unic = data?['unic'] ?? 0;

                if (unic <= 0) {
                  controller.acilGoze = false.obs;
                } else {
                  setState(() {
                    controller.acilGoze = true.obs;
                  });
                }
              },
              child: Wrap(children: [
                if (controller.acilGoze.value)
                  Center(
                    child: Column(
                      children: [
                        Center(
                          child: GestureDetector(
                              onTap: () async {
                                String getfoto =
                                    getbox.read("postFotolinki") ?? 'bos';
                                String getVideo =
                                    getbox.read("postVideolinki") ?? '';
                                bool hasMedia =
                                    getfoto != 'bos' || getVideo.length > 5;

                                if (baslikController.text.isNotEmpty ||
                                    hasMedia) {
                                  var secim = await icerik.get();
                                  Map<String, dynamic>? data =
                                      secim.data() as Map<String, dynamic>?;
                                  num unic = data?['unic'] ?? 0;

                                  if (unic > 0) {
                                    await unicCikar();
                                    await metinEkle();
                                    setState(() {
                                      galeri = '.....';
                                      getbox.write('postFotolinki', 'bos');
                                      getbox.write('postVideolinki', '');
                                      controller.acilGoze = false.obs;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    controller.acilGoze = false.obs;
                                  });
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                }
                                baslikController.clear();
                              },
                              child: SizedBox(
                                width: 150,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed:
                                          (getbox.read('postFotolinki') !=
                                                  'bos')
                                              ? null
                                              : galeridenVideoYukle,
                                      icon: Image.asset(
                                        'assets/images/png/camera.png',
                                        width: 25,
                                        color: (getbox.read('postFotolinki') !=
                                                'bos')
                                            ? Colors.grey
                                            : null,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: (getbox
                                                  .read('postVideolinki')
                                                  .toString()
                                                  .length >
                                              5)
                                          ? null
                                          : galeridenYukle,
                                      icon: Image.asset(
                                        'assets/images/png/gallery.png',
                                        width: 25,
                                        color: (getbox
                                                    .read('postVideolinki')
                                                    .toString()
                                                    .length >
                                                5)
                                            ? Colors.grey
                                            : null,
                                      ),
                                    ),
                                    Image.asset('assets/images/png/unic.png',
                                        width: 35),
                                  ],
                                ),
                              )),
                        ),
                        Card(
                          color: Colors.black87,
                          child: TextField(
                            controller: baslikController,
                            onSubmitted: (value) async {
                              String getfoto =
                                  getbox.read("postFotolinki") ?? 'bos';
                              String getVideo =
                                  getbox.read("postVideolinki") ?? '';
                              bool hasMedia =
                                  getfoto != 'bos' || getVideo.length > 5;

                              if (value.isNotEmpty || hasMedia) {
                                await metinEkle();
                                setState(() {
                                  galeri = '.....';
                                });
                              } else {
                                setState(() {
                                  controller.acilGoze = false.obs;
                                });
                              }
                            },
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: 440,
                            maxLines: 6,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              labelText: galeri,
                              labelStyle: const TextStyle(
                                  color: Colors.cyan, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!controller.acilGoze.value)
                  Center(
                    child: Card(
                      color: Colors.black45,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(alinanDosya,
                            height: 30, width: 50, fit: BoxFit.cover),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
