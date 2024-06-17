import 'dart:convert' show jsonDecode;

import 'package:flutter_soloud/src/bindings_player_web.dart';
import 'package:flutter_soloud/src/worker/worker_web.dart'
    if (dart.library.io) 'package:flutter_soloud/worker/worker_io.dart';

void doJob() async {

  print('Worker created.\n');
  var worker = Worker(args: null);
  worker.onReceive().listen((data) {
    print(
        'Dart worker: '
        'onMessage received $data with type of ${data.runtimeType}\n');

    if (data is String) {
      try {
          final parseMap = jsonDecode(data);
          if (parseMap['message'] == 'voiceEndedCallback') {
            FlutterSoLoudWeb().voiceCallbackFromJs(parseMap["value"]);
          }
        } catch (e) {
          print("Received data from WASM worker but it's not a String!");
        }
    }

  });
}

/// Called only when creating a web worker.
void main() {
  doJob();
}
