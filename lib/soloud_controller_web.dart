import 'bindings_player_web.dart';
import 'worker/js_import.dart';

/// Controller that expose method channel and FFI
class SoLoudController {
  ///
  factory SoLoudController() => _instance ??= SoLoudController._();

  SoLoudController._() {
    initialize();
  }

  static SoLoudController? _instance;

  ///
  late final JSSoloud soLoudFFI;

  ///
  Future<void> initialize() async{
    await JSImport.import(source: 'wasm/build/libflutter_soloud_plugin.js', package: 'flutter_soloud');

    soLoudFFI = JSSoloud();
    // captureFFI = FlutterCaptureFfi.fromLookup(nativeLib.lookup);
  }
}