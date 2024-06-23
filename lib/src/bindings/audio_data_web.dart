import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/src/bindings/js_extension.dart';
import 'package:flutter_soloud/src/bindings/soloud_controller.dart';
import 'package:flutter_soloud/src/enums.dart';
import 'package:meta/meta.dart';
import 'package:flutter_soloud/src/bindings/audio_data_extensions.dart';

typedef SampleFormat2D = Float32List;
typedef SampleFormat1D = Float32List;

@internal
@immutable
class AudioDataCtrl {
  late final int _samplesPtr;
  int get samplesPtr => _samplesPtr;

  /// Where the FFT or wave data is stored.
  late final SampleFormat2D _samplesWave;

  /// The getter for [_samplesWave].
  @internal
  SampleFormat2D get samplesWave => _samplesWave;

  /// Where the audio 2D data is stored.
  late final SampleFormat2D _samples2D;

  /// The getter for [_samples2D].
  @internal
  SampleFormat2D get samples2D => _samples2D;

  /// Where the audio 1D data is stored.
  late final SampleFormat1D _samples1D;

  /// The getter for [_samples1D].
  @internal
  SampleFormat1D get samples1D => _samples1D;

  final void Function(AudioDataCtrl) waveCallback =
      SoLoudController().soLoudFFI.getWave;

  final void Function(AudioDataCtrl) texture2DCallback =
      SoLoudController().soLoudFFI.getAudioTexture2D;

  final void Function(AudioDataCtrl) textureCallback =
      SoLoudController().soLoudFFI.getAudioTexture;

  final void Function(AudioDataCtrl) captureWaveCallback =
      SoLoudController().captureFFI.getCaptureWave;

  final CaptureErrors Function(AudioDataCtrl) captureTexture2DCallback =
      SoLoudController().captureFFI.getCaptureAudioTexture2D;

  final void Function(AudioDataCtrl) captureAudioTextureCallback =
      SoLoudController().captureFFI.getCaptureAudioTexture;

  void allocSample2D() {
    _samplesPtr = wasmMalloc(512 * 256 * 4);
    _samples2D = Float32List(512 * 256);
  }

  void allocSample1D() {
    _samplesPtr = wasmMalloc(512 * 4);
    _samples1D = Float32List(512);
  }

  void allocSampleWave() {
    _samplesPtr = wasmMalloc(256 * 4);
    _samplesWave = Float32List(256);
  }

  void dispose() {
    wasmFree(_samplesPtr);
  }

  double getWave(SampleWave offset) {
    final samplePtr = wasmGetI32Value(_samplesPtr, '*');
    return wasmGetF32Value(samplePtr + offset.value * 4, 'float');
  }

  double getLinear(SampleLinear offset) {
    final data = wasmGetF32Value(_samplesPtr + offset.value * 4, 'float');
    return data;
  }

  double getTexture(SampleRow row, SampleColumn column) {
    final rowPtr = wasmGetI32Value(_samplesPtr + row.value * 4, '*');
    return wasmGetF32Value(rowPtr + column.value * 4, 'float');
  }

  bool isEmptyLinear() => _samples1D.isEmpty;

  bool isEmptyTexture() => _samples2D.isEmpty;

  bool isEmptyWave() => _samplesWave.isEmpty;
}
