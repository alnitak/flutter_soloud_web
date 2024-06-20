import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc;
import 'package:flutter_soloud/src/bindings/audio_data.dart';
import 'package:flutter_soloud/src/bindings/soloud_controller.dart';
import 'package:flutter_soloud/src/enums.dart';
import 'package:meta/meta.dart';

typedef SampleFormat2D = Pointer<Pointer<Float>>;
typedef SampleFormat1D = Pointer<Float>;

@experimental
class AudioDataCtrl {
  SampleFormat2D allocSample2D() {
    return calloc();
  }

  SampleFormat1D allocSample1D() {
    return calloc(512 * 4);
  }

  PlayerErrors Function(AudioData) texture2DCallback =
      SoLoudController().soLoudFFI.getAudioTexture2D;

  void Function(AudioData) textureCallback =
      SoLoudController().soLoudFFI.getAudioTexture;

  CaptureErrors Function(AudioData) captureTexture2DCallback =
      SoLoudController().captureFFI.getCaptureAudioTexture2D;

  void Function(AudioData) captureAudioTextureCallback =
      SoLoudController().captureFFI.getCaptureAudioTexture;

  void dispose(SampleFormat1D s1D, SampleFormat2D s2D) {
    if (s1D != nullptr) calloc.free(s1D);
    if (s2D != nullptr) calloc.free(s2D);
  }

  double get1D(SampleFormat1D s1D, int offset) {
    return s1D[offset];
  }

  double get2D(SampleFormat2D s2D, int row, int column) {
    const stride = 512;
    final val = s2D.value;
    return val[stride * row + column];
  }

  bool isEmpty1D(SampleFormat1D s1D) => s1D == nullptr;

  bool isEmpty2D(SampleFormat2D s2D) => s2D == nullptr;
}
