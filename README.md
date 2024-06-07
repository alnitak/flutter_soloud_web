# flutter_soloud

Only the web version of [flutter_soloud](https://github.com/alnitak/flutter_soloud) package.

## Description

This is a plugin created to support only web. Created to look for an idea on how to proceed to add web platform to the original plugin.

## What I did

In the `wasm` directory, there is a `compile` script that generates the `.js` and `.wasm` files. Run it after installing *emscripten*.

The 2 generated files `libflutter_soloud_plugin.js` and `libflutter_soloud_plugin.wasm` now should be copied to the `example/web` directory.

In the `<body>` section of `example/web/index.html`, add the following line:
`<script src="libflutter_soloud_plugin.js" type="application/javascript"></script>`
    
Now the JS lib with all SoLoud bindings is ready to be used in the web app.
The bindings are in `flutter_soloud.dart`.

## The problems

Refer to the issue [#1](https://github.com/alnitak/flutter_soloud_web/issues/1)

- [web audio is not supported inside a web worker](https://stackoverflow.com/questions/67949831/is-there-a-way-to-use-audiocontext-in-a-web-worker)
- [AudioWorkletNode in miniaudio](https://github.com/mackron/miniaudio/issues/597#issuecomment-1445060662)