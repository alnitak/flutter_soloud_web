import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'bars_fft_widget.dart';
import 'bars_wave_widget.dart';

import 'package:flutter_soloud/src/bindings/audio_data.dart';
import 'package:flutter_soloud/src/soloud.dart';
import 'package:flutter_soloud/src/soloud_capture.dart';

/// Visualizer for FFT and wave data
class Bars extends StatefulWidget {
  /// If true get audio data from the player else from the mic

  const Bars({super.key});

  @override
  State<Bars> createState() => BarsState();
}

class BarsState extends State<Bars> with SingleTickerProviderStateMixin {
  late final Ticker ticker;
  final AudioData audioData = AudioData(
    GetSamplesFrom.player,
    GetSamplesKind.linear,
  );
  @override
  void initState() {
    super.initState();
    ticker = createTicker(_tick);
    ticker.start();
  }

  @override
  void dispose() {
    ticker.stop();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    if (context.mounted) {
      try {
        audioData.updateSamples();
        setState(() {});
      } on Exception {
        debugPrint('Player not initialized or visualization is not enabled!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          BarsFftWidget(
            audioData: audioData,
            minFreq: 0,
            maxFreq: 128,
            width: MediaQuery.sizeOf(context).width / 2 - 17,
            height: MediaQuery.sizeOf(context).width / 6,
          ),
          const SizedBox(width: 6),
          BarsWaveWidget(
            audioData: audioData,
            width: MediaQuery.sizeOf(context).width / 2 - 17,
            height: MediaQuery.sizeOf(context).width / 6,
          ),
        ],
      ),
    );
  }
}
