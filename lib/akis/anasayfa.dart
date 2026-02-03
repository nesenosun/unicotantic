import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:unicotantic/akis/feed.dart';
import 'package:url_launcher/url_launcher.dart';

class DoluAkisAnaSayfa extends StatefulWidget {
  const DoluAkisAnaSayfa({Key? key}) : super(key: key);

  @override
  State<DoluAkisAnaSayfa> createState() => _DoluAkisAnaSayfaState();
}

class _DoluAkisAnaSayfaState extends State<DoluAkisAnaSayfa> {
  final puanSa = Hive.box('unicotantic');

  double top = 50;
  double left = 30;
  double arabatop = 30;
  double arabaleft = 30;

  _launchGooglePlay() async {
    print('Dolu Akış AnaSayfa başladı');

    const url = 'https://play.google.com/store/apps/details?id=com.unicotantic.unicotantic';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Google Play Store açarken hata oluştu.';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String yeniAyarlar = puanSa.get('yeniAyarlar');

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: yeniAyarlar == 'yeniAyarlar001'
              ? FeedSayfasi()
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'Uygulamanın bu sürümü artık kullanılamaz, '
                            'lütfen aşağıdaki linkten Google Play ile güncelleyiniz!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              SystemNavigator.pop();

                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Çıkış Yap',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchGooglePlay();
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 300,
                                width: 200,
                                child: Image.asset(
                                  "assets/images/jpg/unicotantic_googleplay.jpg",
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _launchGooglePlay();
                                    //SystemNavigator.pop();

                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text(
                                      'Google Play',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

///
///
///
///
