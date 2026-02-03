import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'email_giris.dart';
import 'my_button.dart';
import 'yeniKayitEkrani.dart';

class SifremiUnuttum extends StatefulWidget {
  const SifremiUnuttum({super.key});

  @override
  State<SifremiUnuttum> createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  Future sifreYolla() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const EmailGiris()),
                  (Route<dynamic> route) => false);
            },
            child: const AlertDialog(
              content: Text(
                  "Şifre sıfırlamabağlantısı email adresinize gönderildi."),
            ),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);

      showDialog(
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const EmailGiris()),
                  (Route<dynamic> route) => false);
            },
            child: const AlertDialog(
              content: Text("Böyle bir kullanıcımız yok!"),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/gif/lemat.gif"),
                fit: BoxFit.cover),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 100,
                        child: GestureDetector(
                          onTap: () {
                            //Get.off(const ReklamAnaSayfa());
                          },
                          child: Image.asset(
                            "assets/images/png/akis.png",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text('Akış',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 25,
                          color: Colors.white70,
                        )),

                    const SizedBox(height: 30),

                    // username textfield
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 30),
                      child: Card(
                        color: Colors.black54,
                        child: TextFormField(
                          controller: _emailController,
                          obscureText: false,
                          style: const TextStyle(
                              color: Colors.cyanAccent, fontSize: 16),
                          decoration: InputDecoration(
                            focusColor: Colors.black54,
                            //add prefix icon
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.cyanAccent,
                              size: 30,
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.cyanAccent, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            fillColor: Colors.black54,

                            hintText: "Email",

                            //make hint text
                            hintStyle: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 16,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),

                            labelText: 'Email',
                            //lable style
                            labelStyle: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 16,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // password textfield

                    const SizedBox(height: 30),

                    // forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const YeniKayitEkrani()),
                              (Route<dynamic> route) => false),
                          child: const Padding(
                            padding: EdgeInsets.all(18.0),
                            child: Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EmailGiris()),
                              (Route<dynamic> route) => false),
                          child: const Padding(
                            padding: EdgeInsets.all(18.0),
                            child: Text(
                              'Hatırladım',
                              style: TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // sign in button
                    MyButton(
                      text: 'Gönder',
                      onTap: sifreYolla,
                    ),

                    const SizedBox(height: 20),

                    // or continue with
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: const [
                          SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // apple + google sign in

                    const SizedBox(height: 1),

                    // not a member? register now
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
