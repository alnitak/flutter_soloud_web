import 'package:flutter/material.dart';
import 'package:flutter_soloud/src/bindings/ffi_data.dart';

/// Draw the audio FFT data
///
class BarsFftWidget extends StatelessWidget {
  const BarsFftWidget({
    required this.audioData,
    required this.minFreq,
    required this.maxFreq,
    required this.width,
    required this.height,
    super.key,
  });

  final FfiData audioData;
  final int minFreq;
  final int maxFreq;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (audioData.isEmpty2D) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColoredBox(
          color: Colors.black,
          child: RepaintBoundary(
            child: ClipRRect(
              child: CustomPaint(
                size: Size(width, height),
                painter: FftPainter(
                  audioData: audioData,
                  minFreq: minFreq,
                  maxFreq: maxFreq,
                ),
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
class FftPainter extends CustomPainter {
  const FftPainter({
    required this.audioData,
    required this.minFreq,
    required this.maxFreq,
  });
  final FfiData audioData;
  final int minFreq;
  final int maxFreq;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (maxFreq - minFreq);
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = barWidth * 0.8
      ..style = PaintingStyle.stroke;

    for (var i = minFreq; i <= maxFreq; i++) {
      final barHeight = size.height * audioData.get2D(0, i);
      canvas.drawRect(
        Rect.fromLTWH(
          barWidth * (i - minFreq),
          size.height - barHeight,
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
