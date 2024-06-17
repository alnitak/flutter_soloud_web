import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';

import 'package:flutter_soloud/src/bindings/bindings_player.dart';
import 'package:web/web.dart' as web;

import 'package:flutter_soloud/src/enums.dart';
import 'package:flutter_soloud/src/sound_hash.dart';
import 'package:flutter_soloud/src/sound_handle.dart';

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

/// JS/WASM bindings to SoLoud
class FlutterSoLoudWeb extends FlutterSoLoud {
  /// Singleton to permit 'worker.dart' to access [voiceCallbackFromJs].
  static FlutterSoLoudWeb? _instance;

  FlutterSoLoudWeb._();

  factory FlutterSoLoudWeb() => _instance ??= FlutterSoLoudWeb._();

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

  /// Create the worker in the WASM Module.
  @override
  void setDartEventCallbacks() {
    _createWorkerInWasm();
  }

  /// This is the function called by "web/worker.dart" compiled
  /// to "web/worker.dart.js".
  void voiceCallbackFromJs(int handle) {
    print('EUREKAAAAAAAAAAA  DART void voiceCallbackFromJs()  $handle');
    voiceEndedEventController.add(handle);
  }

  void sendMessageToWasmWorker(String message, int value) {
    final messagePtr = malloc(message.length);
    for (var i = 0; i < message.length; i++) {
      setValue(messagePtr + i, message.codeUnits[i], 'i8');
    }
    _sendToWorker(messagePtr, value);
    free(messagePtr);
  }

  @override
  PlayerErrors initEngine() {
    return PlayerErrors.values[_initEngine()];
  }

  @override
  void deinit() => _deinit();

  @override
  bool isInited() => _isInited() == 1;

  @override
  ({PlayerErrors error, SoundHash soundHash}) loadFile(
    String completeFileName,
    LoadMode mode,
  ) {
    throw UnimplementedError(
        '[loadFile] in not supported on the web platfom! '
        'Please use [loadMem].');
  }

  @override
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

  @override
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

  @override
  void setWaveformScale(SoundHash hash, double newScale) {
    return _setWaveformScale(hash.hash, newScale);
  }

  @override
  void setWaveformDetune(SoundHash hash, double newDetune) {
    return _setWaveformDetune(hash.hash, newDetune);
  }

  @override
  void setWaveformFreq(SoundHash hash, double newFreq) {
    return _setWaveformFreq(hash.hash, newFreq);
  }

  @override
  void setWaveformSuperWave(SoundHash hash, int superwave) {
    return _setSuperWave(hash.hash, superwave);
  }

  @override
  void setWaveform(SoundHash hash, WaveForm newWaveform) {
    return _setWaveform(hash.hash, newWaveform.index);
  }

  @override
  ({PlayerErrors error, SoundHandle handle}) speechText(String textToSpeech) {
    final handlePtr = malloc(4); // 4 bytes for an int
    final textToSpeechPtr = malloc(textToSpeech.length);
    final result = _speechText(
      textToSpeechPtr,
      handlePtr,
    );

    /// "*" means unsigned int 32
    final newHandle = getValue(handlePtr, '*');
    final ret = (
      error: PlayerErrors.values[result],
      handle: SoundHandle(newHandle),
    );
    free(textToSpeechPtr);
    free(handlePtr);

    return ret;
  }

  @override
  void pauseSwitch(SoundHandle handle) {
    return _pauseSwitch(handle.id);
  }

  @override
  void setPause(SoundHandle handle, int pause) {
    return _setPause(handle.id, pause);
  }

  @override
  bool getPause(SoundHandle handle) {
    return _getPause(handle.id) == 1;
  }

  @override
  void setRelativePlaySpeed(SoundHandle handle, double speed) {
    return _setRelativePlaySpeed(handle.id, speed);
  }

  @override
  double getRelativePlaySpeed(SoundHandle handle) {
    return _getRelativePlaySpeed(handle.id);
  }

  @override
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
    final newHandle = getValue(handlePtr, '*');
    final ret =
        (error: PlayerErrors.values[result], newHandle: SoundHandle(newHandle));
    free(handlePtr);

    return ret;
  }

  @override
  void stop(SoundHandle handle) {
    return _stop(handle.id);
  }

  @override
  void disposeSound(SoundHash soundHash) {
    return _disposeSound(soundHash.hash);
  }

  @override
  void disposeAllSound() {
    return _disposeAllSound();
  }

  @override
  bool getLooping(SoundHandle handle) {
    return _getLooping(handle.id) == 1;
  }

  @override
  void setLooping(SoundHandle handle, bool enable) {
    return _setLooping(handle.id, enable ? 1 : 0);
  }

  @override
  Duration getLoopPoint(SoundHandle handle) {
    return _getLoopPoint(handle.id).toDuration();
  }

  @override
  void setLoopPoint(SoundHandle handle, Duration timestamp) {
    _setLoopPoint(handle.id, timestamp.toDouble());
  }

  @override
  void setVisualizationEnabled(bool enabled) {
    throw UnimplementedError(
        '[setVisualizationEnabled] in not supported on the web platfom!');
  }

  @override
  bool getVisualizationEnabled() {
    return false;
  }

  @override
  void getFft(dynamic fft) {
    throw UnimplementedError('[getFft] in not supported on the web platfom!');
  }

  @override
  void getWave(dynamic wave) {
    throw UnimplementedError('[getWave] in not supported on the web platfom!');
  }

  @override
  void setFftSmoothing(double smooth) {
    throw UnimplementedError(
        '[setFftSmoothing] in not supported on the web platfom!');
  }

  @override
  void getAudioTexture(dynamic samples) {
    throw UnimplementedError(
        '[getAudioTexture] in not supported on the web platfom!');
  }

  @override
  PlayerErrors getAudioTexture2D(dynamic samples) {
    throw UnimplementedError(
        '[getAudioTexture2D] in not supported on the web platfom!');
  }

  @override
  Duration getLength(SoundHash soundHash) {
    return _getLength(soundHash.hash).toDuration();
  }

  @override
  int seek(SoundHandle handle, Duration time) {
    return _seek(handle.id, time.toDouble());
  }

  @override
  Duration getPosition(SoundHandle handle) {
    return _getPosition(handle.id).toDuration();
  }

  @override
  double getGlobalVolume() {
    return _getGlobalVolume();
  }

  @override
  int setGlobalVolume(double volume) {
    return _setGlobalVolume(volume);
  }

  @override
  double getVolume(SoundHandle handle) {
    return _getVolume(handle.id);
  }

  @override
  int setVolume(SoundHandle handle, double volume) {
    return _setVolume(handle.id, volume);
  }

  @override
  bool getIsValidVoiceHandle(SoundHandle handle) {
    return _getIsValidVoiceHandle(handle.id) == 1;
  }

  @override
  int getActiveVoiceCount() {
    return _getActiveVoiceCount();
  }

  @override
  int countAudioSource(SoundHash soundHash) {
    return _countAudioSource(soundHash.hash);
  }

  @override
  int getVoiceCount() {
    return _getVoiceCount();
  }

  @override
  bool getProtectVoice(SoundHandle handle) {
    return _getProtectVoice(handle.id) == 1;
  }

  @override
  void setProtectVoice(SoundHandle handle, bool protect) {
    return _setProtectVoice(handle.id, protect ? 1 : 0);
  }

  @override
  int getMaxActiveVoiceCount() {
    return _getMaxActiveVoiceCount();
  }

  @override
  void setMaxActiveVoiceCount(int maxVoiceCount) {
    return _setMaxActiveVoiceCount(maxVoiceCount);
  }

  /////////////////////////////////////////
  /// faders
  /////////////////////////////////////////

  @override
  int fadeGlobalVolume(double to, Duration duration) {
    return _fadeGlobalVolume(to, duration.toDouble());
  }

  @override
  int fadeVolume(SoundHandle handle, double to, Duration duration) {
    return _fadeVolume(handle.id, to, duration.toDouble());
  }

  @override
  int fadePan(SoundHandle handle, double to, Duration duration) {
    return _fadePan(handle.id, to, duration.toDouble());
  }

  @override
  int fadeRelativePlaySpeed(SoundHandle handle, double to, Duration time) {
    return _fadeRelativePlaySpeed(handle.id, to, time.toDouble());
  }

  @override
  int schedulePause(SoundHandle handle, Duration duration) {
    return _schedulePause(handle.id, duration.toDouble());
  }

  @override
  int scheduleStop(SoundHandle handle, Duration duration) {
    return _scheduleStop(handle.id, duration.toDouble());
  }

  @override
  int oscillateVolume(
      SoundHandle handle, double from, double to, Duration time) {
    return _oscillateVolume(handle.id, from, to, time.toDouble());
  }

  @override
  int oscillatePan(SoundHandle handle, double from, double to, Duration time) {
    return _oscillatePan(handle.id, from, to, time.toDouble());
  }

  @override
  int oscillateRelativePlaySpeed(
      SoundHandle handle, double from, double to, Duration time) {
    return _oscillateRelativePlaySpeed(handle.id, from, to, time.toDouble());
  }

  @override
  int oscillateGlobalVolume(double from, double to, Duration time) {
    return _oscillateGlobalVolume(from, to, time.toDouble());
  }

  /////////////////////////////////////////
  /// Filters
  /////////////////////////////////////////

  @override
  ({PlayerErrors error, int index}) isFilterActive(int filterType) {
    // ignore: omit_local_variable_types
    final idPtr = malloc(4); // 4 bytes for an int
    final e = _isFilterActive(filterType, idPtr);
    final ret = (error: PlayerErrors.values[e], index: getValue(idPtr, '*'));
    free(idPtr);
    return ret;
  }

  @override
  ({PlayerErrors error, List<String> names}) getFilterParamNames(
      int filterType) {
    final paramsCountPtr = malloc(4); // 4 bytes for an int
    final namesPtr = malloc(30 * 20); // list of 30 String with 20 chars
    final e = _getFilterParamNames(filterType, paramsCountPtr, namesPtr);

    final pNames = <String>[];
    var offsetPtr = 0;
    for (var i = 0; i < getValue(paramsCountPtr, '*'); i++) {
      final namePtr = getValue(namesPtr + offsetPtr, '*');
      final name = _utf8ToString(namePtr);
      offsetPtr += name.length;

      pNames.add(name);
    }

    final ret = (error: PlayerErrors.values[e], names: pNames);
    free(namesPtr);
    free(paramsCountPtr);
    return ret;
  }

  @override
  PlayerErrors addGlobalFilter(int filterType) {
    final e = _addGlobalFilter(filterType);
    return PlayerErrors.values[e];
  }

  @override
  int removeGlobalFilter(int filterType) {
    return _removeGlobalFilter(filterType);
  }

  @override
  int setFilterParams(int filterType, int attributeId, double value) {
    return _setFxParams(filterType, attributeId, value);
  }

  @override
  double getFilterParams(int filterType, int attributeId) {
    return _getFxParams(filterType, attributeId);
  }

  /////////////////////////////////////////
  /// 3D audio methods
  /////////////////////////////////////////

  @override
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
    final handlePtr = malloc(4); // 4 bytes for an int
    final result = _play3d(
      soundHash.hash,
      posX,
      posY,
      posZ,
      velX,
      velY,
      velZ,
      volume,
      paused ? 1 : 0,
      looping ? 1 : 0,
      loopingStartAt.toDouble(),
      handlePtr,
    );

    /// "*" means unsigned int 32
    final newHandle = getValue(handlePtr, '*');
    final ret =
        (error: PlayerErrors.values[result], newHandle: SoundHandle(newHandle));
    free(handlePtr);

    return ret;
  }

  @override
  void set3dSoundSpeed(double speed) {
    return _set3dSoundSpeed(speed);
  }

  @override
  double get3dSoundSpeed() {
    return _get3dSoundSpeed();
  }

  @override
  void set3dListenerParameters(
    double posX,
    double posY,
    double posZ,
    double atX,
    double atY,
    double atZ,
    double upX,
    double upY,
    double upZ,
    double velocityX,
    double velocityY,
    double velocityZ,
  ) {
    return _set3dListenerParameters(
      posX,
      posY,
      posZ,
      atX,
      atY,
      atZ,
      upX,
      upY,
      upZ,
      velocityX,
      velocityY,
      velocityZ,
    );
  }

  @override
  void set3dListenerPosition(double posX, double posY, double posZ) {
    return _set3dListenerPosition(posX, posY, posZ);
  }

  @override
  void set3dListenerAt(double atX, double atY, double atZ) {
    return _set3dListenerAt(atX, atY, atZ);
  }

  @override
  void set3dListenerUp(double upX, double upY, double upZ) {
    return _set3dListenerUp(upX, upY, upZ);
  }

  @override
  void set3dListenerVelocity(
    double velocityX,
    double velocityY,
    double velocityZ,
  ) {
    return _set3dListenerVelocity(velocityX, velocityY, velocityZ);
  }

  @override
  void set3dSourceParameters(
    SoundHandle handle,
    double posX,
    double posY,
    double posZ,
    double velocityX,
    double velocityY,
    double velocityZ,
  ) {
    return _set3dSourceParameters(
      handle.id,
      posX,
      posY,
      posZ,
      velocityX,
      velocityY,
      velocityZ,
    );
  }

  @override
  void set3dSourcePosition(
      SoundHandle handle, double posX, double posY, double posZ) {
    return _set3dSourcePosition(handle.id, posX, posY, posZ);
  }

  @override
  void set3dSourceVelocity(
    SoundHandle handle,
    double velocityX,
    double velocityY,
    double velocityZ,
  ) {
    return _set3dSourceVelocity(handle.id, velocityX, velocityY, velocityZ);
  }

  @override
  void set3dSourceMinMaxDistance(
    SoundHandle handle,
    double minDistance,
    double maxDistance,
  ) {
    return _set3dSourceMinMaxDistance(handle.id, minDistance, maxDistance);
  }

  @override
  void set3dSourceAttenuation(
    SoundHandle handle,
    int attenuationModel,
    double attenuationRolloffFactor,
  ) {
    return _set3dSourceAttenuation(
      handle.id,
      attenuationModel,
      attenuationRolloffFactor,
    );
  }

  @override
  void set3dSourceDopplerFactor(SoundHandle handle, double dopplerFactor) {
    return _set3dSourceDopplerFactor(handle.id, dopplerFactor);
  }
}

//////////////////////////////////////////////////////////////
/// JS external methods
//////////////////////////////////////////////////////////////

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

@JS('Module._createWorkerInWasm')
external void _createWorkerInWasm();

@JS('Module._sendToWorker')
external void _sendToWorker(int message, int value);

@JS('Module.worker')
external web.Worker wasmWorker;

@JS('Module._initEngine')
external int _initEngine();

@JS('Module._dispose')
external void _deinit();

@JS('Module._isInited')
external int _isInited();

@JS('Module._loadFile')
external int _loadFile(int completeFileNamePtr, int loadIntoMem, int hashPtr);

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

@JS('Module._setWaveformScale')
external void _setWaveformScale(int soundHash, double newScale);

@JS('Module._setWaveformDetune')
external void _setWaveformDetune(int soundHash, double newDetune);

@JS('Module._setWaveformFreq')
external void _setWaveformFreq(int soundHash, double newFreq);

@JS('Module._setSuperWave')
external void _setSuperWave(int soundHash, int superwave);

@JS('Module._setWaveform')
external void _setWaveform(int soundHash, int newWaveform);

@JS('Module._speechText')
external int _speechText(int textToSpeechPtr, int handlePtr);

@JS('Module._pauseSwitch')
external void _pauseSwitch(int handle);

@JS('Module._setPause')
external void _setPause(int handle, int pause);

@JS('Module._getPause')
external int _getPause(int handle);

@JS('Module._setRelativePlaySpeed')
external void _setRelativePlaySpeed(int handle, double speed);

@JS('Module._getRelativePlaySpeed')
external double _getRelativePlaySpeed(int handle);

@JS('Module._play')
external int _play(int soundHash, double volume, double pan, bool paused,
    bool looping, double loopingStartAt, int handlePtr);

@JS('Module._stop')
external void _stop(int handle);

@JS('Module._disposeSound')
external void _disposeSound(int soundHash);

@JS('Module._disposeAllSound')
external void _disposeAllSound();

@JS('Module._getLooping')
external int _getLooping(int handle);

@JS('Module._setLooping')
external void _setLooping(int handle, int enable);

@JS('Module._getLoopPoint')
external double _getLoopPoint(int handle);

@JS('Module._setLoopPoint')
external void _setLoopPoint(int handle, double time);

@JS('Module._setVisualizationEnabled')
external void _setVisualizationEnabled(int enabled);

@JS('Module._getVisualizationEnabled')
external int _getVisualizationEnabled();

// @JS('Module._getFft')
// external void _getFft(XXXX fft);

// @JS('Module._getWave')
// external void _getWave(XXXX wave);

// @JS('Module._setFftSmoothing')
// external void _setFftSmoothing(double smooth);

// @JS('Module._getAudioTexture')
// external void _getAudioTexture(XXXX samples);

// @JS('Module._getAudioTexture2D')
// external void _getAudioTexture2D(XXXX samples);

@JS('Module._getLength')
external double _getLength(int soundHash);

@JS('Module._seek')
external int _seek(int handle, double time);

@JS('Module._getPosition')
external double _getPosition(int handle);

@JS('Module._getGlobalVolume')
external double _getGlobalVolume();

@JS('Module._setGlobalVolume')
external int _setGlobalVolume(double volume);

@JS('Module._getVolume')
external double _getVolume(int handle);

@JS('Module._setVolume')
external int _setVolume(int handle, double volume);

@JS('Module._getIsValidVoiceHandle')
external int _getIsValidVoiceHandle(int handle);

@JS('Module._getActiveVoiceCount')
external int _getActiveVoiceCount();

@JS('Module._countAudioSource')
external int _countAudioSource(int soundHash);

@JS('Module._getVoiceCount')
external int _getVoiceCount();

@JS('Module._getProtectVoice')
external int _getProtectVoice(int handle);

@JS('Module._setProtectVoice')
external void _setProtectVoice(int handle, int protect);

@JS('Module._getMaxActiveVoiceCount')
external int _getMaxActiveVoiceCount();

@JS('Module._setMaxActiveVoiceCount')
external void _setMaxActiveVoiceCount(int maxVoiceCount);

@JS('Module._fadeGlobalVolume')
external int _fadeGlobalVolume(double to, double duration);

@JS('Module._fadeVolume')
external int _fadeVolume(int handle, double to, double duration);

@JS('Module._fadePan')
external int _fadePan(int handle, double to, double duration);

@JS('Module._fadeRelativePlaySpeed')
external int _fadeRelativePlaySpeed(int handle, double to, double duration);

@JS('Module._schedulePause')
external int _schedulePause(int handle, double duration);

@JS('Module._scheduleStop')
external int _scheduleStop(int handle, double duration);

@JS('Module._oscillateVolume')
external int _oscillateVolume(int handle, double from, double to, double time);

@JS('Module._oscillatePan')
external int _oscillatePan(int handle, double from, double to, double time);

@JS('Module._oscillateRelativePlaySpeed')
external int _oscillateRelativePlaySpeed(
    int handle, double from, double to, double time);

@JS('Module._oscillateGlobalVolume')
external int _oscillateGlobalVolume(double from, double to, double time);

@JS('Module._isFilterActive')
external int _isFilterActive(int filterType, int idPtr);

@JS('Module._getFilterParamNames')
external int _getFilterParamNames(
  int filterType,
  int paramsCountPtr,
  int namesPtr,
);

@JS('Module._addGlobalFilter')
external int _addGlobalFilter(int filterType);

@JS('Module._removeGlobalFilter')
external int _removeGlobalFilter(int filterType);

@JS('Module._setFxParams')
external int _setFxParams(int filterType, int attributeId, double value);

@JS('Module._getFxParams')
external double _getFxParams(int filterType, int attributeId);

@JS('Module._play3d')
external int _play3d(
  int soundHash,
  double posX,
  double posY,
  double posZ,
  double velX,
  double velY,
  double velZ,
  double volume,
  int paused,
  int looping,
  double loopingStartAt,
  int handlePtr,
);

@JS('Module._set3dSoundSpeed')
external void _set3dSoundSpeed(double speed);

@JS('Module._get3dSoundSpeed')
external double _get3dSoundSpeed();

@JS('Module._set3dListenerParameters')
external void _set3dListenerParameters(
  double posX,
  double posY,
  double posZ,
  double atX,
  double atY,
  double atZ,
  double upX,
  double upY,
  double upZ,
  double velocityX,
  double velocityY,
  double velocityZ,
);

@JS('Module._set3dListenerPosition')
external void _set3dListenerPosition(double posX, double posY, double posZ);

@JS('Module._set3dListenerAt')
external void _set3dListenerAt(double atX, double atY, double atZ);

@JS('Module._set3dListenerUp')
external void _set3dListenerUp(double upX, double upY, double upZ);

@JS('Module._set3dListenerVelocity')
external void _set3dListenerVelocity(
  double velocityX,
  double velocityY,
  double velocityZ,
);

@JS('Module._set3dSourceParameters')
external void _set3dSourceParameters(
  int handle,
  double posX,
  double posY,
  double posZ,
  double velocityX,
  double velocityY,
  double velocityZ,
);

@JS('Module._set3dSourcePosition')
external void _set3dSourcePosition(
  int handle,
  double posX,
  double posY,
  double posZ,
);

@JS('Module._set3dSourceVelocity')
external void _set3dSourceVelocity(
  int handle,
  double velocityX,
  double velocityY,
  double velocityZ,
);

@JS('Module._set3dSourceMinMaxDistance')
external void _set3dSourceMinMaxDistance(
  int handle,
  double minDistance,
  double maxDistance,
);

@JS('Module._set3dSourceAttenuation')
external void _set3dSourceAttenuation(
  int handle,
  int attenuationModel,
  double attenuationRolloffFactor,
);

@JS('Module._set3dSourceDopplerFactor')
external void _set3dSourceDopplerFactor(int handle, double dopplerFactor);
