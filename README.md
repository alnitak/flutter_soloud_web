# flutter_soloud

Testing implementation of the web version of [flutter_soloud](https://github.com/alnitak/flutter_soloud) package.

## Description

The web platform is now supported but some testing are welcome.

## What I did

In the `wasm` directory, there is a `compile.sh` script that generates the `.js` and `.wasm` files. Run it after installing *emscripten*.

In the `<body>` section of `example/web/index.html`, add the following line:
`<script src="assets/packages/flutter_soloud/web/libflutter_soloud_plugin.js" defer></script>`

## The problems occurred

The `AudioIsolate` was bringing a lot of problems related to web Workers. It was used to monitor all the sounds state and to send some operations to the native. These operations were not working inside a JS Worker because the `web audio` is not supported.

The `AudioIsolate` has been removed and all the logic has been implemented on native. Events like `audio finished` are sent from C back to Dart. But since is not possible to call Dart from a native thread (the audio thread) a new web Worker is created using WASM `EM_ASM`directive. Doing so it was possible to send to the Worker the `audio finished` event back to Dart.
The same problem happens using `dart:ffi`, neither here is possible to call directly a function from native to Dart. And here comes to help the `NativeCallable` with which is not needed to import into native the `sendPort` and `receivePort` which are part of ffi which is not compatible when compiling with emscripten for the web.


## Notes
Since to get audio data is/was experimental, there is now the `AudioData` class. The following experimental methods are now deprecated:
- `@experimental SoLoud.getAudioTexture2D()`
- `@experimental SoLoudCapture.getCaptureAudioTexture2D()`
- on the web is not possible to directly read a local audio file. For this reason has been added `loadMem` which needs the `Uint8List` bytes buffer of the audio file.

@filip the `Loader` is not compatible with web.

## Feats:
- added capture exceptions
- the experimental *.getTexture* methods to get wave and FFT values are now in the `AudioData` class. In addition to the `getAudioTexture2D` it's now possible to acquire also the audio data as `linear` which represents FFT+wave array or just `wave` data array for better performance. With this class is also possible to choose to acquire data from the player or from the mic.