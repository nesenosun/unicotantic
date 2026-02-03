// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:unicotantic/Unic/fonksiyonlar/buildDefaultTextStyle.dart';
import 'package:video_player/video_player.dart';

class VideoFotoGosterSayfasi extends StatefulWidget {
  String gelenVideolink;
  String gelenFotolink;

  VideoFotoGosterSayfasi({required this.gelenVideolink, required this.gelenFotolink});

  @override
  State<VideoFotoGosterSayfasi> createState() => _VideoFotoGosterSayfasiState();
}

class _VideoFotoGosterSayfasiState extends State<VideoFotoGosterSayfasi> {
  late final VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.network(widget.gelenVideolink)
      ..initialize().then((_) {
        setState(() {
          controller.play();
        });
      });
    //controller.play();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    controller.pause();
    //controller.play();
  }

  @override
  Widget build(BuildContext context) {
    bool cal = false;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: widget.gelenVideolink != ''
            ? Center(
                child: widget.gelenFotolink != 'bos'
                    ? PageView(children: [
                        Center(
                          child: controller.value.isInitialized
                              ? Container(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18.0),
                                      topRight: Radius.circular(18.0),
                                      bottomRight: Radius.circular(18.0),
                                      bottomLeft: Radius.circular(18.0),
                                    ),
                                    child: PinchZoom(
                                      maxScale: 2.5,
                                      onZoomStart: () {},
                                      onZoomEnd: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: AspectRatio(
                                          aspectRatio: controller.value.aspectRatio,
                                          child: Stack(
                                            //fit: StackFit.expand,
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              VideoPlayer(controller),
                                              PinchZoom(
                                                maxScale: 2.5,
                                                onZoomStart: () {},
                                                onZoomEnd: () {},
                                                child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (cal == true) {
                                                          controller.play();
                                                          cal = false;
                                                        } else {
                                                          controller.pause();
                                                          cal = true;
                                                        }
                                                      },
                                                      child: SizedBox(
                                                          height: 40, child: Image.asset('assets/images/png/play.png')),
                                                    )),
                                              )
                                            ],
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
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0),
                            bottomRight: Radius.circular(18.0),
                            bottomLeft: Radius.circular(18.0),
                          ),
                          child: PinchZoom(
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Image.network(
                                widget.gelenFotolink,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        )),
                      ])
                    : Center(
                        child: controller.value.isInitialized
                            ? Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(18.0),
                                    topRight: Radius.circular(18.0),
                                    bottomRight: Radius.circular(18.0),
                                    bottomLeft: Radius.circular(18.0),
                                  ),
                                  child: PinchZoom(
                                    maxScale: 2.5,
                                    onZoomStart: () {},
                                    onZoomEnd: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: AspectRatio(
                                        aspectRatio: controller.value.aspectRatio,
                                        child: Stack(
                                          //fit: StackFit.expand,
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            VideoPlayer(controller),
                                            Padding(
                                                padding: const EdgeInsets.all(3.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (cal == true) {
                                                      controller.play();
                                                      cal = false;
                                                    } else {
                                                      controller.pause();
                                                      cal = true;
                                                    }
                                                  },
                                                  child: SizedBox(
                                                      height: 40, child: Image.asset('assets/images/png/play.png')),
                                                ))
                                          ],
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
                child: PinchZoom(
                maxScale: 2.5,
                onZoomStart: () {},
                onZoomEnd: () {},
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Image.network(
                    widget.gelenFotolink,
                    fit: BoxFit.fill,
                  ),
                ),
              )),
      ),
    );
  }
}
