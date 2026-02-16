import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart'; // kIsWeb için

class FeedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const FeedVideoPlayer({super.key, required this.videoUrl});

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isVisible = true;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (kIsWeb) {
        // Web için doğrudan URL kullan (CacheManager web'de CORS hatası verebilir)
        _controller =
            VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        // Mobil için CacheManager kullan
        final file = await DefaultCacheManager().getSingleFile(widget.videoUrl);
        _controller = VideoPlayerController.file(file);
      }

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _controller.setVolume(0); // Sessiz
          _controller.setLooping(true); // Döngü
          if (_isVisible) _controller.play(); // Sadece görünürse oynat
        });
      }
    } catch (e) {
      debugPrint("Video yükleme hatası: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller.pause();
    } else if (state == AppLifecycleState.resumed && _isVisible) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: VisibilityDetector(
        key: Key(widget.videoUrl),
        onVisibilityChanged: (info) {
          if (!mounted) return;
          setState(() {
            _isVisible = info.visibleFraction > 0.5;
            if (_isVisible && _isInitialized) {
              _controller.play();
            } else {
              _controller.pause();
            }
          });
        },
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(0),
          minScale: 1.0,
          maxScale: 2.5,
          onInteractionEnd: (details) {
            _resetZoom();
          },
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                VideoPlayer(_controller),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Play/Pause Butonu
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            _controller.value.isPlaying
                                ? 'assets/images/png/pause.png'
                                : 'assets/images/png/play.png',
                            height: 24,
                            width: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Ses Butonu
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller.setVolume(
                                _controller.value.volume == 0 ? 1 : 0);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _controller.value.volume == 0
                                ? Icons.volume_off
                                : Icons.volume_up,
                            color: Colors.white,
                            size: 24,
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
    );
  }
}
