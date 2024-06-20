import 'package:meta/meta.dart';

export 'package:flutter_soloud/src/bindings/ffi_data_ffi.dart'
    if (dart.library.html) 'package:flutter_soloud/src/bindings/ffi_data_web.dart';

enum GetSamplesFrom {
  player,
  microphone,
}

enum GetSamplesKind {
  linear,
  texture,
}