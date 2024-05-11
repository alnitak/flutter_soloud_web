// import 'dart:js_interop';
// import 'dart:js_interop_unsafe';
// import 'dart:js_util';
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter_soloud/worker/send_port_io.dart';
import 'package:flutter_soloud/worker/worker_web.dart'
    if (dart.library.io) 'package:flutter_soloud/worker/worker_io.dart';

void doJob(SendPort? port) async {
  print('Worker created.\n');
  var worker = Worker(args: port);
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
        } catch (e) {
          worker.sendMessage(data);
        }
    }
  });
  for (var i = 0; i < 999999999; i++) {
    print('audio_isolate: $i');
    await Future.delayed(const Duration(milliseconds: 3000), () {});
  }
}

/// The main() function is needed only when compiling a .dart file to .js.
/// It will be called only when spawing a web worker.
void main() {
  doJob(null);
}
