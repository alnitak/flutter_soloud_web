import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:js_util';
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter_soloud/bindings_player_web.dart';
import 'package:flutter_soloud/worker/worker_web.dart'
    if (dart.library.io) 'package:flutter_soloud/worker/worker_io.dart';

/// Allows assigning a function to be callable from `window.functionName()`
@JS('voiceCallback')
external set _voiceCallback(JSFunction f);

/// Allows calling the assigned function from Dart as well.
@JS()
external void voiceCallback(int handle);

void doJob() async {
  print('Worker created.\n');
  var worker = Worker(args: null);
  _voiceCallback = allowInterop(voiceCallbackFromJs).toJS;
  worker.onReceive().listen((data) {
    print(
        'audio_isolate: onMessage received $data with type of ${data.runtimeType}\n');

    switch (data) {
      case Map():
        worker.sendMessage(data);
      case num():
        worker.sendMessage(data);

      /// A String can be a Map() or a simple String. Try the Map() first
      case String():
        try {
          final parseMap = jsonDecode(data);
          worker.sendMessage(jsonEncode(parseMap));
          if (parseMap['message'] == 'voiceEndedCallback') {
            voiceCallbackFromJs(parseMap["value"]);
          }
        } catch (e) {
          worker.sendMessage(data);
        }
    }
  });
}

/// Called only when creating a web worker.
void main() {
  doJob();
}
