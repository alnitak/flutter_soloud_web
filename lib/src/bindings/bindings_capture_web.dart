import 'dart:typed_data';
import 'dart:js_interop';

import 'package:flutter_soloud/src/bindings/bindings_capture.dart';
import 'package:flutter_soloud/src/enums.dart';
import 'package:flutter_soloud/src/sound_hash.dart';
import 'package:flutter_soloud/src/sound_handle.dart';

@JS('Module._malloc')
external int _malloc(int bytesCount);

@JS('Module._free')
external void _free(int ptrAddress);

@JS('Module.getValue')
external int _getValue(int ptrAddress, String type);

@JS('Module.UTF8ToString')
external String _utf8ToString(int ptrAddress);

@JS('Module.setValue')
external void _setValue(int ptrAddress, int value, String type);

@JS('Module.cwrap')
external JSFunction _cwrap(
  JSString fName,
  JSString returnType,
  JSArray<JSString> argTypes,
);

@JS('Module.ccall')
external JSFunction _ccall(
  JSString fName,
  JSString returnType,
  JSArray<JSString> argTypes,
  JSArray<JSAny> args,
);

// TODO(marco): implment
@JS('Module._listCaptureDevices')
external void _listCaptureDevices(int structPtr, int nDevicePtr);

// TODO(marco): implment
@JS('Module._freeListCaptureDevices')
external void _freeListCaptureDevices();

@JS('Module._initCapture')
external int _initCapture(int deviceID);

@JS('Module._disposeCapture')
external void _disposeCapture();

@JS('Module._isCaptureInited')
external int _isCaptureInited();

@JS('Module._isCaptureStarted')
external int _isCaptureStarted();

@JS('Module._startCapture')
external int _startCapture();

@JS('Module._stopCapture')
external int _stopCapture();

// @JS('Module._getCaptureAudioTexture2D')
// external int _getCaptureAudioTexture2D();

// @JS('Module._setCaptureFftSmoothing')
// external int _setCaptureFftSmoothing();

class FlutterCaptureWeb extends FlutterCapture {
  int malloc(int bytesCount) => _malloc(bytesCount);

  int getValue(int ptrAddress, String type) => _getValue(ptrAddress, type);

  void setValue(int ptrAddress, int value, String type) =>
      _setValue(ptrAddress, value, type);

  void free(int ptrAddress) => _free(ptrAddress);

  @override
  List<CaptureDevice> listCaptureDevices() {
    /// allocate 50 devices and for each an int and a string
    final structPtr = malloc(50 * (4 + 150));
    final nDevicesPtr = malloc(4); // 4 bytes for an int

    _listCaptureDevices(
      structPtr,
      nDevicesPtr,
    );

    final nDevices = getValue(nDevicesPtr, '*');
    print("LIST INPUT DEVICES nDevices: $nDevices");
    final devices = <CaptureDevice>[];
    var offsetPtr = 0;
    for (var i = 0; i < nDevices; i++) {
      final namePtr = getValue(structPtr + offsetPtr, '*');
      if (i == 0) {
        for (var n = 0; n < 30; n++) {
          final s = getValue(structPtr + i, 'i8');
          print('@@@@  $s');
        }
      }
      final name = _utf8ToString(namePtr);
      offsetPtr += name.length;

      final isDefault = getValue(structPtr + offsetPtr, '*');
      offsetPtr += 4;

      print("LIST INPUT DEVICES $i: isDefault: $isDefault  name: $name");
      devices.add(CaptureDevice(name, isDefault == 1));
    }

    free(nDevicesPtr);
    free(structPtr);
    return devices;
  }

  @override
  CaptureErrors initCapture(int deviceID) {
    final e = _initCapture(deviceID);
    return CaptureErrors.values[e];
  }

  @override
  void disposeCapture() {
    return _disposeCapture();
  }

  @override
  bool isCaptureInited() {
    return _isCaptureInited() == 1 ? true : false;
  }

  @override
  bool isCaptureStarted() {
    return _isCaptureStarted() == 1 ? true : false;
  }

  @override
  CaptureErrors startCapture() {
    return CaptureErrors.values[_startCapture()];
  }

  @override
  CaptureErrors stopCapture() {
    return CaptureErrors.values[_stopCapture()];
  }

  @override
  CaptureErrors getCaptureAudioTexture2D(samples) {
    throw UnimplementedError('No yet supported on the web platfom!');
  }

  @override
  CaptureErrors setCaptureFftSmoothing(double smooth) {
    throw UnimplementedError('No yet supported on the web platfom!');
  }
}
