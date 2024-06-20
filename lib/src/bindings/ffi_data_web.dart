import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/src/bindings/ffi_data.dart';
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
external void _getAudioTexture2D(int samplesPtr);

@JS('Module._getCaptureTexture')
external void _getCaptureAudioTexture(int samplesPtr);

@JS('Module._getCaptureAudioTexture2D')
external void _getCaptureAudioTexture2D(int samplesPtr);

@experimental
class FfiData {
  int malloc(int bytesCount) => _malloc(bytesCount);

  int getI32Value(int ptrAddress, String type) =>
      _getI32Value(ptrAddress, type);
  double getF32Value(int ptrAddress, String type) =>
      _getF32Value(ptrAddress, type);

  void setValue(int ptrAddress, int value, String type) =>
      _setValue(ptrAddress, value, type);

  void free(int ptrAddress) => _free(ptrAddress);

  final Float32List _samples2D;
  Float32List get data2D => _samples2D;

  final Float32List _samples1D;
  Float32List get data1D => _samples1D;

  final GetSamplesFrom getSamplesFrom;
  final GetSamplesKind getSamplesKind;

  late void Function(int) _update;
  late int _samplesPtr;

  FfiData(this.getSamplesFrom, this.getSamplesKind)
      : _samples2D = Float32List(512 * 256),
        _samples1D = Float32List(512) {
    if (getSamplesFrom == GetSamplesFrom.player) {
      if (getSamplesKind == GetSamplesKind.texture) {
        _update = _getAudioTexture2D;
        _samplesPtr = malloc(512 * 256);
      } else {
        _update = _getAudioTexture;
        _samplesPtr = malloc(512);
      }
    } else {
      if (getSamplesKind == GetSamplesKind.texture) {
        _update = _getCaptureAudioTexture2D;
        _samplesPtr = malloc(512 * 256);
      } else {
        _update = _getCaptureAudioTexture;
        _samplesPtr = malloc(512);
      }
    }
  }

  void updateSamples() {
    _update(_samplesPtr);
  }

  void dispose() {
    free(_samplesPtr);
  }

  double get1D(int offset) {
    final val = getF32Value(_samplesPtr + offset * 4, 'float');
    return val;
  }

  double get2D(int row, int column) {
    final rowPtr = getI32Value(_samplesPtr + row * 4, '*');
    final val = getF32Value(rowPtr + column * 4, 'float');
    return val;
  }

  bool get isEmpty1D => _samples1D.isEmpty;

  bool get isEmpty2D => _samples2D.isEmpty;
}
