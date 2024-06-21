import 'dart:typed_data';

import 'package:flutter_soloud/src/bindings/audio_data.dart';
import 'package:flutter_soloud/src/bindings/bindings_player.dart';
import 'package:flutter_soloud/src/bindings/js_extension.dart';

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

  /// Create the worker in the WASM Module.
  @override
  void setDartEventCallbacks() {
    wasmModule.createWorkerInWasm();
  }

  /// This is the function called by "web/worker.dart" compiled
  /// to "web/worker.dart.js".
  void voiceCallbackFromJs(int handle) {
    print('EUREKAAAAAAAAAAA  DART void voiceCallbackFromJs()  $handle');
    voiceEndedEventController.add(handle);
  }

  void sendMessageToWasmWorker(String message, int value) {
    final messagePtr = wasmModule.malloc(message.length);
    for (var i = 0; i < message.length; i++) {
      wasmModule.setValue(messagePtr + i, message.codeUnits[i], 'i8');
    }
    wasmModule.sendToWorker(messagePtr, value);
    wasmModule.free(messagePtr);
  }

  @override
  PlayerErrors initEngine() {
    return PlayerErrors.values[wasmModule.initEngine()];
  }

  @override
  void deinit() => wasmModule.deinit();

  @override
  bool isInited() => wasmModule.isInited() == 1;

  @override
  ({PlayerErrors error, SoundHash soundHash}) loadFile(
    String completeFileName,
    LoadMode mode,
  ) {
    throw UnimplementedError('[loadFile] in not supported on the web platfom! '
        'Please use [loadMem].');
  }

  @override
  ({PlayerErrors error, SoundHash soundHash}) loadMem(
    String uniqueName,
    Uint8List buffer,
  ) {
    final hashPtr = wasmModule.malloc(4); // 4 bytes for an int
    final bytesPtr = wasmModule.malloc(buffer.length);
    final pathPtr = wasmModule.malloc(uniqueName.length);
    for (var i = 0; i < buffer.length; i++) {
      wasmModule.setValue(bytesPtr + i, buffer[i], 'i8');
    }
    for (var i = 0; i < uniqueName.length; i++) {
      wasmModule.setValue(pathPtr + i, uniqueName.codeUnits[i], 'i8');
    }
    final result = wasmModule.loadMem(
      pathPtr,
      bytesPtr,
      buffer.length,
      hashPtr,
    );

    /// "*" means unsigned int 32
    final hash = wasmModule.getI32Value(hashPtr, '*');
    final soundHash = SoundHash(hash);
    final ret = (error: PlayerErrors.values[result], soundHash: soundHash);

    wasmModule.free(hashPtr);
    wasmModule.free(bytesPtr);
    wasmModule.free(pathPtr);

    return ret;
  }

  @override
  ({PlayerErrors error, SoundHash soundHash}) loadWaveform(
    WaveForm waveform,
    bool superWave,
    double scale,
    double detune,
  ) {
    final hashPtr = wasmModule.malloc(4); // 4 bytes for an int
    final result = wasmModule.loadWaveform(
      waveform.index,
      superWave,
      scale,
      detune,
      hashPtr,
    );

    /// "*" means unsigned int 32
    var hash = wasmModule.getI32Value(hashPtr, '*');
    final soundHash = SoundHash(hash);
    final ret = (error: PlayerErrors.values[result], soundHash: soundHash);
    wasmModule.free(hashPtr);

    return ret;
  }

  @override
  void setWaveformScale(SoundHash hash, double newScale) {
    return wasmModule.setWaveformScale(hash.hash, newScale);
  }

  @override
  void setWaveformDetune(SoundHash hash, double newDetune) {
    return wasmModule.setWaveformDetune(hash.hash, newDetune);
  }

  @override
  void setWaveformFreq(SoundHash hash, double newFreq) {
    return wasmModule.setWaveformFreq(hash.hash, newFreq);
  }

  @override
  void setWaveformSuperWave(SoundHash hash, int superwave) {
    return wasmModule.setSuperWave(hash.hash, superwave);
  }

  @override
  void setWaveform(SoundHash hash, WaveForm newWaveform) {
    return wasmModule.setWaveform(hash.hash, newWaveform.index);
  }

  @override
  ({PlayerErrors error, SoundHandle handle}) speechText(String textToSpeech) {
    final handlePtr = wasmModule.malloc(4); // 4 bytes for an int
    final textToSpeechPtr = wasmModule.malloc(textToSpeech.length);
    final result = wasmModule.speechText(
      textToSpeechPtr,
      handlePtr,
    );

    /// "*" means unsigned int 32
    final newHandle = wasmModule.getI32Value(handlePtr, '*');
    final ret = (
      error: PlayerErrors.values[result],
      handle: SoundHandle(newHandle),
    );
    wasmModule.free(textToSpeechPtr);
    wasmModule.free(handlePtr);

    return ret;
  }

  @override
  void pauseSwitch(SoundHandle handle) {
    return wasmModule.pauseSwitch(handle.id);
  }

  @override
  void setPause(SoundHandle handle, int pause) {
    return wasmModule.setPause(handle.id, pause);
  }

  @override
  bool getPause(SoundHandle handle) {
    return wasmModule.getPause(handle.id) == 1;
  }

  @override
  void setRelativePlaySpeed(SoundHandle handle, double speed) {
    return wasmModule.setRelativePlaySpeed(handle.id, speed);
  }

  @override
  double getRelativePlaySpeed(SoundHandle handle) {
    return wasmModule.getRelativePlaySpeed(handle.id);
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
    final handlePtr = wasmModule.malloc(4); // 4 bytes for an int
    final result = wasmModule.play(
      soundHash.hash,
      volume,
      pan,
      paused,
      looping,
      loopingStartAt.toDouble(),
      handlePtr,
    );

    /// "*" means unsigned int 32
    final newHandle = wasmModule.getI32Value(handlePtr, '*');
    final ret =
        (error: PlayerErrors.values[result], newHandle: SoundHandle(newHandle));
    wasmModule.free(handlePtr);

    return ret;
  }

  @override
  void stop(SoundHandle handle) {
    return wasmModule.stop(handle.id);
  }

  @override
  void disposeSound(SoundHash soundHash) {
    return wasmModule.disposeSound(soundHash.hash);
  }

  @override
  void disposeAllSound() {
    return wasmModule.disposeAllSound();
  }

  @override
  bool getLooping(SoundHandle handle) {
    return wasmModule.getLooping(handle.id) == 1;
  }

  @override
  void setLooping(SoundHandle handle, bool enable) {
    return wasmModule.setLooping(handle.id, enable ? 1 : 0);
  }

  @override
  Duration getLoopPoint(SoundHandle handle) {
    return wasmModule.getLoopPoint(handle.id).toDuration();
  }

  @override
  void setLoopPoint(SoundHandle handle, Duration timestamp) {
    wasmModule.setLoopPoint(handle.id, timestamp.toDouble());
  }

  @override
  void setVisualizationEnabled(bool enabled) {
    wasmModule.setVisualizationEnabled(enabled ? 1 : 0);
  }

  @override
  bool getVisualizationEnabled() {
    return wasmModule.getVisualizationEnabled() == 1;
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
    wasmModule.setFftSmoothing(smooth);
  }

  @override
  void getAudioTexture(AudioData samples) {
    wasmModule.getAudioTexture(samples.ctrl.samplesPtr);
  }

  @override
  PlayerErrors getAudioTexture2D(AudioData samples) {
    final e = wasmModule.getAudioTexture2D(samples.ctrl.samplesPtr);
    return PlayerErrors.values[e];
  }

  @override
  Duration getLength(SoundHash soundHash) {
    return wasmModule.getLength(soundHash.hash).toDuration();
  }

  @override
  int seek(SoundHandle handle, Duration time) {
    return wasmModule.seek(handle.id, time.toDouble());
  }

  @override
  Duration getPosition(SoundHandle handle) {
    return wasmModule.getPosition(handle.id).toDuration();
  }

  @override
  double getGlobalVolume() {
    return wasmModule.getGlobalVolume();
  }

  @override
  int setGlobalVolume(double volume) {
    return wasmModule.setGlobalVolume(volume);
  }

  @override
  double getVolume(SoundHandle handle) {
    return wasmModule.getVolume(handle.id);
  }

  @override
  int setVolume(SoundHandle handle, double volume) {
    return wasmModule.setVolume(handle.id, volume);
  }

  @override
  bool getIsValidVoiceHandle(SoundHandle handle) {
    return wasmModule.getIsValidVoiceHandle(handle.id) == 1;
  }

  @override
  int getActiveVoiceCount() {
    return wasmModule.getActiveVoiceCount();
  }

  @override
  int countAudioSource(SoundHash soundHash) {
    return wasmModule.countAudioSource(soundHash.hash);
  }

  @override
  int getVoiceCount() {
    return wasmModule.getVoiceCount();
  }

  @override
  bool getProtectVoice(SoundHandle handle) {
    return wasmModule.getProtectVoice(handle.id) == 1;
  }

  @override
  void setProtectVoice(SoundHandle handle, bool protect) {
    return wasmModule.setProtectVoice(handle.id, protect ? 1 : 0);
  }

  @override
  int getMaxActiveVoiceCount() {
    return wasmModule.getMaxActiveVoiceCount();
  }

  @override
  void setMaxActiveVoiceCount(int maxVoiceCount) {
    return wasmModule.setMaxActiveVoiceCount(maxVoiceCount);
  }

  // ///////////////////////////////////////
  //  faders
  // ///////////////////////////////////////

  @override
  int fadeGlobalVolume(double to, Duration duration) {
    return wasmModule.fadeGlobalVolume(to, duration.toDouble());
  }

  @override
  int fadeVolume(SoundHandle handle, double to, Duration duration) {
    return wasmModule.fadeVolume(handle.id, to, duration.toDouble());
  }

  @override
  int fadePan(SoundHandle handle, double to, Duration duration) {
    return wasmModule.fadePan(handle.id, to, duration.toDouble());
  }

  @override
  int fadeRelativePlaySpeed(SoundHandle handle, double to, Duration time) {
    return wasmModule.fadeRelativePlaySpeed(handle.id, to, time.toDouble());
  }

  @override
  int schedulePause(SoundHandle handle, Duration duration) {
    return wasmModule.schedulePause(handle.id, duration.toDouble());
  }

  @override
  int scheduleStop(SoundHandle handle, Duration duration) {
    return wasmModule.scheduleStop(handle.id, duration.toDouble());
  }

  @override
  int oscillateVolume(
      SoundHandle handle, double from, double to, Duration time) {
    return wasmModule.oscillateVolume(handle.id, from, to, time.toDouble());
  }

  @override
  int oscillatePan(SoundHandle handle, double from, double to, Duration time) {
    return wasmModule.oscillatePan(handle.id, from, to, time.toDouble());
  }

  @override
  int oscillateRelativePlaySpeed(
      SoundHandle handle, double from, double to, Duration time) {
    return wasmModule.oscillateRelativePlaySpeed(handle.id, from, to, time.toDouble());
  }

  @override
  int oscillateGlobalVolume(double from, double to, Duration time) {
    return wasmModule.oscillateGlobalVolume(from, to, time.toDouble());
  }

  // ///////////////////////////////////////
  //  Filters
  // ///////////////////////////////////////

  @override
  ({PlayerErrors error, int index}) isFilterActive(int filterType) {
    // ignore: omit_local_variable_types
    final idPtr = wasmModule.malloc(4); // 4 bytes for an int
    final e = wasmModule.isFilterActive(filterType, idPtr);
    final ret = (error: PlayerErrors.values[e], index: wasmModule.getI32Value(idPtr, '*'));
    wasmModule.free(idPtr);
    return ret;
  }

  @override
  ({PlayerErrors error, List<String> names}) getFilterParamNames(
      int filterType) {
    final paramsCountPtr = wasmModule.malloc(4); // 4 bytes for an int
    final namesPtr = wasmModule.malloc(30 * 20); // list of 30 String with 20 chars
    final e = wasmModule.getFilterParamNames(filterType, paramsCountPtr, namesPtr);

    final pNames = <String>[];
    var offsetPtr = 0;
    for (var i = 0; i < wasmModule.getI32Value(paramsCountPtr, '*'); i++) {
      final namePtr = wasmModule.getI32Value(namesPtr + offsetPtr, '*');
      final name = wasmModule.utf8ToString(namePtr);
      offsetPtr += name.length;

      pNames.add(name);
    }

    final ret = (error: PlayerErrors.values[e], names: pNames);
    wasmModule.free(namesPtr);
    wasmModule.free(paramsCountPtr);
    return ret;
  }

  @override
  PlayerErrors addGlobalFilter(int filterType) {
    final e = wasmModule.addGlobalFilter(filterType);
    return PlayerErrors.values[e];
  }

  @override
  int removeGlobalFilter(int filterType) {
    return wasmModule.removeGlobalFilter(filterType);
  }

  @override
  int setFilterParams(int filterType, int attributeId, double value) {
    return wasmModule.setFxParams(filterType, attributeId, value);
  }

  @override
  double getFilterParams(int filterType, int attributeId) {
    return wasmModule.getFxParams(filterType, attributeId);
  }

  // //////////////////////////////////////
  // 3D audio methods
  // //////////////////////////////////////

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
    final handlePtr = wasmModule.malloc(4); // 4 bytes for an int
    final result = wasmModule.play3d(
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
    final newHandle = wasmModule.getI32Value(handlePtr, '*');
    final ret =
        (error: PlayerErrors.values[result], newHandle: SoundHandle(newHandle));
    wasmModule.free(handlePtr);

    return ret;
  }

  @override
  void set3dSoundSpeed(double speed) {
    return wasmModule.set3dSoundSpeed(speed);
  }

  @override
  double get3dSoundSpeed() {
    return wasmModule.get3dSoundSpeed();
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
    return wasmModule.set3dListenerParameters(
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
    return wasmModule.set3dListenerPosition(posX, posY, posZ);
  }

  @override
  void set3dListenerAt(double atX, double atY, double atZ) {
    return wasmModule.set3dListenerAt(atX, atY, atZ);
  }

  @override
  void set3dListenerUp(double upX, double upY, double upZ) {
    return wasmModule.set3dListenerUp(upX, upY, upZ);
  }

  @override
  void set3dListenerVelocity(
    double velocityX,
    double velocityY,
    double velocityZ,
  ) {
    return wasmModule.set3dListenerVelocity(velocityX, velocityY, velocityZ);
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
    return wasmModule.set3dSourceParameters(
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
    return wasmModule.set3dSourcePosition(handle.id, posX, posY, posZ);
  }

  @override
  void set3dSourceVelocity(
    SoundHandle handle,
    double velocityX,
    double velocityY,
    double velocityZ,
  ) {
    return wasmModule.set3dSourceVelocity(handle.id, velocityX, velocityY, velocityZ);
  }

  @override
  void set3dSourceMinMaxDistance(
    SoundHandle handle,
    double minDistance,
    double maxDistance,
  ) {
    return wasmModule.set3dSourceMinMaxDistance(handle.id, minDistance, maxDistance);
  }

  @override
  void set3dSourceAttenuation(
    SoundHandle handle,
    int attenuationModel,
    double attenuationRolloffFactor,
  ) {
    return wasmModule.set3dSourceAttenuation(
      handle.id,
      attenuationModel,
      attenuationRolloffFactor,
    );
  }

  @override
  void set3dSourceDopplerFactor(SoundHandle handle, double dopplerFactor) {
    return wasmModule.set3dSourceDopplerFactor(handle.id, dopplerFactor);
  }
}
