// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names

// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'enums.dart';

/// CaptureDevice struct exposed in C
final class _CaptureDevice extends ffi.Struct {
  external ffi.Pointer<ffi.Char> name;

  @ffi.UnsignedInt()
  external int isDefault;
}

/// FFI bindings to capture with miniaudio
class FlutterCaptureFfi {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  FlutterCaptureFfi(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  FlutterCaptureFfi.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  /// --------------------- copy here the new functions to generate
  List<CaptureDevice> listCaptureDevices() {
    List<CaptureDevice> ret = [];
    ffi.Pointer<ffi.Pointer<_CaptureDevice>> devices =
        calloc(ffi.sizeOf<_CaptureDevice>());
    ffi.Pointer<ffi.Int> n_devices = calloc();

    _listCaptureDevices(
      devices,
      n_devices,
    );

    int ndev = n_devices.value;
    for (int i = 0; i < ndev; i++) {
      var s = (devices + i).value.ref.name.cast<Utf8>().toDartString();
      var n = (devices + i).value.ref.isDefault;
      ret.add(CaptureDevice(s, n == 1 ? true : false));
    }

    /// free allocated memory done in C
    /// this work on linux and android, not on win
    // for (int i = 0; i < ndev; i++) {
    //   calloc.free(devices.elementAt(i).value.ref.name);
    //   calloc.free(devices.elementAt(i).value);
    // }
    _freeListCaptureDevices(
      devices,
      ndev,
    );

    calloc.free(devices);
    calloc.free(n_devices);
    return ret;
  }

  late final _listCaptureDevicesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<ffi.Pointer<_CaptureDevice>>,
              ffi.Pointer<ffi.Int>)>>('listCaptureDevices');
  late final _listCaptureDevices = _listCaptureDevicesPtr.asFunction<
      void Function(
          ffi.Pointer<ffi.Pointer<_CaptureDevice>>, ffi.Pointer<ffi.Int>)>();

  late final _freeListCaptureDevicesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<ffi.Pointer<_CaptureDevice>>,
              ffi.Int)>>('freeListCaptureDevices');
  late final _freeListCaptureDevices = _freeListCaptureDevicesPtr.asFunction<
      void Function(ffi.Pointer<ffi.Pointer<_CaptureDevice>>, int)>();

  ///
  CaptureErrors initCapture(int deviceID) {
    final e = _initCapture(deviceID);
    return CaptureErrors.values[e];
  }

  late final _initCapturePtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int)>>('initCapture');
  late final _initCapture = _initCapturePtr.asFunction<int Function(int)>();

  void disposeCapture() {
    return _disposeCapture();
  }

  late final _disposeCapturePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('disposeCapture');
  late final _disposeCapture = _disposeCapturePtr.asFunction<void Function()>();

  bool isCaptureInited() {
    return _isCaptureInited() == 1 ? true : false;
  }

  late final _isCaptureInitedPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function()>>('isCaptureInited');
  late final _isCaptureInited =
      _isCaptureInitedPtr.asFunction<int Function()>();

  bool isCaptureStarted() {
    return _isCaptureStarted() == 1 ? true : false;
  }

  late final _isCaptureStartedPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function()>>('isCaptureStarted');
  late final _isCaptureStarted =
      _isCaptureStartedPtr.asFunction<int Function()>();

  CaptureErrors startCapture() {
    return CaptureErrors.values[_startCapture()];
  }

  late final _startCapturePtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function()>>('startCapture');
  late final _startCapture = _startCapturePtr.asFunction<int Function()>();

  CaptureErrors stopCapture() {
    return CaptureErrors.values[_stopCapture()];
  }

  late final _stopCapturePtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function()>>('stopCapture');
  late final _stopCapture = _stopCapturePtr.asFunction<int Function()>();

  CaptureErrors getCaptureAudioTexture2D(
    ffi.Pointer<ffi.Pointer<ffi.Float>> samples,
  ) {
    int ret = _getCaptureAudioTexture2D(samples);
    return CaptureErrors.values[ret];
  }

  late final _getCaptureAudioTexture2DPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<ffi.Pointer<ffi.Float>>)>>(
      'getCaptureAudioTexture2D');
  late final _getCaptureAudioTexture2D = _getCaptureAudioTexture2DPtr
      .asFunction<int Function(ffi.Pointer<ffi.Pointer<ffi.Float>>)>();

  CaptureErrors setCaptureFftSmoothing(double smooth) {
    int ret = _setCaptureFftSmoothing(smooth);
    return CaptureErrors.values[ret];
  }

  late final _setCaptureFftSmoothingPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Float)>>(
          'setCaptureFftSmoothing');
  late final _setCaptureFftSmoothing =
      _setCaptureFftSmoothingPtr.asFunction<int Function(double)>();
}
