// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'package:flutter/material.dart';
import 'package:unicotantic/core/utils/buildDefaultTextStyle.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoFotoGosterSayfasi extends StatefulWidget {
  String gelenVideolink;
  String gelenFotolink;

  VideoFotoGosterSayfasi(
      {required this.gelenVideolink, required this.gelenFotolink});

  @override
  State<VideoFotoGosterSayfasi> createState() => _VideoFotoGosterSayfasiState();
}

class _VideoFotoGosterSayfasiState extends State<VideoFotoGosterSayfasi>
    with WidgetsBindingObserver {
  late final VideoPlayerController controller;
  bool _isVisible = true;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller = VideoPlayerController.network(widget.gelenVideolink)
      ..initialize().then((_) {
        setState(() {
          if (_isVisible) controller.play();
        });
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      controller.pause();
    } else if (state == AppLifecycleState.resumed && _isVisible) {
      controller.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: widget.gelenVideolink != ''
            ? Center(
                child: widget.gelenFotolink != 'bos'
                    ? PageView(children: [
                        Center(
                          child: controller.value.isInitialized
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(18.0),
                                  child: ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxHeight: maxHeight),
                                    child: InteractiveViewer(
                                      transformationController:
                                          _transformationController,
                                      boundaryMargin: const EdgeInsets.all(0),
                                      minScale: 1.0,
                                      maxScale: 2.5,
                                      onInteractionEnd: (details) {
                                        _resetZoom();
                                      },
                                      child: VisibilityDetector(
                                        key: Key(
                                            'video_page_1_${widget.gelenVideolink}'),
                                        onVisibilityChanged: (info) {
                                          if (!mounted) return;
                                          setState(() {
                                            _isVisible =
                                                info.visibleFraction > 0.5;
                                            if (_isVisible) {
                                              controller.play();
                                            } else {
                                              controller.pause();
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: AspectRatio(
                                            aspectRatio:
                                                controller.value.aspectRatio,
                                            child: Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                VideoPlayer(controller),
                                                Positioned(
                                                  right: 12,
                                                  bottom: 12,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            controller.value
                                                                    .isPlaying
                                                                ? controller
                                                                    .pause()
                                                                : controller
                                                                    .play();
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.black45,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Image.asset(
                                                            controller.value
                                                                    .isPlaying
                                                                ? 'assets/images/png/pause.png'
                                                                : 'assets/images/png/play.png',
                                                            height: 30,
                                                            width: 30,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            controller.setVolume(
                                                                controller.value
                                                                            .volume ==
                                                                        0
                                                                    ? 1
                                                                    : 0);
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.black45,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Icon(
                                                            controller.value
                                                                        .volume ==
                                                                    0
                                                                ? Icons
                                                                    .volume_off
                                                                : Icons
                                                                    .volume_up,
                                                            color: Colors.white,
                                                            size: 30,
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
                                  ),
                                )
                              : Center(
                                  child: buildDefaultTextStyle(),
                                ),
                        ),
                        Center(
                            child: ClipRRect(
                          borderRadius: BorderRadius.circular(18.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: maxHeight),
                            child: InteractiveViewer(
                              transformationController:
                                  _transformationController,
                              boundaryMargin: const EdgeInsets.all(0),
                              minScale: 1.0,
                              maxScale: 2.5,
                              onInteractionEnd: (details) {
                                _resetZoom();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Image.network(
                                  widget.gelenFotolink,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        )),
                      ])
                    : Center(
                        child: controller.value.isInitialized
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18.0),
                                child: ConstrainedBox(
                                  constraints:
                                      BoxConstraints(maxHeight: maxHeight),
                                  child: InteractiveViewer(
                                    transformationController:
                                        _transformationController,
                                    boundaryMargin: const EdgeInsets.all(0),
                                    minScale: 1.0,
                                    maxScale: 2.5,
                                    onInteractionEnd: (details) {
                                      _resetZoom();
                                    },
                                    child: VisibilityDetector(
                                      key: Key(
                                          'video_page_2_${widget.gelenVideolink}'),
                                      onVisibilityChanged: (info) {
                                        if (!mounted) return;
                                        setState(() {
                                          _isVisible =
                                              info.visibleFraction > 0.5;
                                          if (_isVisible) {
                                            controller.play();
                                          } else {
                                            controller.pause();
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: AspectRatio(
                                          aspectRatio:
                                              controller.value.aspectRatio,
                                          child: Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              VideoPlayer(controller),
                                              Positioned(
                                                right: 12,
                                                bottom: 12,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          controller.value
                                                                  .isPlaying
                                                              ? controller
                                                                  .pause()
                                                              : controller
                                                                  .play();
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black45,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Image.asset(
                                                          controller.value
                                                                  .isPlaying
                                                              ? 'assets/images/png/pause.png'
                                                              : 'assets/images/png/play.png',
                                                          height: 30,
                                                          width: 30,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          controller.setVolume(
                                                              controller.value
                                                                          .volume ==
                                                                      0
                                                                  ? 1
                                                                  : 0);
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black45,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Icon(
                                                          controller.value
                                                                      .volume ==
                                                                  0
                                                              ? Icons.volume_off
                                                              : Icons.volume_up,
                                                          color: Colors.white,
                                                          size: 30,
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
                                ),
                              )
                            : Center(
                                child: buildDefaultTextStyle(),
                              ),
                      ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    boundaryMargin: const EdgeInsets.all(0),
                    minScale: 1.0,
                    maxScale: 2.5,
                    onInteractionEnd: (details) {
                      _resetZoom();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Image.network(
                        widget.gelenFotolink,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
