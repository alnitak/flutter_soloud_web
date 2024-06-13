// import 'package:flutter_soloud/bindings_capture_web.dart';

import 'dart:async';

import 'package:flutter_soloud/worker/js_import.dart';

import 'bindings_player_web.dart';

/// Controller that expose method channel and FFI
// class SoLoudController {
//   ///
//   factory SoLoudController() => _instance ??= SoLoudController._();

//   SoLoudController._() {
//     initialize();
//   }

//   static SoLoudController? _instance;

//   ///
//   late final JSSoloudPlayer soLoudFFI;

//   ///
//   // late final JSSoloudCapture captureFFI;

//   ///
//   Future<void> initialize() async{
//     print('################ SoLoudController()1');
//     await JSImport.import(source: 'web/libflutter_soloud_plugin.js', package: 'flutter_soloud');
//     print('################ SoLoudController()2');
//     soLoudFFI = JSSoloudPlayer();
//     print('################ SoLoudController()3');
//     // captureFFI = FlutterCaptureFfi.fromLookup(nativeLib.lookup);
//   }
// }

/// Controller that expose method channel and FFI
class SoLoudController {
  ///
  factory SoLoudController() => _instance ??= SoLoudController._();

  SoLoudController._() {
    if (_isInitialized != null || !(_isInitialized?.isCompleted ?? false)) {
      _isInitialized = Completer<bool>();
      initialize();
    }
  }

  static SoLoudController? _instance;

  Completer? _isInitialized;

  ///
  late final JSSoloudPlayer _soLoudFFI;
  JSSoloudPlayer get soLoudFFI {
    if (_isInitialized?.isCompleted ?? false) {
      return _soLoudFFI;
    }
    throw AsyncError('error', StackTrace.fromString('stackTrace'));
  }

  ///
  // late final JSSoloudCapture captureFFI;

  ///
  Future<void> initialize() async {
    _soLoudFFI = JSSoloudPlayer();
    // captureFFI = FlutterCaptureFfi.fromLookup(nativeLib.lookup);
    await JSImport.import(
        source: 'web/libflutter_soloud_plugin.js',
        package: 'flutter_soloud');
    _isInitialized?.complete(true);
  }
}


// class SoLoudController {
//   static SoLoudController? _instance;

//   factory SoLoudController() => _instance ??= SoLoudController._();
  
//   SoLoudController._() {initialize();}

//   ///
//   static late final JSSoloudPlayer _soLoudFFI;
//   static JSSoloudPlayer get soLoudFFI => _soLoudFFI;

//   static Future<SoLoudController> initialize() async {
//     print('################ SoLoudController()1');
//     await JSImport.import(source: 'web/libflutter_soloud_plugin.js', package: 'flutter_soloud');
//     print('################ SoLoudController()2');
//     _soLoudFFI = JSSoloudPlayer();
//     print('################ SoLoudController()3');
//     // captureFFI = FlutterCaptureFfi.fromLookup(nativeLib.lookup);
    
//     _instance ??= SoLoudController._();

//     return _instance!;
//   }
// }