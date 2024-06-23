import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc;
import 'package:flutter_soloud/src/bindings/soloud_controller.dart';
import 'package:flutter_soloud/src/enums.dart';
import 'package:meta/meta.dart';
import 'package:flutter_soloud/src/bindings/audio_data_extensions.dart';

typedef SampleFormat2D = Pointer<Pointer<Float>>;
typedef SampleFormat1D = Pointer<Float>;

@internal
@immutable
class AudioDataCtrl {
  /// To reflect [AudioDataCtrl] for web. Not used with `dart:ffi`
  final int _samplesPtr = 0;
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

  final PlayerErrors Function(AudioDataCtrl) texture2DCallback =
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
    _samples2D = calloc();
  }

  void allocSample1D() {
    _samples1D = calloc(512 * 4);
  }

  void allocSampleWave() {
    _samplesWave = calloc();
  }

  void dispose() {
    if (_samples1D != nullptr) calloc.free(_samples1D);
    if (_samples2D != nullptr) calloc.free(_samples2D);
  }

  double getWave(SampleWave offset) {
    final val = Pointer<Float>.fromAddress(_samples2D.value.address);
    return (val + offset.value).value;
  }

  double getLinear(SampleLinear offset) {
    return _samples1D[offset.value];
  }

  double getTexture(SampleRow row, SampleColumn column) {
    const stride = 512;
    final val = _samples2D.value;
    return val[stride * row.value + column.value];
  }

  bool isEmptyLinear() => _samples1D == nullptr;

  bool isEmptyTexture() => _samples2D == nullptr;

  bool isEmptywav() => _samplesWave == nullptr;
}
