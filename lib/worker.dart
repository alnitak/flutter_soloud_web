import 'package:flutter_soloud/worker/worker_web.dart'
    if (dart.library.io) 'package:flutter_soloud/worker/worker_io.dart';

void main() {
  print('Worker created\n');
  var worker = Worker();
  worker.onReceive().listen((dynamic data) {
    print('worker: onMessage $data  ${data.runtimeType}\n');
    worker.sendMessage(data);
  });
}
