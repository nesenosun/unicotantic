import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

DefaultTextStyle buildDefaultTextStyle() {
  return DefaultTextStyle(
    textAlign: TextAlign.center,
    style: const TextStyle(
        backgroundColor: Colors.black54,
        color: Colors.greenAccent,
        fontSize: 20.0,
        fontFamily: 'Chivo',
        fontWeight: FontWeight.bold),
    child: AnimatedTextKit(
      pause: const Duration(seconds: 3),
      stopPauseOnTap: true,
      isRepeatingAnimation: false,
      animatedTexts: [
        TypewriterAnimatedText(
          curve: Curves.decelerate,
          "..........",
          textAlign: TextAlign.center,
          speed: const Duration(milliseconds: 200),
        ),
      ],
    ),
  );
}
