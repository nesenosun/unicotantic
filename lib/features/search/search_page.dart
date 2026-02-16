import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/profilResmiGetir.dart';
import '../../core/voice/widgets/voice_bottom_bar.dart';
import '../profile/kullanici_profili.dart';
import '../profile/site.dart';
import '../profile/ziyaretci.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  List<DocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    // Türkçe karakter uyumlu arama için \uf8ff kullanımı
    // Hem username hem de name alanında arama yapıyoruz
    Future.wait([
      _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: value)
          .where('username', isLessThan: value + '\uf8ff')
          .limit(20)
          .get(),
      _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: value)
          .where('name', isLessThan: value + '\uf8ff')
          .limit(20)
          .get(),
    ]).then((results) {
      if (mounted) {
        // İki sorgu sonucunu birleştirip ID'ye göre tekilleştiriyoruz
        final allDocs = [...results[0].docs, ...results[1].docs];
        final uniqueDocsMap = {for (var doc in allDocs) doc.id: doc};

        setState(() {
          _searchResults = uniqueDocsMap.values.toList();
          _isLoading = false;
        });
      }
    }).catchError((error) {
      print("Arama hatası: $error");
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        Widget content = Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Kullanıcı Ara (Kullanıcı Adı)',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                icon:
                    const Icon(Iconsax.search_normal, color: Colors.cyanAccent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          bottomNavigationBar: isDesktop
              ? null
              : const VoiceBottomBar(currentTab: VoiceBottomBarTab.search),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.cyanAccent))
              : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.search_status,
                              size: 64, color: Colors.grey[800]),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Aramak istediğiniz kullanıcı adını yazın'
                                : 'Kullanıcı bulunamadı',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        var doc = _searchResults[index];
                        var data = doc.data() as Map<String, dynamic>;
                        String uid = doc.id;
                        String username = data['username'] ?? '';
                        String name = data['name'] ?? data['displayName'] ?? '';

                        return ListTile(
                          onTap: () {
                            if (currentUser != null &&
                                currentUser!.uid == uid) {
                              Get.to(() => const KullaniciProfili());
                            } else {
                              Get.to(() => Ziyaretci(gelenKullaniciEmail: uid));
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[900],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: profilResmiGetir(uid),
                            ),
                          ),
                          title: Text(name.isNotEmpty ? name : 'Kullanıcı',
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text("@$username",
                              style: const TextStyle(color: Colors.cyanAccent)),
                          trailing: const Icon(Iconsax.arrow_right_3,
                              color: Colors.grey, size: 16),
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
                        left: BorderSide(
                            color: Colors.white.withOpacity(0.05), width: 1),
                        right: BorderSide(
                            color: Colors.white.withOpacity(0.05), width: 1),
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
