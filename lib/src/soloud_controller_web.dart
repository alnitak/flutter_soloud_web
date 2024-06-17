// import 'package:flutter_soloud/bindings_capture_web.dart';

import 'dart:async';

import 'package:flutter_soloud/src/worker/js_import.dart';

import 'bindings_player_web.dart';

/// Controller that expose method channel and FFI
class SoLoudController {
  factory SoLoudController() => _instance ??= SoLoudController._();

  SoLoudController._() {
    initialize();
  }

  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  static SoLoudController? _instance;

  Completer<void>? completer;

  late final FlutterSoLoudWeb _soLoudFFI;

  FlutterSoLoudWeb get soLoudFFI {
    if (_isInitialized) {
      return _soLoudFFI;
    } else {
      throw AsyncError('error',
          StackTrace.fromString('SoLoudController is not yet initialized!'));
    }
  }

  ///
  // late final JSSoloudCapture captureFFI;

  Future<void> initialize() async {
    if (_isInitialized) return;
    // captureFFI = FlutterCaptureFfi.fromLookup(nativeLib.lookup);
    await initWebJs();
    return Future.value();
  }

  /// It could happen that if the user doesn't initilize some variable
  /// to this class (ie: `final _flutterSoloudPlugin = SoLoud.instance;`)
  /// and call at first `SoLoud.instance.init()`,  the
  /// `web/libflutter_soloud_plugin.js` is not yet loaded in
  /// `soloud_controller_web.dart`. If the latter is not yet initialized
  /// await for it.
  ///
  /// The alternative is to let the user to insert in its
  /// `web/index.html` app file, the following `script` tag and modify
  /// `soloud_controller_web.dart` acordingly:
  /// `<script src=
  /// "assets/packages/flutter_soloud/web/libflutter_soloud_plugin.js"
  /// defer></script>`
  Future<void> initWebJs() async {
    if (_isInitialized) return;
    if (completer != null) {
      print('** AWAITING COMPLETER\n');
      await completer?.future;
      print('** AWAITED COMPLETER\n');
      return;
    }
    print('** BUILDING COMPLETER\n');
    completer = Completer();
    await JSImport.import(
      source: 'web/libflutter_soloud_plugin.js',
      package: 'flutter_soloud',
    );
    // while (!JSImport.isImported(
    //   source: 'web/libflutter_soloud_plugin.js',
    //   package: 'flutter_soloud',
    // )) {}

    // await Future.delayed(const Duration(milliseconds: 2000), () {});
    _soLoudFFI = FlutterSoLoudWeb();
    var loaded = false;
    while (loaded) {
      try {
        _soLoudFFI.getVoiceCount();
        loaded = true;
      } catch (e) {}
    }

    _isInitialized = true;
    print('** COMPLETED\n');
    completer?.complete();
  }
}

/// Controller that expose method channel and FFI
// class SoLoudController {
//   ///
//   factory SoLoudController() => _instance ??= SoLoudController._();

//   SoLoudController._() {
//     if (completer != null || !(completer?.isCompleted ?? false)) {
//       completer = Completer<bool>();
//       initialize();
//     }
//   }

//   static SoLoudController? _instance;

//   Completer? completer;
//   var _isInitialized = false;
//   bool get isInitialized => _isInitialized;

//   late final FlutterSoLoudWeb _soLoudFFI;

//   FlutterSoLoudWeb get soLoudFFI {
//     if (completer?.isCompleted ?? false) {
//       return _soLoudFFI;
//     }
//     throw AsyncError('error', StackTrace.fromString('stackTrace'));
//   }

//   ///
//   // late final JSSoloudCapture captureFFI;

//   ///
//   Future<void> initialize() async {
//     _soLoudFFI = FlutterSoLoudWeb();
//     // captureFFI = FlutterCaptureFfi.fromLookup(nativeLib.lookup);
//     await JSImport.import(
//         source: 'web/libflutter_soloud_plugin.js',
//         package: 'flutter_soloud');
//     _isInitialized = true;
//     completer?.complete(true);
//   }
// }
