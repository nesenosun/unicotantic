import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

Widget buildDefaultTextStyle() {
  return Center(
    child: Container(
      color: Colors.black,
      child: DefaultTextStyle(
        textAlign: TextAlign.center,
        style: const TextStyle(
            backgroundColor: Colors.transparent,
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
      ),
    ),
  );
}
