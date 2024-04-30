import 'package:flutter_soloud/worker/worker_web.dart'
    if (dart.library.io) 'package:flutter_soloud/worker/worker_io.dart';

void doJob(WorkerController? controller) async{
  print('Worker created.\n');
  var worker = Worker();
  worker.onReceive().listen((dynamic data) {
    print('audio_isolate: onMessage $data  ${data.runtimeType}\n');
    worker.sendMessage(data);
  });
  for (var i = 0; i<999999999; i++) {
    await Future.delayed(const Duration(milliseconds: 3000), () {
      print('audio_isolate: $i');
    });
  }
}

void main() {
  doJob(null);
}
