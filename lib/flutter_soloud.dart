import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/src/audio_source.dart';
import 'package:flutter_soloud/src/filter_params.dart';
import 'package:flutter_soloud/src/bindings/soloud_controller.dart';
import 'package:flutter_soloud/src/sound_hash.dart';
import 'package:flutter_soloud/src/enums.dart';
import 'package:flutter_soloud/src/sound_handle.dart';

import 'flutter_soloud_platform_interface.dart';

/// To be replaced with soloud.dart
class FlutterSoloudWeb {
  final _controller = SoLoudController();
  Future<String?> getPlatformVersion() async {
    return FlutterSoloudPlatform.instance.getPlatformVersion();
  }

  PlayerErrors init() {
    final ret = _controller.soLoudFFI.initEngine();
    SoLoudController().soLoudFFI.setDartEventCallbacks();

    debugPrint('***************** INIT  result: $ret');
    return ret;
  }

  void sendMessage(String message, int value) {
    // SoLoudController().soLoudFFI.sendMessageToWasmWorker(message, value);
  }

  bool isInited() {
    return _controller.soLoudFFI.isInited();
  }

  void deinit() {
    _controller.soLoudFFI.deinit();
  }

  /// Reading a local file on web is not possible. Use [loadMem] instead
  // AudioSource loadFile(
  //   String path, {
  //   LoadMode mode = LoadMode.memory,
  // }) {
  //   var ret = _controller.soLoudFFI.loadFile(path, mode);
  //   return AudioSource(ret.soundHash);
  // }

  /// On web the audio file must be loaded in memory first and then passed
  /// as [bytes].
  /// Here the [path] is used only as a reference to compute its hash.
  Future<AudioSource> loadMem(String path, Uint8List bytes) async {
    var ret = _controller.soLoudFFI.loadMem(path, bytes);

    var b = SoLoudController().soLoudFFI.isInited();

    debugPrint('***************** LOADMEM $b   result: $ret');

    return AudioSource(ret.soundHash);
  }

  Future<AudioSource> loadWaveform(WaveForm waveform,
    bool superWave,
    double scale,
    double detune,) async{
    final ret =
        _controller.soLoudFFI.loadWaveform(WaveForm.fSaw, true, 0.25, 1);
    AudioSource newSound = AudioSource(ret.soundHash);

    print('LOAD WAVEFORM $ret');
    return newSound;
  }

  Future<SoundHandle> play(AudioSource sound) async{
    var ret = _controller.soLoudFFI.play(sound.soundHash);
    print('PLAY $ret');
    return ret.newHandle;
  }

  bool getIsValidVoiceHandle(SoundHandle handle) {
    print('GET IS VALID1');
    var ret = _controller.soLoudFFI.getIsValidVoiceHandle(handle);
    print('GET IS VALID $ret');
    return ret;
  }

  ({PlayerErrors error, List<String> names}) getFilterParamNames(
      FilterType filterType) {
    final ret = _controller.soLoudFFI.getFilterParamNames(filterType.index);
    print(ret);
    return ret;
  }
}
