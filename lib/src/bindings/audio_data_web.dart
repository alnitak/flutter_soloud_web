import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/src/bindings/audio_data.dart';
import 'package:flutter_soloud/src/bindings/js_extension.dart';
import 'package:flutter_soloud/src/bindings/soloud_controller.dart';
import 'package:flutter_soloud/src/enums.dart';
import 'package:flutter_soloud/src/soloud.dart';
import 'package:meta/meta.dart';

typedef SampleFormat2D = Float32List;
typedef SampleFormat1D = Float32List;

@experimental
class AudioDataCtrl {
  late final int _samplesPtr;
  int get samplesPtr => _samplesPtr;

  late void Function(AudioData) texture2DCallback;

  late void Function(AudioData) textureCallback;

  late void Function(AudioData) captureTexture2DCallback;

  late void Function(AudioData) captureAudioTextureCallback;

  AudioDataCtrl() {
    texture2DCallback = getAudioTexture2D;
    textureCallback = getAudioTexture;
    captureTexture2DCallback = getCaptureAudioTexture2D;
    captureAudioTextureCallback = getCaptureAudioTexture;
  }

  SampleFormat2D allocSample2D() {
    _samplesPtr = wasmMalloc(512 * 256 * 4);
    return Float32List(512 * 256);
  }

  SampleFormat1D allocSample1D() {
    _samplesPtr = wasmMalloc(512 * 4);
    return Float32List(512);
  }

  PlayerErrors getAudioTexture2D(AudioData samples) =>
      SoLoudController().soLoudFFI.getAudioTexture2D(samples);

  void getAudioTexture(AudioData samples) =>
      SoLoudController().soLoudFFI.getAudioTexture(samples);

  CaptureErrors getCaptureAudioTexture2D(AudioData samples) =>
      SoLoudController().captureFFI.getCaptureAudioTexture2D(samples);

  void getCaptureAudioTexture(AudioData samples) =>
      SoLoudController().captureFFI.getCaptureAudioTexture(samples);

  void dispose(SampleFormat1D s1D, SampleFormat2D s2D) {
    wasmFree(_samplesPtr);
  }

  double get1D(SampleFormat1D s1D, int offset) {
    final data = wasmGetF32Value(_samplesPtr + offset * 4, 'float');
    return data;
  }

  double get2D(SampleFormat2D s2D, int row, int column) {
    final rowPtr = wasmGetI32Value(_samplesPtr + row * 4, '*');
    return wasmGetF32Value(rowPtr + column * 4, 'float');
  }

  bool isEmpty1D(SampleFormat1D s1D) => s1D.isEmpty;

  bool isEmpty2D(SampleFormat1D s2D) => s2D.isEmpty;
}
