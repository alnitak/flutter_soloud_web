import 'dart:typed_data';
import 'dart:js_interop';

import 'package:flutter_soloud/src/bindings/audio_data.dart';
import 'package:flutter_soloud/src/bindings/bindings_capture.dart';
import 'package:flutter_soloud/src/enums.dart';
import 'package:flutter_soloud/src/sound_hash.dart';
import 'package:flutter_soloud/src/sound_handle.dart';
import 'package:flutter_soloud/src/bindings/js_extension.dart';

class FlutterCaptureWeb extends FlutterCapture {
  @override
  List<CaptureDevice> listCaptureDevices() {
    /// allocate 50 device strings
    final namesPtr = wasmModule.malloc(50 * 150);
    final isDefaultPtr = wasmModule.malloc(50 * 4);
    final nDevicesPtr = wasmModule.malloc(4); // 4 bytes for an int

    wasmModule.listCaptureDevices(
      namesPtr,
      isDefaultPtr,
      nDevicesPtr,
    );

    final nDevices = wasmModule.getI32Value(nDevicesPtr, '*');
    final devices = <CaptureDevice>[];
    for (var i = 0; i < nDevices; i++) {
      final namePtr = wasmModule.getI32Value(namesPtr + i * 4, '*');
      final name = wasmModule.utf8ToString(namePtr);
      final isDefault = wasmModule.getI32Value(
          wasmModule.getI32Value(isDefaultPtr + i * 4, '*'), '*');

      devices.add(CaptureDevice(name, isDefault == 1));
    }

    wasmModule.freeListCaptureDevices(namesPtr, isDefaultPtr, nDevices);

    wasmModule.free(nDevicesPtr);
    wasmModule.free(isDefaultPtr);
    wasmModule.free(namesPtr);

    return devices;
  }

  @override
  CaptureErrors initCapture(int deviceID) {
    final e = wasmModule.initCapture(deviceID);
    return CaptureErrors.values[e];
  }

  @override
  void disposeCapture() {
    return wasmModule.disposeCapture();
  }

  @override
  bool isCaptureInited() {
    return wasmModule.isCaptureInited() == 1 ? true : false;
  }

  @override
  bool isCaptureStarted() {
    return wasmModule.isCaptureStarted() == 1 ? true : false;
  }

  @override
  CaptureErrors startCapture() {
    return CaptureErrors.values[wasmModule.startCapture()];
  }

  @override
  CaptureErrors stopCapture() {
    return CaptureErrors.values[wasmModule.stopCapture()];
  }

  @override
  void getCaptureAudioTexture(AudioData samples) {
    wasmModule.getCaptureAudioTexture(samples.ctrl.samplesPtr);
  }

  @override
  CaptureErrors getCaptureAudioTexture2D(AudioData samples) {
    final e = wasmModule.getCaptureAudioTexture2D(samples.ctrl.samplesPtr);
    return CaptureErrors.values[e];
  }

  @override
  CaptureErrors setCaptureFftSmoothing(double smooth) {
    final e = wasmModule.setCaptureFftSmoothing(smooth);
    return CaptureErrors.values[e];
  }
}
