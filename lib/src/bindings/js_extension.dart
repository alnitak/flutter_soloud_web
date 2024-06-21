import 'dart:js_interop';
import 'package:web/web.dart' as web;

@JS()
external $Module get wasmModule;

@JS()
extension type $Module._(JSObject _) implements JSObject {
  @JS('Module._malloc')
  external int malloc(int bytesCount);

  @JS('Module._free')
  external void free(int ptrAddress);

  @JS('Module.getValue')
  external int getI32Value(int ptrAddress, String type);

  @JS('Module.getValue')
  external double getF32Value(int ptrAddress, String type);

  @JS('Module.UTF8ToString')
  external String utf8ToString(int ptrAddress);

  @JS('Module.setValue')
  external void setValue(int ptrAddress, int value, String type);

  @JS('Module.cwrap')
  external JSFunction cwrap(
    JSString fName,
    JSString returnType,
    JSArray<JSString> argTypes,
  );

  @JS('Module.ccall')
  external JSFunction ccall(
    JSString fName,
    JSString returnType,
    JSArray<JSString> argTypes,
    JSArray<JSAny> args,
  );

  @JS('Module._createWorkerInWasm')
  external void createWorkerInWasm();

  @JS('Module._sendToWorker')
  external void sendToWorker(int message, int value);

  @JS('Module.worker')
  external web.Worker wasmWorker;

  @JS('Module._initEngine')
  external int initEngine();

  @JS('Module._dispose')
  external void deinit();

  @JS('Module._isInited')
  external int isInited();

  @JS('Module._loadFile')
  external int loadFile(int completeFileNamePtr, int loadIntoMem, int hashPtr);

  @JS('Module._loadMem')
  external int loadMem(
    int uniqueNamePtr,
    int memPtr,
    int length,
    int hashPtr,
  );
  @JS('Module._loadWaveform')
  external int loadWaveform(
      int waveform, bool superWave, double scale, double detune, int hashPtr);

  @JS('Module._setWaveformScale')
  external void setWaveformScale(int soundHash, double newScale);

  @JS('Module._setWaveformDetune')
  external void setWaveformDetune(int soundHash, double newDetune);

  @JS('Module._setWaveformFreq')
  external void setWaveformFreq(int soundHash, double newFreq);

  @JS('Module._setSuperWave')
  external void setSuperWave(int soundHash, int superwave);

  @JS('Module._setWaveform')
  external void setWaveform(int soundHash, int newWaveform);

  @JS('Module._speechText')
  external int speechText(int textToSpeechPtr, int handlePtr);

  @JS('Module._pauseSwitch')
  external void pauseSwitch(int handle);

  @JS('Module._setPause')
  external void setPause(int handle, int pause);

  @JS('Module._getPause')
  external int getPause(int handle);

  @JS('Module._setRelativePlaySpeed')
  external void setRelativePlaySpeed(int handle, double speed);

  @JS('Module._getRelativePlaySpeed')
  external double getRelativePlaySpeed(int handle);

  @JS('Module._play')
  external int play(int soundHash, double volume, double pan, bool paused,
      bool looping, double loopingStartAt, int handlePtr);

  @JS('Module._stop')
  external void stop(int handle);

  @JS('Module._disposeSound')
  external void disposeSound(int soundHash);

  @JS('Module._disposeAllSound')
  external void disposeAllSound();

  @JS('Module._getLooping')
  external int getLooping(int handle);

  @JS('Module._setLooping')
  external void setLooping(int handle, int enable);

  @JS('Module._getLoopPoint')
  external double getLoopPoint(int handle);

  @JS('Module._setLoopPoint')
  external void setLoopPoint(int handle, double time);

  @JS('Module._setVisualizationEnabled')
  external void setVisualizationEnabled(int enabled);

  @JS('Module._getVisualizationEnabled')
  external int getVisualizationEnabled();

  @JS('Module._setFftSmoothing')
  external void setFftSmoothing(double smooth);

  @JS('Module._getAudioTexture')
  external void getAudioTexture(int samplesPtr);

  @JS('Module._getAudioTexture2D')
  external int getAudioTexture2D(int samplesPtr);

  @JS('Module._getCaptureAudioTexture')
  external void getCaptureAudioTexture(int samplesPtr);

  @JS('Module._getCaptureAudioTexture2D')
  external int getCaptureAudioTexture2D(int samplesPtr);

  @JS('Module._setCaptureFftSmoothing')
  external int setCaptureFftSmoothing(double smooth);

  @JS('Module._getLength')
  external double getLength(int soundHash);

  @JS('Module._seek')
  external int seek(int handle, double time);

  @JS('Module._getPosition')
  external double getPosition(int handle);

  @JS('Module._getGlobalVolume')
  external double getGlobalVolume();

  @JS('Module._setGlobalVolume')
  external int setGlobalVolume(double volume);

  @JS('Module._getVolume')
  external double getVolume(int handle);

  @JS('Module._setVolume')
  external int setVolume(int handle, double volume);

  @JS('Module._getIsValidVoiceHandle')
  external int getIsValidVoiceHandle(int handle);

  @JS('Module._getActiveVoiceCount')
  external int getActiveVoiceCount();

  @JS('Module._countAudioSource')
  external int countAudioSource(int soundHash);

  @JS('Module._getVoiceCount')
  external int getVoiceCount();

  @JS('Module._getProtectVoice')
  external int getProtectVoice(int handle);

  @JS('Module._setProtectVoice')
  external void setProtectVoice(int handle, int protect);

  @JS('Module._getMaxActiveVoiceCount')
  external int getMaxActiveVoiceCount();

  @JS('Module._setMaxActiveVoiceCount')
  external void setMaxActiveVoiceCount(int maxVoiceCount);

  @JS('Module._fadeGlobalVolume')
  external int fadeGlobalVolume(double to, double duration);

  @JS('Module._fadeVolume')
  external int fadeVolume(int handle, double to, double duration);

  @JS('Module._fadePan')
  external int fadePan(int handle, double to, double duration);

  @JS('Module._fadeRelativePlaySpeed')
  external int fadeRelativePlaySpeed(int handle, double to, double duration);

  @JS('Module._schedulePause')
  external int schedulePause(int handle, double duration);

  @JS('Module._scheduleStop')
  external int scheduleStop(int handle, double duration);

  @JS('Module._oscillateVolume')
  external int oscillateVolume(int handle, double from, double to, double time);

  @JS('Module._oscillatePan')
  external int oscillatePan(int handle, double from, double to, double time);

  @JS('Module._oscillateRelativePlaySpeed')
  external int oscillateRelativePlaySpeed(
      int handle, double from, double to, double time);

  @JS('Module._oscillateGlobalVolume')
  external int oscillateGlobalVolume(double from, double to, double time);

  @JS('Module._isFilterActive')
  external int isFilterActive(int filterType, int idPtr);

  @JS('Module._getFilterParamNames')
  external int getFilterParamNames(
    int filterType,
    int paramsCountPtr,
    int namesPtr,
  );

  @JS('Module._addGlobalFilter')
  external int addGlobalFilter(int filterType);

  @JS('Module._removeGlobalFilter')
  external int removeGlobalFilter(int filterType);

  @JS('Module._setFxParams')
  external int setFxParams(int filterType, int attributeId, double value);

  @JS('Module._getFxParams')
  external double getFxParams(int filterType, int attributeId);

  @JS('Module._play3d')
  external int play3d(
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
  external void set3dSoundSpeed(double speed);

  @JS('Module._get3dSoundSpeed')
  external double get3dSoundSpeed();

  @JS('Module._set3dListenerParameters')
  external void set3dListenerParameters(
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
  external void set3dListenerPosition(double posX, double posY, double posZ);

  @JS('Module._set3dListenerAt')
  external void set3dListenerAt(double atX, double atY, double atZ);

  @JS('Module._set3dListenerUp')
  external void set3dListenerUp(double upX, double upY, double upZ);

  @JS('Module._set3dListenerVelocity')
  external void set3dListenerVelocity(
    double velocityX,
    double velocityY,
    double velocityZ,
  );

  @JS('Module._set3dSourceParameters')
  external void set3dSourceParameters(
    int handle,
    double posX,
    double posY,
    double posZ,
    double velocityX,
    double velocityY,
    double velocityZ,
  );

  @JS('Module._set3dSourcePosition')
  external void set3dSourcePosition(
    int handle,
    double posX,
    double posY,
    double posZ,
  );

  @JS('Module._set3dSourceVelocity')
  external void set3dSourceVelocity(
    int handle,
    double velocityX,
    double velocityY,
    double velocityZ,
  );

  @JS('Module._set3dSourceMinMaxDistance')
  external void set3dSourceMinMaxDistance(
    int handle,
    double minDistance,
    double maxDistance,
  );

  @JS('Module._set3dSourceAttenuation')
  external void set3dSourceAttenuation(
    int handle,
    int attenuationModel,
    double attenuationRolloffFactor,
  );

  @JS('Module._set3dSourceDopplerFactor')
  external void set3dSourceDopplerFactor(int handle, double dopplerFactor);

  // ///////////////////////////
  // Capture
  // ///////////////////////////
  @JS('Module._listCaptureDevices')
  external void listCaptureDevices(
      int namesPtr, int isDefaultPtr, int nDevicePtr);

  @JS('Module._freeListCaptureDevices')
  external void freeListCaptureDevices(
    int namesPtr,
    int isDefaultPtr,
    int nDevice,
  );

  @JS('Module._initCapture')
  external int initCapture(int deviceID);

  @JS('Module._disposeCapture')
  external void disposeCapture();

  @JS('Module._isCaptureInited')
  external int isCaptureInited();

  @JS('Module._isCaptureStarted')
  external int isCaptureStarted();

  @JS('Module._startCapture')
  external int startCapture();

  @JS('Module._stopCapture')
  external int stopCapture();
}
