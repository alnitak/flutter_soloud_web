import 'dart:convert' show jsonDecode;

import 'package:flutter_soloud/src/bindings/bindings_player_web.dart';
import 'package:flutter_soloud/src/worker/worker_web.dart';

void doJob() async {
  print('Worker created.\n');
  var worker = Worker(args: null);
  worker.onReceive().listen((data) {
    print('Dart worker: '
        'onMessage received $data with type of ${data.runtimeType}\n');

    if (data is String) {
      try {
        final parseMap = jsonDecode(data);
        if (parseMap['message'] == 'voiceEndedCallback') {
          ******** provare a usare una gloab func
          FlutterSoLoudWeb().voiceCallbackFromJs(parseMap["value"]);
        }
      } catch (e) {
        print("Received data from WASM worker but it's not a String!\n");
      }
    }
  });
}

/// Called only when creating a web worker.
void main() {
  doJob();
}
