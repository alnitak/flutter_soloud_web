// import 'dart:js_interop';
// import 'dart:js_interop_unsafe';
// import 'dart:js_util';
// import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter_soloud/worker/send_port_io.dart';
import 'package:flutter_soloud/worker/worker_web.dart'
    if (dart.library.io) 'package:flutter_soloud/worker/worker_io.dart';

void doJob(SendPort? port) async {
  print('Worker created.\n');
  var worker = Worker(args: port);
  worker.onReceive().listen((data) {
    print('audio_isolate: onMessage $data  ${data.runtimeType}\n');
    // printValues(data);
    worker.sendMessage(data);
  });
  for (var i = 0; i < 999999999; i++) {
    await Future.delayed(const Duration(milliseconds: 3000), () {
      print('audio_isolate: $i');
    });
  }
}

void main() {
  doJob(null);
}
