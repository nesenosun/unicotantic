import 'package:flutter/material.dart';

import '../../core/voice/widgets/voice_bottom_bar.dart';
import '../profile/site.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        Widget content = Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Arama', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
          ),
          bottomNavigationBar: isDesktop ? null : const VoiceBottomBar(currentTab: VoiceBottomBarTab.search),
          body: const Center(
            child: Text('Arama Sayfası Yakında!', style: TextStyle(color: Colors.grey)),
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
