import 'dart:typed_data';
import 'dart:js_interop';
import 'dart:js_util';

import 'package:meta/meta.dart';
import 'package:web/web.dart' as web;

import 'package:flutter_soloud/enums.dart';
import 'package:flutter_soloud/sound_hash.dart';
import 'package:flutter_soloud/sound_handle.dart';

/// https://kapadia.github.io/emscripten/2013/09/13/emscripten-pointers-and-pointers.html
/// https://emscripten.org/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html#access-memory-from-javascript

/// https://github.com/isar/isar/blob/main/packages/isar/lib/src/web/web.dart
/// chromium --disable-web-security --disable-gpu --user-data-dir=~/chromeTemp
///
/// Call Dart method from JS in Flutter Web
/// https://stackoverflow.com/questions/65423861/call-dart-method-from-js-in-flutter-web

/// These exports should take place of "bindings_player_ffi.dart" and referenced
/// into SoLoudController taking the place of "soLoudFFI".
/// SoLoudController should be an `abstract` class which will conditional
/// import the appropriate bindings: the current SoLoudController for all
/// but web, and this for web.
///
/// AudioIsolate should use an abstract class that implements Isolate, SendPort,
/// ReceivePort, Isolate.spawn, Isolate.kill logic and the same
/// functionalities for a web worker.
///
///

@JS('Module._malloc')
external int _malloc(int bytesCount);

@JS('Module._free')
external void _free(int ptrAddress);

@JS('Module.getValue')
external int _getValue(int ptrAddress, String type);

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

@JS('Module._createWorkerInWasm')
external void _createWorkerInWasm();

@JS('Module._sendToWorker')
external void _sendToWorker(String message, int value);

void voiceCallbackFromJs(int handle) {
  print('EUREKAAAAAAAAAAA  DART void voiceCallbackFromJs()  $handle');
}

@JS('Module.worker')
external web.Worker wasmWorker;

@JS('Module._initEngine')
external int _initEngine();

@JS('Module._dispose')
external void _dispose();

@JS('Module._isInited')
external bool _isInited();

@JS('Module._loadFile')
external int _loadFile(int completeFileNamePtr, bool loadIntoMem, int hashPtr);

@JS('Module._loadMem')
external int _loadMem(
  int uniqueNamePtr,
  int memPtr,
  int length,
  int hashPtr,
);

@JS('Module._loadWaveform')
external int _loadWaveform(
    int waveform, bool superWave, double scale, double detune, int hashPtr);

@JS('Module._play')
external int _play(int soundHash, double volume, double pan, bool paused,
    bool looping, double loopingStartAt, int handlePtr);

@JS('Module._getIsValidVoiceHandle')
external int _getIsValidVoiceHandle(int handle);

class JSSoloudPlayer {
  int malloc(int bytesCount) => _malloc(bytesCount);

  int getValue(int ptrAddress, String type) => _getValue(ptrAddress, type);

  void setValue(int ptrAddress, int value, String type) =>
      _setValue(ptrAddress, value, type);

  void free(int ptrAddress) => _free(ptrAddress);

  JSFunction cwrap(
    JSString fName,
    JSString returnType,
    JSArray<JSString> argTypes,
  ) =>
      _cwrap(fName, returnType, argTypes);

  JSFunction ccall(
    JSString fName,
    JSString returnType,
    JSArray<JSString> argTypes,
    JSArray<JSAny> args,
  ) =>
      _ccall(fName, returnType, argTypes, args);

  PlayerErrors initEngine() {
    var a = _initEngine();
    print('[[[[[[[[[[[[]]]]]]]]]]]] initEngine()  $a');
    // var result = callMethod(voiceEndedCallbackJS, 'call', [null, 1234]);
    // print('@@@@@@@@@@@@@@ $result'); // Should print: Hello, Flutter!

    setDartEventCallbacks();
    return PlayerErrors.values[a];
  }

  /// Set a Dart function to call when a sound ends.
  ///
  void setDartEventCallbacks() {
    _createWorkerInWasm();
  }

  void sendMessageToWasmWorker(String message, int value) {
    _sendToWorker(message, value);
  }

  void deinit() => _dispose();

  bool isInited() => _isInited();

  ({PlayerErrors error, SoundHash soundHash}) loadFile(
    String completeFileName,
    LoadMode mode,
  ) {
    final hashPtr = malloc(4); // 4 bytes for an int
    final pathPtr = malloc(completeFileName.length);
    final result = _loadFile(
      pathPtr,
      mode == LoadMode.memory ? true : false,
      hashPtr,
    );

    /// "*" means unsigned int 32
    final hash = getValue(hashPtr, '*');
    final soundHash = SoundHash(hash);
    final ret = (error: PlayerErrors.values[result], soundHash: soundHash);
    free(hashPtr);
    free(pathPtr);

    return ret;
  }

  ({PlayerErrors error, SoundHash soundHash}) loadMem(
    String uniqueName,
    Uint8List buffer,
  ) {
    final hashPtr = malloc(4); // 4 bytes for an int
    final bytesPtr = malloc(buffer.length);
    final pathPtr = malloc(uniqueName.length);
    for (var i = 0; i < buffer.length; i++) {
      setValue(bytesPtr + i, buffer[i], 'i8');
    }
    for (var i = 0; i < uniqueName.length; i++) {
      setValue(pathPtr + i, uniqueName.codeUnits[i], 'i8');
    }
    final result = _loadMem(
      pathPtr,
      bytesPtr,
      buffer.length,
      hashPtr,
    );

    /// "*" means unsigned int 32
    final hash = getValue(hashPtr, '*');
    final soundHash = SoundHash(hash);
    final ret = (error: PlayerErrors.values[result], soundHash: soundHash);

    free(hashPtr);
    free(bytesPtr);
    free(pathPtr);

    return ret;
  }

  ({PlayerErrors error, SoundHash soundHash}) loadWaveform(
    WaveForm waveform,
    bool superWave,
    double scale,
    double detune,
  ) {
    final hashPtr = malloc(4); // 4 bytes for an int
    final result = _loadWaveform(
      waveform.index,
      superWave,
      scale,
      detune,
      hashPtr,
    );

    /// "*" means unsigned int 32
    var hash = getValue(hashPtr, '*');
    final soundHash = SoundHash(hash);
    final ret = (error: PlayerErrors.values[result], soundHash: soundHash);
    free(hashPtr);

    return ret;
  }

  ({PlayerErrors error, SoundHandle newHandle}) play(
    SoundHash soundHash, {
    double volume = 1,
    double pan = 0,
    bool paused = false,
    bool looping = false,
    Duration loopingStartAt = Duration.zero,
  }) {
    final handlePtr = malloc(4); // 4 bytes for an int
    final result = _play(
      soundHash.hash,
      volume,
      pan,
      paused,
      looping,
      loopingStartAt.toDouble(),
      handlePtr,
    );

    /// "*" means unsigned int 32
    final handle = getValue(handlePtr, '*');
    final ret =
        (error: PlayerErrors.values[result], newHandle: SoundHandle(handle));
    free(handlePtr);

    return ret;
  }

  void stop(SoundHandle handle) {
    throw UnimplementedError();
  }

  void seek(double time) {
    throw UnimplementedError();
  }

  void disposeSound(SoundHash soundHash) {
    throw UnimplementedError();
  }

  void disposeAllSound() {
    throw UnimplementedError();
  }

  ({PlayerErrors error, SoundHandle handle}) speechText(String textToSpeech) {
    throw UnimplementedError();
  }

  ({PlayerErrors error, SoundHandle newHandle}) play3d(
    SoundHash soundHash,
    double posX,
    double posY,
    double posZ, {
    double velX = 0,
    double velY = 0,
    double velZ = 0,
    double volume = 1,
    bool paused = false,
    bool looping = false,
    Duration loopingStartAt = Duration.zero,
  }) {
    throw UnimplementedError();
  }

  bool getIsValidVoiceHandle(SoundHandle handle) {
    print('JSSoloudPlayer getIsValidVoiceHandle1  handle: $handle');
    final b = _getIsValidVoiceHandle(handle.id);
    print('JSSoloudPlayer getIsValidVoiceHandle: $b');
    return b == 1;
  }
}

/// Used for easier conversion from [Duration] to [double].
extension _DurationToDouble on Duration {
  double toDouble() {
    return inMicroseconds / Duration.microsecondsPerSecond;
  }
}
