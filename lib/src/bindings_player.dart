import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_soloud/src/enums.dart';
import 'package:flutter_soloud/src/sound_hash.dart';
import 'package:flutter_soloud/src/sound_handle.dart';
import 'package:meta/meta.dart';

export 'package:flutter_soloud/src/bindings_player_ffi.dart'
    if (dart.library.html) 'package:flutter_soloud/src/bindings_player_web.dart';

/// Abstract class defining the interface for the platform-specific
/// implementations.
abstract class FlutterSoLoud {
  /// Controller to listen to voice ended events.
  late final StreamController<int> voiceEndedEventController =
      StreamController.broadcast();

  /// Listener for voices ended.
  Stream<int> get voiceEndedEvents => voiceEndedEventController.stream;

  /// Controller to listen to file loaded events.
  /// Not used on the web.
  late final StreamController<Map<String, dynamic>> fileLoadedEventsController =
      StreamController.broadcast();

  /// Listener for file loaded.
  /// Not used on the web.
  Stream<Map<String, dynamic>> get fileLoadedEvents =>
      fileLoadedEventsController.stream;

  /// Controller to listen to voice ended events.
  /// Not used on the web.
  @experimental
  late final StreamController<PlayerStateNotification> stateChangedController =
      StreamController.broadcast();

  /// listener for voices ended.
  /// Not used on the web.
  @experimental
  Stream<PlayerStateNotification> get stateChangedEvents =>
      stateChangedController.stream;

  /// Set Dart functions to call when an event occurs.
  ///
  /// On the web, only the `voiceEndedCallback` is supported. On the other
  /// platform there are also `fileLoadedCallback` and `stateChangedCallback`.
  @mustBeOverridden
  void setDartEventCallbacks();

  /// Initialize the player. Must be called before any other player functions.
  ///
  /// Returns [PlayerErrors.noError] if success.
  @mustBeOverridden
  PlayerErrors initEngine();

  /// Must be called when the player is no more needed or when closing the app.
  @mustBeOverridden
  void deinit();

  /// Gets the state of player
  ///
  /// Return true if initilized
  @mustBeOverridden
  bool isInited();

  /// Load a new sound to be played once or multiple times later.
  /// This is not supported on the web, use [loadMem] instead.
  ///
  /// After loading the file, the [_fileLoadedCallback] will call the
  /// Dart function defined with [_setDartEventCallback] which gives back
  /// the error and the new hash.
  ///
  /// [completeFileName] the complete file path.
  /// [LoadMode] if `LoadMode.memory`, Soloud::wav will be used which loads
  /// all audio data into memory. Used to prevent gaps or lags
  /// when seeking/starting a sound (less CPU, more memory allocated).
  /// If `LoadMode.disk` is used, the audio data is loaded
  /// from the given file when needed (more CPU, less memory allocated).
  /// See the [seek] note problem when using [LoadMode] = `LoadMode.disk`.
  /// `soundHash` return hash of the sound.
  @mustBeOverridden
  void loadFile(
    String completeFileName,
    LoadMode mode,
  );

  /// Load a new sound stored into [buffer] as file bytes to be played once
  /// or multiple times later.
  /// This is used on the web instead of [loadFile] because the browsers are
  /// not allowed to read files directly, but it works also on the other
  /// platforms.
  ///
  /// [uniqueName] the unique name of the sound. Used only to have the [hash].
  /// [buffer] the audio data. These contains the audio file bytes.
  @mustBeOverridden
  ({PlayerErrors error, SoundHash soundHash}) loadMem(
    String uniqueName,
    Uint8List buffer,
  );

  /// Load a new waveform to be played once or multiple times later.
  ///
  /// [waveform]
  /// [superWave]
  /// [scale]
  /// [detune]
  /// `soundHash` return hash of the sound.
  /// Returns [PlayerErrors.noError] if success.
  @mustBeOverridden
  ({PlayerErrors error, SoundHash soundHash}) loadWaveform(
    WaveForm waveform,
    bool superWave,
    double scale,
    double detune,
  );

  /// Set the scale of an already loaded waveform identified by [hash].
  ///
  /// [hash] the unique sound hash of a waveform sound.
  /// [newScale] the new scale of the wave.
  @mustBeOverridden
  void setWaveformScale(SoundHash hash, double newScale);

  /// Set the detune of an already loaded waveform identified by [hash].
  ///
  /// [hash] the unique sound hash of a waveform sound.
  /// [newDetune] the new detune of the wave.
  @mustBeOverridden
  void setWaveformDetune(SoundHash hash, double newDetune);

  /// Set a new frequency of an already loaded waveform identified by [hash].
  ///
  /// [hash] the unique sound hash of a waveform sound.
  /// [newFreq] the new frequence of the wave.
  @mustBeOverridden
  void setWaveformFreq(SoundHash hash, double newFreq);

  /// Set a new frequence of an already loaded waveform identified by [hash].
  ///
  /// [hash] the unique sound hash of a waveform sound.
  /// [superwave] 1 if using the super wave.
  @mustBeOverridden
  void setWaveformSuperWave(SoundHash hash, int superwave);

  /// Set a new wave form of an already loaded waveform identified by [hash].
  ///
  /// [hash] the unique sound hash of a waveform sound.
  /// [newWaveform] the new kind of [WaveForm] to be used.
  @mustBeOverridden
  void setWaveform(SoundHash hash, WaveForm newWaveform);

  /// Speech the text given.
  ///
  /// [textToSpeech] the text to be spoken.
  /// Returns [PlayerErrors.noError] if success and handle sound identifier.
  // TODO(marco): add other T2S parameters
  @mustBeOverridden
  ({PlayerErrors error, SoundHandle handle}) speechText(String textToSpeech);

  /// Switch pause state of an already loaded sound identified by [handle].
  ///
  /// [handle] the sound handle.
  @mustBeOverridden
  void pauseSwitch(SoundHandle handle);

  /// Pause or unpause already loaded sound identified by [handle].
  ///
  /// [handle] the sound handle.
  /// [pause] the new state.
  @mustBeOverridden
  void setPause(SoundHandle handle, int pause);

  /// Gets the pause state.
  ///
  /// [handle] the sound handle.
  /// Return true if paused.
  @mustBeOverridden
  bool getPause(SoundHandle handle);

  /// Set a sound's relative play speed.
  /// Setting the value to 0 will cause undefined behavior, likely a crash.
  /// Change the relative play speed of a sample. This changes the effective
  /// sample rate while leaving the base sample rate alone.
  ///
  /// Note that playing a sound at a higher sample rate will require SoLoud
  /// to request more samples from the sound source, which will require more
  /// memory and more processing power. Playing at a slower sample
  /// rate is cheaper.
  ///
  /// [handle] the sound handle.
  /// [speed] the new speed.
  @mustBeOverridden
  void setRelativePlaySpeed(SoundHandle handle, double speed);

  /// Return the current play speed.
  ///
  /// [handle] the sound handle.
  @mustBeOverridden
  double getRelativePlaySpeed(SoundHandle handle);

  /// Play already loaded sound identified by [soundHash].
  ///
  /// [soundHash] the unique sound hash of a sound.
  /// [volume] 1.0 full volume.
  /// [pan] 0.0 centered.
  /// [paused] false not paused.
  /// [looping] whether to start the sound in looping state.
  /// [loopingStartAt] If looping is enabled, the loop point is, by default,
  /// the start of the stream. The loop start point can be set with this
  /// parameter, and current loop point can be queried with `getLoopingPoint()`
  /// and changed by `setLoopingPoint()`.
  /// Return the error if any and a new `newHandle` of this sound.
  @mustBeOverridden
  ({PlayerErrors error, SoundHandle newHandle}) play(
    SoundHash soundHash, {
    double volume = 1,
    double pan = 0,
    bool paused = false,
    bool looping = false,
    Duration loopingStartAt = Duration.zero,
  });

  /// Stop already loaded sound identified by [handle] and clear it.
  ///
  /// [handle] the sound handle.
  @mustBeOverridden
  void stop(SoundHandle handle);

  /// Stop all handles of the already loaded sound identified
  /// by [soundHash] and dispose it.
  ///
  /// [soundHash] the unique sound hash of a sound.
  @mustBeOverridden
  void disposeSound(SoundHash soundHash);

  /// Dispose all sounds already loaded.
  @mustBeOverridden
  void disposeAllSound();

  /// Query whether a sound is set to loop.
  ///
  /// [handle] the sound handle.
  /// Returns true if flagged for looping.
  @mustBeOverridden
  bool getLooping(SoundHandle handle);

  /// This function can be used to set a sample to play on repeat,
  /// instead of just playing it once.
  ///
  /// [handle] the sound handle.
  /// [enable] enable or not the looping.
  @mustBeOverridden
  void setLooping(SoundHandle handle, bool enable);

  /// Get sound loop point value.
  ///
  /// [handle] the sound handle.
  /// Returns the duration.
  @mustBeOverridden
  Duration getLoopPoint(SoundHandle handle);

  /// Set sound loop point value.
  ///
  /// [handle] the sound handle.
  /// [timestamp] the time in which the loop will restart.
  @mustBeOverridden
  void setLoopPoint(SoundHandle handle, Duration timestamp);

  // TODO(marco): implement Soloud.getLoopCount() also?

  /// Enable or disable visualization.
  /// Not yet supported on the web.
  ///
  /// [enabled] whether to enable or disable.
  @mustBeOverridden
  void setVisualizationEnabled(bool enabled);

  /// Get visualization state.
  /// Not yet supported on the web.
  ///
  /// Return true if enabled.
  @mustBeOverridden
  bool getVisualizationEnabled();

  /// Returns valid data only if VisualizationEnabled is true.
  /// Not yet supported on the web.
  ///
  /// [fft] on all platforms web excluded, the [fft] type is `Pointer<Float>`.
  /// Return a 256 float array int the [fft] pointer containing FFT data.
  @mustBeOverridden
  void getFft(dynamic fft);

  /// Returns valid data only if VisualizationEnabled is true
  ///
  /// [wave] on all platforms web excluded, the [wave] type is `Pointer<Float>`.
  /// Return a 256 float array int the [wave] pointer containing audio data.
  @mustBeOverridden
  void getWave(dynamic wave);

  /// Smooth FFT data.
  /// Not yet supported on the web.
  ///
  /// When new data is read and the values are decreasing, the new value will be
  /// decreased with an amplitude between the old and the new value.
  /// This will result on a less shaky visualization.
  ///
  /// [smooth] must be in the [0.0 ~ 1.0] range.
  /// 0 = no smooth
  /// 1 = full smooth
  /// the new value is calculated with:
  /// newFreq = smooth * oldFreq + (1 - smooth) * newFreq
  @mustBeOverridden
  void setFftSmoothing(double smooth);

  /// Return in [samples] a 512 float array.
  /// The first 256 floats represent the FFT frequencies data [>=0.0].
  /// The other 256 floats represent the wave data (amplitude) [-1.0~1.0].
  /// Not yet supported on the web.
  ///
  /// [samples] on all platforms web excluded, the [samples] type is
  /// `Pointer<Float>`.
  @mustBeOverridden
  void getAudioTexture(dynamic samples);

  /// Return a floats matrix of 256x512
  /// Every row are composed of 256 FFT values plus 256 of wave data
  /// Every time is called, a new row is stored in the
  /// first row and all the previous rows are shifted
  /// up and the last one will be lost.
  ///
  /// [samples] on all platforms web excluded, the [samples] type is
  /// `Pointer<Pointer<Float>>`.
  @mustBeOverridden
  PlayerErrors getAudioTexture2D(dynamic samples);

  /// Get the sound length.
  ///
  /// [soundHash] the sound hash.
  /// Returns sound length.
  @mustBeOverridden
  Duration getLength(SoundHash soundHash);

  /// Seek playing to [time] position.
  ///
  /// [time] the time position to seek to.
  /// [handle] the sound handle.
  /// Returns [PlayerErrors.noError] if success.
  ///
  /// NOTE: when seeking an MP3 file loaded using `mode`=`LoadMode.disk` the
  /// seek operation is performed but there will be delays. This occurs because
  /// the MP3 codec must compute each frame length to gain a new position.
  /// The problem is explained in souloud_wavstream.cpp
  /// in `WavStreamInstance::seek` function.
  ///
  /// This mode is useful ie for background music, not for a music player
  /// where a seek slider for MP3s is a must.
  /// If you need to seek MP3s without lags, please, use
  /// `mode`=`LoadMode.memory` instead or other supported audio formats!
  @mustBeOverridden
  int seek(SoundHandle handle, Duration time);

  /// Get current sound position..
  ///
  /// [handle] the sound handle.
  /// Returns time position.
  @mustBeOverridden
  Duration getPosition(SoundHandle handle);

  /// Get current Global volume.
  ///
  /// Returns the volume.
  @mustBeOverridden
  double getGlobalVolume();

  /// Set current Global volume.
  ///
  /// Returns [PlayerErrors.noError] if success.
  @mustBeOverridden
  int setGlobalVolume(double volume);

  /// Get current [handle] volume.
  ///
  /// Returns the volume.
  @mustBeOverridden
  double getVolume(SoundHandle handle);

  /// Set current [handle] volume.
  ///
  /// Returns [PlayerErrors.noError] if success.
  @mustBeOverridden
  int setVolume(SoundHandle handle, double volume);

  /// Check if the [handle] is still valid.
  ///
  /// [handle] handle to check.
  /// Return true if it still exists.
  @mustBeOverridden
  bool getIsValidVoiceHandle(SoundHandle handle);

  /// Returns the number of concurrent sounds that are playing at the moment.
  @mustBeOverridden
  int getActiveVoiceCount();

  /// Returns the number of concurrent sounds that are playing a
  /// specific audio source.
  @mustBeOverridden
  int countAudioSource(SoundHash soundHash);

  /// Returns the number of voices the application has told SoLoud to play.
  @mustBeOverridden
  int getVoiceCount();

  /// Get a sound's protection state.
  @mustBeOverridden
  bool getProtectVoice(SoundHandle handle);

  /// Set a sound's protection state.
  ///
  /// Normally, if you try to play more sounds than there are voices,
  /// SoLoud will kill off the oldest playing sound to make room.
  /// This will most likely be your background music. This can be worked
  /// around by protecting the sound.
  /// If all voices are protected, the result will be undefined.
  ///
  /// [handle] handle to check.
  /// [protect] whether to protect or not.
  @mustBeOverridden
  void setProtectVoice(SoundHandle handle, bool protect);

  /// Get the current maximum active voice count.
  @mustBeOverridden
  int getMaxActiveVoiceCount();

  /// Set the current maximum active voice count.
  /// If voice count is higher than the maximum active voice count,
  /// SoLoud will pick the ones with the highest volume to actually play.
  /// [maxVoiceCount] the max concurrent sounds that can be played.
  ///
  /// NOTE: The number of concurrent voices is limited, as having unlimited
  /// voices would cause performance issues, as well as lead to unnecessary
  /// clipping. The default number of concurrent voices is 16, but this can be
  /// adjusted at runtime. The hard maximum number is 4095, but if more are
  /// required, SoLoud can be modified to support more. But seriously, if you
  /// need more than 4095 sounds at once, you're probably going to make
  /// some serious changes in any case.
  @mustBeOverridden
  void setMaxActiveVoiceCount(int maxVoiceCount);

  /////////////////////////////////////////
  /// faders
  /////////////////////////////////////////

  /// Smoothly change the global volume over specified [duration].
  @mustBeOverridden
  int fadeGlobalVolume(double to, Duration duration);

  /// Smoothly change a channel's volume over specified [duration].
  @mustBeOverridden
  int fadeVolume(SoundHandle handle, double to, Duration duration);

  /// Smoothly change a channel's pan setting over specified [duration].
  @mustBeOverridden
  int fadePan(SoundHandle handle, double to, Duration duration);

  /// Smoothly change a channel's relative play speed over specified time.
  @mustBeOverridden
  int fadeRelativePlaySpeed(SoundHandle handle, double to, Duration time);

  /// After specified [duration], pause the channel.
  @mustBeOverridden
  int schedulePause(SoundHandle handle, Duration duration);

  /// After specified time, stop the channel.
  @mustBeOverridden
  int scheduleStop(SoundHandle handle, Duration duration);

  /// Set fader to oscillate the volume at specified frequency.
  @mustBeOverridden
  int oscillateVolume(
      SoundHandle handle, double from, double to, Duration time);

  /// Set fader to oscillate the panning at specified frequency.
  @mustBeOverridden
  int oscillatePan(SoundHandle handle, double from, double to, Duration time);

  /// Set fader to oscillate the relative play speed at specified frequency.
  @mustBeOverridden
  int oscillateRelativePlaySpeed(
      SoundHandle handle, double from, double to, Duration time);

  /// Set fader to oscillate the global volume at specified frequency.
  @mustBeOverridden
  int oscillateGlobalVolume(double from, double to, Duration time);

  /////////////////////////////////////////
  /// Filters
  /////////////////////////////////////////

  /// Check if the given filter is active or not.
  ///
  /// [filterType] filter to check.
  /// Returns [PlayerErrors.noError] if no errors and the index of
  /// the active filter (-1 if the filter is not active).
  @mustBeOverridden
  ({PlayerErrors error, int index}) isFilterActive(int filterType);

  /// Get parameters names of the given filter.
  ///
  /// [filterType] filter to get param names.
  /// Returns [PlayerErrors.noError] if no errors and the list of param names.
  @mustBeOverridden
  ({PlayerErrors error, List<String> names}) getFilterParamNames(
      int filterType);

  /// Add the filter [filterType].
  ///
  /// [filterType] filter to add.
  /// Returns:
  /// [PlayerErrors.noError] if no errors.
  /// [PlayerErrors.filterNotFound] if the [filterType] does not exits.
  /// [PlayerErrors.filterAlreadyAdded] when trying to add an already
  /// added filter.
  /// [PlayerErrors.maxNumberOfFiltersReached] when the maximum number of
  /// filters has been reached (default is 8).
  @mustBeOverridden
  PlayerErrors addGlobalFilter(int filterType);

  /// Remove the filter [filterType].
  ///
  /// [filterType] filter to remove.
  /// Returns [PlayerErrors.noError] if no errors.
  @mustBeOverridden
  int removeGlobalFilter(int filterType);

  /// Set the effect parameter with id [attributeId] of [filterType]
  /// with [value] value.
  ///
  /// [filterType] filter to modify a param.
  /// Returns [PlayerErrors.noError] if no errors.
  @mustBeOverridden
  int setFilterParams(int filterType, int attributeId, double value);

  /// Get the effect parameter with id [attributeId] of [filterType].
  ///
  /// [filterType] the filter to modify a parameter.
  /// Returns the value of the parameter.
  @mustBeOverridden
  double getFilterParams(int filterType, int attributeId);

  /////////////////////////////////////////
  /// 3D audio methods
  /////////////////////////////////////////

  /// play3d() is the 3d version of the play() call.
  ///
  /// [posX], [posY], [posZ] are the audio source position coordinates.
  /// [velX], [velY], [velZ] are the audio source velocity.
  /// [looping] whether to start the sound in looping state.
  /// [loopingStartAt] If looping is enabled, the loop point is, by default,
  /// the start of the stream. The loop start point can be set with this
  /// parameter, and current loop point can be queried with `getLoopingPoint()`
  /// and changed by `setLoopingPoint()`.
  /// Returns the handle of the sound, 0 if error.
  @mustBeOverridden
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
  });

  /// Since SoLoud has no knowledge of the scale of your coordinates,
  /// you may need to adjust the speed of sound for these effects
  /// to work correctly. The default value is 343, which assumes
  /// that your world coordinates are in meters (where 1 unit is 1 meter),
  /// and that the environment is dry air at around 20 degrees Celsius.
  @mustBeOverridden
  void set3dSoundSpeed(double speed);

  /// Get the sound speed.
  @mustBeOverridden
  double get3dSoundSpeed();

  /// You can set the position, at-vector, up-vector and velocity parameters
  /// of the 3d audio listener with one call.
  @mustBeOverridden
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
  );

  /// You can set the position parameter of the 3d audio listener.
  @mustBeOverridden
  void set3dListenerPosition(double posX, double posY, double posZ);

  /// You can set the "at" vector parameter of the 3d audio listener.
  @mustBeOverridden
  void set3dListenerAt(double atX, double atY, double atZ);

  /// You can set the "up" vector parameter of the 3d audio listener.
  @mustBeOverridden
  void set3dListenerUp(double upX, double upY, double upZ);

  /// You can set the listener's velocity vector parameter.
  @mustBeOverridden
  void set3dListenerVelocity(
    double velocityX,
    double velocityY,
    double velocityZ,
  );

  /// You can set the position and velocity parameters of a live
  /// 3d audio source with one call.
  @mustBeOverridden
  void set3dSourceParameters(
    SoundHandle handle,
    double posX,
    double posY,
    double posZ,
    double velocityX,
    double velocityY,
    double velocityZ,
  );

  /// You can set the position parameters of a live 3d audio source.
  @mustBeOverridden
  void set3dSourcePosition(
    SoundHandle handle,
    double posX,
    double posY,
    double posZ,
  );

  /// You can set the velocity parameters of a live 3d audio source.
  @mustBeOverridden
  void set3dSourceVelocity(
    SoundHandle handle,
    double velocityX,
    double velocityY,
    double velocityZ,
  );

  /// You can set the minimum and maximum distance parameters
  /// of a live 3d audio source.
  @mustBeOverridden
  void set3dSourceMinMaxDistance(
    SoundHandle handle,
    double minDistance,
    double maxDistance,
  );

  /// You can change the attenuation model and rolloff factor parameters of
  /// a live 3d audio source.
  ///
  /// NO_ATTENUATION 	      No attenuation
  /// INVERSE_DISTANCE 	    Inverse distance attenuation model
  /// LINEAR_DISTANCE 	    Linear distance attenuation model
  /// EXPONENTIAL_DISTANCE 	Exponential distance attenuation model
  ///
  /// see https://solhsa.com/soloud/concepts3d.html
  @mustBeOverridden
  void set3dSourceAttenuation(
    SoundHandle handle,
    int attenuationModel,
    double attenuationRolloffFactor,
  );

  /// You can change the doppler factor of a live 3d audio source.
  @mustBeOverridden
  void set3dSourceDopplerFactor(SoundHandle handle, double dopplerFactor);
}

/// Used for easier conversion from [double] to [Duration].
extension DoubleToDuration on double {
  Duration toDuration() {
    return Duration(
        microseconds: (this * Duration.microsecondsPerSecond).round());
  }
}

/// Used for easier conversion from [Duration] to [double].
extension DurationToDouble on Duration {
  double toDouble() {
    return inMicroseconds / Duration.microsecondsPerSecond;
  }
}
