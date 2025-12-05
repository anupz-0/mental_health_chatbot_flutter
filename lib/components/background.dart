import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.8, -0.8), // diagonal start from top-left
          radius: 1.5,
          colors: [
            Color(0xFFE9E9E9), // 16%
            Color(0xFFD8C7FA), // 33%
            Color(0xFFCEB8F8), // 49%
            Color(0xFFB999F4), // 65%
            Color(0xFFC2A7F6), // 81%
            Color(0xFFAF8CF2), // 98%
          ],
          stops: [
            0.0,
            0.25,
            0.5,
            0.7,
            0.85,
            1.0,
          ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
