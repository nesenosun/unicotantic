import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/voice/widgets/voice_bottom_bar.dart';
import '../auth/splash.dart';
import 'admin_sayfasi.dart';
import 'site.dart';

class Ayarlar extends StatefulWidget {
  const Ayarlar({super.key});

  @override
  State<Ayarlar> createState() => _AyarlarState();
}

class _AyarlarState extends State<Ayarlar> {
  final User kullanici = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  String? _currentPhotoUrl;
  String? _oldUsername;
  bool _isSaving = false;
  bool _isCheckingUsername = false;
  String? _usernameError;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await _firestore.collection('users').doc(kullanici.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? kullanici.displayName ?? "";
      _usernameController.text = data['username'] ?? "";
      _oldUsername = data['username'];
      _currentPhotoUrl = data['photoUrl'] ?? kullanici.photoURL;
      if (mounted) setState(() {});
    }
  }

  Future<void> _checkUsername(String val) async {
    if (val.isEmpty) {
      setState(() => _usernameError = "Kullanıcı adı boş olamaz.");
      return;
    }
    if (val == _oldUsername) {
      setState(() => _usernameError = null);
      return;
    }
    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(val)) {
      setState(() => _usernameError = "Sadece küçük harf, rakam ve alt çizgi (3-20 krkt).");
      return;
    }

    setState(() => _isCheckingUsername = true);
    final doc = await _firestore.collection('usernames').doc(val).get();
    setState(() {
      _isCheckingUsername = false;
      if (doc.exists) {
        _usernameError = "Bu kullanıcı adı zaten alınmış.";
      } else {
        _usernameError = null;
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        await _uploadAndApplyPhoto(pickedFile);
      } else {
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  Future<void> _uploadAndApplyPhoto(XFile pickedFile) async {
    setState(() => _isSaving = true);
    try {
      String fileName = 'profile_${kullanici.uid}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('profilePhotos').child(kullanici.uid).child(fileName);

      if (kIsWeb) {
        await ref.putData(await pickedFile.readAsBytes());
      } else {
        await ref.putFile(File(pickedFile.path));
      }

      String url = await ref.getDownloadURL();
      await kullanici.updatePhotoURL(url);
      await _firestore.collection('users').doc(kullanici.uid).update({'photoUrl': url});

      setState(() {
        _currentPhotoUrl = url;
        _isSaving = false;
      });
      Get.snackbar('Başarılı', 'Profil fotoğrafı güncellendi.');
    } catch (e) {
      setState(() => _isSaving = false);
      Get.snackbar('Hata', 'Fotoğraf yüklenemedi: $e');
    }
  }

  Future<void> _saveProfile() async {
    final newUsername = _usernameController.text.trim().toLowerCase();
    final newName = _nameController.text.trim();

    if (newName.isEmpty || newUsername.isEmpty) {
      Get.snackbar('Hata', 'İsim ve kullanıcı adı boş olamaz.');
      return;
    }
    if (_usernameError != null) {
      Get.snackbar('Hata', 'Lütfen geçerli bir kullanıcı adı seçin.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (newUsername != _oldUsername) {
        await _firestore.collection('usernames').doc(newUsername).set({'uid': kullanici.uid});
        if (_oldUsername != null && _oldUsername!.isNotEmpty) {
          await _firestore.collection('usernames').doc(_oldUsername).delete();
        }
      }

      if (!kIsWeb && _imageFile != null) {
        String fileName = 'profile_${kullanici.uid}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child('profilePhotos').child(kullanici.uid).child(fileName);
        await ref.putFile(_imageFile!);
        _currentPhotoUrl = await ref.getDownloadURL();
        await kullanici.updatePhotoURL(_currentPhotoUrl);
      }

      await kullanici.updateDisplayName(newName);

      await _firestore.collection('users').doc(kullanici.uid).update({
        'name': newName,
        'username': newUsername,
        'photoUrl': _currentPhotoUrl,
      });

      _oldUsername = newUsername;
      Get.snackbar('Başarılı', 'Profil bilgileriniz kaydedildi.');
    } catch (e) {
      Get.snackbar('Hata', 'Güncelleme hatası: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const Splash());
    } catch (e) {
      Get.snackbar('Hata', 'Çıkış yapılamadı.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        Widget content = Scaffold(
          backgroundColor: Colors.black,
          drawer: isDesktop ? null : Site(),
          bottomNavigationBar: isDesktop ? null : VoiceBottomBar(currentTab: VoiceBottomBarTab.profile),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.cyanAccent, width: 3),
                          boxShadow: [
                            BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                          ],
                        ),
                        child: _imageFile != null
                            ? CircleAvatar(backgroundImage: FileImage(_imageFile!))
                            : (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty
                                ? CircleAvatar(backgroundImage: NetworkImage(_currentPhotoUrl!))
                                : const Icon(Iconsax.user, color: Colors.white, size: 60)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle),
                            child: const Icon(Iconsax.camera, color: Colors.black, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('İsim Soyisim', Iconsax.user),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: _checkUsername,
                  decoration: _inputDecoration(
                    'Kullanıcı Adı (@)',
                    Iconsax.tag,
                    suffix: _isCheckingUsername
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent))
                        : (_usernameError == null && _usernameController.text.isNotEmpty
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null),
                    errorText: _usernameError,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: TextEditingController(text: kullanici.email),
                  readOnly: true,
                  style: const TextStyle(color: Colors.grey),
                  decoration: _inputDecoration('E-posta', Iconsax.sms).copyWith(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white10)),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSaving || _usernameError != null ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Değişiklikleri Kaydet',
                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
                const Divider(color: Colors.white10),
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('users').doc(kullanici.uid).snapshots(),
                  builder: (context, snapshot) {
                    bool profilGizli = false;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      profilGizli = (snapshot.data!.data() as Map<String, dynamic>)['profilGizli'] ?? false;
                    }
                    return Column(
                      children: [
                        _buildSettingsTile(
                          title: 'Profili Gizle',
                          subtitle: profilGizli ? 'Profiliniz şu an gizli' : 'Profiliniz herkese açık',
                          icon: Iconsax.lock,
                          trailing: Switch(
                            value: profilGizli,
                            onChanged: (val) {
                              _firestore.collection('users').doc(kullanici.uid).update({'profilGizli': val});
                            },
                            activeColor: Colors.cyanAccent,
                          ),
                        ),
                        if (kullanici.email == 'nesenosun@gmail.com')
                          _buildSettingsTile(
                            title: 'Admin Paneli',
                            icon: Iconsax.setting_2,
                            color: Colors.redAccent,
                            onTap: () => Get.to(() => const AdminSayfasi()),
                          ),
                        _buildSettingsTile(
                          title: 'Oturumu Kapat',
                          icon: Iconsax.logout,
                          color: Colors.redAccent,
                          onTap: _signOut,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
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

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix, String? errorText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.cyanAccent),
      prefixIcon: Icon(icon, color: Colors.cyanAccent),
      suffixIcon: suffix,
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.redAccent),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyanAccent)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
    );
  }

  Widget _buildSettingsTile(
      {required String title,
      String? subtitle,
      required IconData icon,
      Widget? trailing,
      Color color = Colors.white70,
      VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)) : null,
      trailing: trailing ?? const Icon(Iconsax.arrow_right_3, color: Colors.white24, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }
}
