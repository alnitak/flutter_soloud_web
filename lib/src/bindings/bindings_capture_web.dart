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

@JS('Module._listCaptureDevices')
external void _listCaptureDevices(
    int namesPtr, int isDefaultPtr, int nDevicePtr);

@JS('Module._freeListCaptureDevices')
external void _freeListCaptureDevices(
  int namesPtr,
  int isDefaultPtr,
  int nDevice,
);

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
    /// allocate 50 device strings
    final namesPtr = malloc(50 * 150);
    final isDefaultPtr = malloc(50 * 4);
    final nDevicesPtr = malloc(4); // 4 bytes for an int

    _listCaptureDevices(
      namesPtr,
      isDefaultPtr,
      nDevicesPtr,
    );

    final nDevices = getValue(nDevicesPtr, '*');
    final devices = <CaptureDevice>[];
    for (var i = 0; i < nDevices; i++) {
      final namePtr = getValue(namesPtr + i * 4, '*');
      final name = _utf8ToString(namePtr);
      final isDefault = getValue(getValue(isDefaultPtr + i * 4, '*'), '*');

      devices.add(CaptureDevice(name, isDefault == 1));
    }

    _freeListCaptureDevices(namesPtr, isDefaultPtr, nDevices);

    free(nDevicesPtr);
    free(isDefaultPtr);
    free(namesPtr);

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
  CaptureErrors getCaptureAudioTexture2D(dynamic samples) {
    throw UnimplementedError('No yet supported on the web platfom!');
  }

  @override
  CaptureErrors setCaptureFftSmoothing(double smooth) {
    throw UnimplementedError('No yet supported on the web platfom!');
  }
}
