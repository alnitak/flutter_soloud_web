import 'package:flutter_soloud/src/bindings/soloud_controller.dart';
import 'package:flutter_soloud/src/exceptions/exceptions.dart';
import 'package:flutter_soloud/src/soloud.dart';
import 'package:flutter_soloud/src/bindings/audio_data_extensions.dart';
import 'package:flutter_soloud/src/soloud_capture.dart';
import 'package:meta/meta.dart';

import 'package:flutter_soloud/src/bindings/audio_data_ffi.dart'
    if (dart.library.html) 'audio_data_web.dart';

/// Enum to tell [AudioData] from where to get audio data.
/// Every time [AudioData.updateSamples] is called, the audio data will
/// be acquired by the respective device.
enum GetSamplesFrom {
  /// Take data from the player.
  player,

  /// Take data from the microphone.
  microphone,
}

/// The way the audio data should be acquired.
/// 
/// Every time [AudioData.updateSamples] is called is possible to query the
/// acquired new audio data using respectively [AudioData.getLinear],
/// [AudioData.getTexture] and [AudioData.getWave].
enum GetSamplesKind {
  /// Get data in a linear manner: the first 256 floats are audio FFI values,
  /// the other 256 are audio wave samples.
  /// To get audio data use [AudioData.getLinear].
  linear,

  /// Get data in a 2D way. The resulting data will be a matrix of 256
  /// [linear] rows. Each time the [AudioData.updateSamples] method is called,
  /// the last row is discarded and the new one will be the first.
  /// To get audio data use [AudioData.getTexture].
  texture,

  /// Get the 256 float of wave audio data.
  /// To get audio data use [AudioData.getWave].
  wave,
}

/// Class to manage audio samples.
///
/// The `visualization` must be enabled to be able to acquire data. You can
/// achieve this by calling `SoLoud.instance.setVisualizationEnabled(true);`.
///
/// Audio samples can be get from the player or from the microphone, and
/// in a texture matrix or a linear array way.
///
/// IMPORTANT: remember to call [dispose] method when there is no more need
/// to acquire audio.
///
/// After calling [updateSamples] is possible to call [getLinear] or [getTexture]
/// and have back the audio samples. For example using a "Ticker" in a Widget
/// that needs the audio data to be displayed:
/// ```
/// ...
/// late final Ticker ticker;
/// late final AudioData audioData;
/// late final double waveData;
/// late final double fftData;
///
/// @override
/// void initState() {
///   super.initState();
///   audioData = AudioData(GetSamplesFrom.player, GetSamplesKind.linear);
///   ticker = createTicker(_tick);
///   ticker.start();
/// }
///
/// @override
/// void dispose() {
///   ticker.stop();
///   audioData.dispose();
///   super.dispose();
/// }
///
/// void _tick(Duration elapsed) {
///   if (context.mounted) {
///     try {
///       audioData.updateSamples();
///       setState(() {});
///     } on Exception {
///       debugPrint('Player not initialized or visualization is not enabled!');
///     }
///   }
/// }
/// ```
/// Then in your "build" method, you can read the audio data:
/// ```
/// try {
///   /// Use [getTexture] if you have inizialized [AudioData]
///   /// with [GetSamplesKind.texture]
///   ffiData = audioData.getLinear(i);
///   waveData = audioData.getLinear(i+256);
/// } on Exception {
///   ffiData = 0;
///   waveData = 0;
/// }
/// ```
///
/// To smooth FFT value use [SoLoud.instance.setFftSmoothing] or
/// [SoLoudCapture.instance.setCaptureFftSmoothing].
///
///
// TODO(): make AudioData singleton?
//     add capture exceptions
//    fix worker.dart
@experimental
class AudioData {
  /// Initialize the way the audio data should be acquired.
  AudioData(
    this._getSamplesFrom,
    this._getSamplesKind,
  ) : ctrl = AudioDataCtrl() {
    // if (_getSamplesFrom == GetSamplesFrom.player) {
    //   if (_getSamplesKind == GetSamplesKind.texture) {
    //     _updateCallback = ctrl.texture2DCallback;
    //     _samples2D = ctrl.allocSample2D();
    //   } else {
    //     _updateCallback = ctrl.textureCallback;
    //     _samples1D = ctrl.allocSample1D();
    //   }
    // } else {
    //   if (_getSamplesKind == GetSamplesKind.texture) {
    //     _updateCallback = ctrl.captureTexture2DCallback;
    //     _samples2D = ctrl.allocSample2D();
    //   } else {
    //     _updateCallback = ctrl.captureAudioTextureCallback;
    //     _samples1D = ctrl.allocSample1D();
    //   }
    // }
    switch (_getSamplesFrom) {
      case GetSamplesFrom.player:
        switch (_getSamplesKind) {
          case GetSamplesKind.linear:
            _updateCallback = ctrl.textureCallback;
            _samples1D = ctrl.allocSample1D();
          case GetSamplesKind.texture:
            _updateCallback = ctrl.texture2DCallback;
            _samples2D = ctrl.allocSample2D();
          case GetSamplesKind.wave:
            _updateCallback = ctrl.waveCallback;
            _samplesWave = ctrl.allocSampleWave();
        }
      case GetSamplesFrom.microphone:
        switch (_getSamplesKind) {
          case GetSamplesKind.linear:
            _updateCallback = ctrl.captureAudioTextureCallback;
            _samples1D = ctrl.allocSample1D();
          case GetSamplesKind.texture:
            _updateCallback = ctrl.captureTexture2DCallback;
            _samples2D = ctrl.allocSample2D();
          case GetSamplesKind.wave:
            _updateCallback = ctrl.captureWaveCallback;
            _samplesWave = ctrl.allocSampleWave();
        }
    }
  }

  @internal
  final AudioDataCtrl ctrl;

  /// Where the FFT or wave data is stored.
  late final SampleFormat2D _samplesWave;

  /// The getter for [_samplesWave].
  @internal
  SampleFormat2D get samplesWave => _samplesWave;

  /// Where the audio 2D data is stored.
  late final SampleFormat2D _samples2D;

  /// The getter for [_samples2D].
  @internal
  SampleFormat2D get samples2D => _samples2D;

  /// Where the audio 1D data is stored.
  late final SampleFormat1D _samples1D;

  /// The getter for [_samples1D].
  @internal
  SampleFormat1D get samples1D => _samples1D;

  /// Where to get audio samples. See [GetSamplesFrom].
  final GetSamplesFrom _getSamplesFrom;
  GetSamplesFrom get getSamplesFrom => _getSamplesFrom;

  /// Kind of audio samples. See [GetSamplesKind].
  final GetSamplesKind _getSamplesKind;
  GetSamplesKind get getSamplesKind => _getSamplesKind;

  /// The callback used to get new audio samples.
  /// This callback is used in [updateSamples] to avoid to
  /// do the [GetSamplesFrom] and [GetSamplesKind] checks on every calls.
  late void Function(AudioData) _updateCallback;

  /// Update the content of samples memory to be get with [getLinear] or [getTexture].
  ///
  /// Throws [SoLoudNotInitializedException] if the engine is not initialized.
  /// Throws [SoLoudVisualizationNotEnabledException] if the visualization
  /// flag is not enableb. Please, Use `setVisualizationEnabled(true)`
  /// when needed.
  /// Throws [SoLoudNullPointerException] something is going wrong with the
  /// player engine. Please, open an issue on
  /// [GitHub](https://github.com/alnitak/flutter_soloud/issues) providing
  /// a simple working example.
  void updateSamples() {
    if (!SoLoud.instance.isInitialized) {
      throw const SoLoudNotInitializedException();
    }
    if (!SoLoudController().soLoudFFI.getVisualizationEnabled()) {
      throw const SoLoudVisualizationNotEnabledException();
    }
    _updateCallback(this);
  }

  /// Dispose the memory allocated to acquire audio data.
  /// Must be called when there is no more need of [AudioData].
  void dispose() {
    ctrl.dispose(_samples1D, _samples2D);
  }

  double getWave(SampleWave offset) {
    if (_getSamplesKind != GetSamplesKind.wave) return 0;

    if (!SoLoudController().soLoudFFI.getVisualizationEnabled()) {
      throw const SoLoudVisualizationNotEnabledException();
    }
    return ctrl.getWave(_samplesWave, offset);
  }

  /// Get the audio data at offset [offset].
  /// Use this method to get data when using [GetSamplesKind.linear].
  /// The first 256 float represents FFT data, the other 256 are wave data.
  double getLinear(SampleLinear offset) {
    if (_getSamplesKind != GetSamplesKind.linear) return 0;

    if (!SoLoudController().soLoudFFI.getVisualizationEnabled()) {
      throw const SoLoudVisualizationNotEnabledException();
    }
    return ctrl.getLinear(_samples1D, offset);
  }

  /// Get the audio data at row [row] and column [column].
  /// Use this method to get data when using [GetSamplesKind.texture].
  /// This matrix represents 256 rows alike the [getLinear] manages when
  /// using [GetSamplesKind.linear].
  /// Each time the [AudioData.updateSamples] method is called,
  /// the last row is discarded and the new one will be the first.
  double getTexture(SampleRow row, SampleColumn column) {
    if (_getSamplesKind != GetSamplesKind.texture) return 0;

    if (!SoLoudController().soLoudFFI.getVisualizationEnabled()) {
      throw const SoLoudVisualizationNotEnabledException();
    }
    return ctrl.getTexture(_samples2D, row, column);
  }

  // Wether or not the current used data is empty.
  bool get isEmpty => _getSamplesKind == GetSamplesKind.texture
      ? ctrl.isEmptyTexture(_samples2D)
      : _getSamplesKind == GetSamplesKind.linear
          ? ctrl.isEmptyLinear(_samples1D)
          : ctrl.isEmptyTexture(_samplesWave); // GetSamplesKind.wave
}
