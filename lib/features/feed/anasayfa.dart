import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:unicotantic/features/feed/akis.dart';
import 'package:url_launcher/url_launcher.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({Key? key}) : super(key: key);

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  final puanSa = Hive.box('unicotantic');

  Future<void> _launchGooglePlay() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.unicotantic.unicotantic';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Google Play Store açarken hata oluştu.';
    }
  }

  @override
  Widget build(BuildContext context) {
    String yeniAyarlar = puanSa.get('yeniAyarlar') ?? '';

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: yeniAyarlar == 'yeniAyarlar001'
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return const Akis();
                    } else {
                      return const Akis();
                    }
                  },
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(5.0),
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
                            onPressed: () => SystemNavigator.pop(),
                            child: const Text('Çıkış Yap'),
                          ),
                        ),
                        InkWell(
                          onTap: _launchGooglePlay,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: Image.asset(
                                    "assets/images/jpg/unicotantic_googleplay.jpg"),
                              ),
                              ElevatedButton(
                                onPressed: _launchGooglePlay,
                                child: const Text('Google Play'),
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
