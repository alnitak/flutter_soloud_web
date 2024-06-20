import 'package:flutter/material.dart';
import 'package:flutter_soloud/src/bindings/audio_data.dart';
import 'package:flutter_soloud/src/bindings/audio_data_extensions.dart';

/// Draw the audio wave data
///
class BarsWaveWidget extends StatelessWidget {
  const BarsWaveWidget({
    required this.audioData,
    required this.width,
    required this.height,
    super.key,
  });

  final AudioData audioData;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (audioData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColoredBox(
          color: Colors.black,
          child: RepaintBoundary(
            child: ClipRRect(
              child: CustomPaint(
                size: Size(width, height),
                painter: WavePainter(audioData: audioData),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter to draw the wave in a circle
///
class WavePainter extends CustomPainter {
  const WavePainter({
    required this.audioData,
  });
  final AudioData audioData;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / 256;
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = barWidth * 0.8
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 256; i++) {
      late final double barHeight;
      try {
        barHeight = size.height * audioData.get1D(SampleOffset(i+256));
      } on Exception {
        barHeight = 0;
      }
      canvas.drawRect(
        Rect.fromLTWH(
          barWidth * i,
          (size.height - barHeight) / 2,
          barWidth,
          barHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
