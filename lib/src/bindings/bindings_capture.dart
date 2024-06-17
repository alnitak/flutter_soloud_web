import 'package:flutter_soloud/src/enums.dart';
import 'package:meta/meta.dart';

export 'package:flutter_soloud/src/bindings/bindings_capture_ffi.dart'
    if (dart.library.html) 
      'package:flutter_soloud/src/bindings/bindings_capture_web.dart';

abstract class FlutterCapture {
  @mustBeOverridden
  List<CaptureDevice> listCaptureDevices();

  @mustBeOverridden
  CaptureErrors initCapture(int deviceID);

  @mustBeOverridden
  void disposeCapture();

  @mustBeOverridden
  bool isCaptureInited();

  @mustBeOverridden
  bool isCaptureStarted();

  @mustBeOverridden
  CaptureErrors startCapture();

  @mustBeOverridden
  CaptureErrors stopCapture();

  @mustBeOverridden
  CaptureErrors getCaptureAudioTexture2D(dynamic samples);

  @mustBeOverridden
  CaptureErrors setCaptureFftSmoothing(double smooth);
}
