import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc;
import 'package:flutter_soloud/src/bindings/ffi_data.dart';
import 'package:flutter_soloud/src/bindings/soloud_controller.dart';
import 'package:meta/meta.dart';

@experimental
class FfiData {
  final Pointer<Pointer<Float>> _samples2D;
  Pointer<Pointer<Float>> get data2D => _samples2D;

  final Pointer<Float> _samples1D;
  Pointer<Float> get data1D => _samples1D;

  final GetSamplesFrom getSamplesFrom;
  final GetSamplesKind getSamplesKind;

  late void Function(FfiData) _update;

  FfiData(this.getSamplesFrom, this.getSamplesKind)
      : _samples2D = calloc(),
        _samples1D = calloc(512*4) {
    if (getSamplesFrom == GetSamplesFrom.player) {
      if (getSamplesKind == GetSamplesKind.texture) {
        _update = SoLoudController().soLoudFFI.getAudioTexture2D;
      } else {
        _update = SoLoudController().soLoudFFI.getAudioTexture;
      }
    } else {
      if (getSamplesKind == GetSamplesKind.texture) {
        _update = SoLoudController().captureFFI.getCaptureAudioTexture2D;
      } else {
        _update = SoLoudController().captureFFI.getCaptureAudioTexture;
      }
    }
  }

  void updateSamples() {
    _update(this);
  }

  void dispose() {
    calloc.free(_samples2D);
    calloc.free(_samples1D);
  }

  double get1D(int offset) {
    final val = _samples1D[offset];
    return val;
  }

  double get2D(int row, int column) {
    const stride = 512;
    final val = _samples2D.value;
    return val[stride * row + column];
  }

  bool get isEmpty1D => _samples1D == nullptr;

  bool get isEmpty2D => _samples2D == nullptr;
}
