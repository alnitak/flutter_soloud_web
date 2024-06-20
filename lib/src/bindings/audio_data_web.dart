import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/src/bindings/audio_data.dart';
import 'package:flutter_soloud/src/enums.dart';
import 'package:meta/meta.dart';

@JS('Module._malloc')
external int _malloc(int bytesCount);

@JS('Module._free')
external void _free(int ptrAddress);

@JS('Module.getValue')
external int _getI32Value(int ptrAddress, String type);

@JS('Module.getValue')
external double _getF32Value(int ptrAddress, String type);

@JS('Module.setValue')
external void _setValue(int ptrAddress, int value, String type);

// @JS('Module._getFft')
// external void _getFft(XXXX fft);

// @JS('Module._getWave')
// external void _getWave(XXXX wave);

// @JS('Module._setFftSmoothing')
// external void _setFftSmoothing(double smooth);

@JS('Module._getAudioTexture')
external void _getAudioTexture(int samplesPtr);

@JS('Module._getAudioTexture2D')
external int _getAudioTexture2D(int samplesPtr);

@JS('Module._getCaptureTexture')
external void _getCaptureAudioTexture(int samplesPtr);

@JS('Module._getCaptureAudioTexture2D')
external int _getCaptureAudioTexture2D(int samplesPtr);

typedef SampleFormat2D = Float32List;
typedef SampleFormat1D = Float32List;

@experimental
class AudioDataCtrl {
  late final int _samplesPtr;

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
    _samplesPtr = _malloc(512 * 256);
    return Float32List(512 * 256);
  }

  SampleFormat1D allocSample1D() {
    _samplesPtr = _malloc(512);
    return Float32List(512);
  }

  PlayerErrors getAudioTexture2D(AudioData dummy) =>
      PlayerErrors.values[_getAudioTexture2D(_samplesPtr)];

  void getAudioTexture(AudioData dummy) => _getAudioTexture(_samplesPtr);

  CaptureErrors getCaptureAudioTexture2D(AudioData dummy) =>
      CaptureErrors.values[_getCaptureAudioTexture2D(_samplesPtr)];

  void getCaptureAudioTexture(AudioData dummy) =>
      _getCaptureAudioTexture(_samplesPtr);

  void dispose(SampleFormat1D s1D, SampleFormat2D s2D) {
    _free(_samplesPtr);
  }

  double get1D(SampleFormat1D s1D, int offset) {
    return _getF32Value(_samplesPtr + offset * 4, 'float');
  }

  double get2D(SampleFormat2D s2D, int row, int column) {
    final rowPtr = _getI32Value(_samplesPtr + row * 4, '*');
    return _getF32Value(rowPtr + column * 4, 'float');
  }

  bool isEmpty1D(SampleFormat1D s1D) => s1D.isEmpty;

  bool isEmpty2D(SampleFormat1D s2D) => s2D.isEmpty;
}
