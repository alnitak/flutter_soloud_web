import 'package:flutter_soloud/src/bindings/soloud_controller.dart';
import 'package:flutter_soloud/src/exceptions/exceptions.dart';
import 'package:flutter_soloud/src/soloud.dart';
import 'package:flutter_soloud/src/bindings/audio_data_extensions.dart';
import 'package:flutter_soloud/src/soloud_capture.dart';
import 'package:meta/meta.dart';

import 'package:flutter_soloud/src/bindings/audio_data_ffi.dart'
    if (dart.library.html) 'audio_data_web.dart';

/// Enum to tell [AudioData] from where to get audio data.
enum GetSamplesFrom {
  /// Take data from the player.
  player,

  /// Take data from the microphone.
  microphone,
}

/// The way the audio data should be acquired.
enum GetSamplesKind {
  // If adding something here check [AudioData.isEmpty].

  /// Get data in a linear manner: the first 256 floats are audio FFI values,
  /// the other 256 are audio wave samples.
  linear,

  /// Get data in a 2D way. The resulting data will be a matrix of 256
  /// [linear] data. Each time the [AudioData.updateSamples] method is called,
  /// the last row is discarded and the new one will be the first.
  texture,
}

/// Class to manage audio samples.
///
/// The `visualization` must be enabled to be able to acquire data. You can
/// achieve this by calling `SoLoud.instance.setVisualizationEnabled(true);`.
///
/// Audio samples can be get from the player or from the microphone, and
/// in a texture matrix (2D) or a linear way (1D).
///
/// IMPORTANT: remember to call [dispose] method when there is no more need
/// to acquire audio.
///
/// After calling [updateSamples] is possible to call [get1D] or [get2D]
/// and have back the audio samples. For example using a "Ticker" in a Widget
/// that needs the audio data to be displayed:
/// ```
/// ...
/// late final Ticker ticker;
/// late final AudioData audioData;
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
/// late final double waveData;
/// late final double fftData;
/// try {
///   /// Use [get2D] if you have inizialized [AudioData]
///   /// with [GetSamplesKind.texture]
///   ffiData = audioData.get1D(i);
///   waveData = audioData.get1D(i+256);
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
// TODO(me):
//        add `getWave` and `getFFT`
//     JS imports in a standalone .dart using extension type
//     add capture exceptions
@experimental
class AudioData {
//   factory AudioData() => _instance ??= AudioData._();

//   AudioData._() : _ctrl = AudioDataCtrl() {
//     if (_getSamplesFrom == GetSamplesFrom.player) {
//   if (_getSamplesKind == GetSamplesKind.texture) {
//     _updateCallback = _ctrl.texture2DCallback;
//     _samples2D = _ctrl.allocSample2D();
//   } else {
//     _updateCallback = _ctrl.textureCallback;
//     _samples1D = _ctrl.allocSample1D();
//   }
// } else {
//   if (_getSamplesKind == GetSamplesKind.texture) {
//     _updateCallback = _ctrl.captureTexture2DCallback;
//     _samples2D = _ctrl.allocSample2D();
//   } else {
//     _updateCallback = _ctrl.captureAudioTextureCallback;
//     _samples1D = _ctrl.allocSample1D();
//   }
// }
//   }

  // static AudioData? _instance;

  /// Initialize the way the audio data should be acquired.
  AudioData(
    this._getSamplesFrom,
    this._getSamplesKind,
  ) : _ctrl = AudioDataCtrl() {
    if (_getSamplesFrom == GetSamplesFrom.player) {
      if (_getSamplesKind == GetSamplesKind.texture) {
        _updateCallback = _ctrl.texture2DCallback;
        _samples2D = _ctrl.allocSample2D();
      } else {
        _updateCallback = _ctrl.textureCallback;
        _samples1D = _ctrl.allocSample1D();
      }
    } else {
      if (_getSamplesKind == GetSamplesKind.texture) {
        _updateCallback = _ctrl.captureTexture2DCallback;
        _samples2D = _ctrl.allocSample2D();
      } else {
        _updateCallback = _ctrl.captureAudioTextureCallback;
        _samples1D = _ctrl.allocSample1D();
      }
    }
  }

  final AudioDataCtrl _ctrl;

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

  /// Update the content of samples memory to be get with [get1D] or [get2D].
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
    _ctrl.dispose(_samples1D, _samples2D);
  }

  /// Get the audio data at offset [offset].
  /// Use this method to get data when using [GetSamplesKind.linear].
  /// The first 256 float represents FFT data, the other 256 are wave data.
  double get1D(SampleOffset offset) {
    if (_getSamplesKind != GetSamplesKind.linear) return 0;

    if (!SoLoudController().soLoudFFI.getVisualizationEnabled()) {
      throw const SoLoudVisualizationNotEnabledException();
    }
    return _ctrl.get1D(_samples1D, offset.value);
  }

  /// Get the audio data at row [row] and column [column].
  /// Use this method to get data when using [GetSamplesKind.texture].
  /// This matrix represents 256 rows alike the [get1D] manages when
  /// using [GetSamplesKind.linear].
  /// Each time the [AudioData.updateSamples] method is called,
  /// the last row is discarded and the new one will be the first.
  double get2D(SampleRow row, SampleColumn column) {
    if (_getSamplesKind != GetSamplesKind.texture) return 0;

    if (!SoLoudController().soLoudFFI.getVisualizationEnabled()) {
      throw const SoLoudVisualizationNotEnabledException();
    }
    return _ctrl.get2D(_samples2D, row.value, column.value);
  }

  // Wether or not the current used data is empty.
  bool get isEmpty => _getSamplesKind == GetSamplesKind.texture
      ? _ctrl.isEmpty2D(_samples2D)
      : _ctrl.isEmpty1D(_samples1D);
}
