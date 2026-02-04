import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../akis/feed_video_player.dart';

class FullScreenVideoPlayer extends StatelessWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: FeedVideoPlayer(videoUrl: videoUrl),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Iconsax.arrow_left, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
