import 'worker.dart' as base;
import 'dart:async';
import 'dart:isolate' as iso;


class Worker implements base.Worker {
  late iso.SendPort _sendPort;
  late iso.ReceivePort _receivePort;
  Worker(_sendPort) {
    _receivePort = iso.ReceivePort();
    _sendPort.send(_receivePort.sendPort);
  }

  @override
  void sendMessage(dynamic message) { 
    _sendPort.send(message);
  }

  @override
  Stream<dynamic> onReceive()=> _receivePort;
}

class WorkerController implements base.WorkerController {
  bool _initialized = false;
  late iso.ReceivePort _receivePort;
  iso.Isolate? _isolate;
  iso.SendPort?  _sendPort;
  late StreamController<dynamic> _outputController;
  late StreamController<dynamic> _inputController;
  late Completer<void> _initializedCompleter;
  List<dynamic> messageCache = [];
  bool get initialized => _initialized;

  @override
  void spawn(String path) async  {
    _isolate =  await iso.Isolate.spawnUri(
        Uri.file(path), [], _receivePort.sendPort);
  }

  @override
  Future<void> waitByInitialized() async {
    if (initialized) {
      return;
    }
    await _initializedCompleter.future;
  }

  WorkerController() {
    _initializedCompleter = Completer();
    _outputController = StreamController();
    _inputController = StreamController();
    _receivePort = iso.ReceivePort();

    _receivePort.listen((message) {
      if(initialized) {
        _outputController.add(message);
        return;
      }
      if(message is iso.SendPort) {
        _sendPort = message;
        for(var m in messageCache) {
          _sendPort?.send(m);
        }
        _initialized = true;
        _initializedCompleter.complete();
      }
    }, onError: (e){
      _outputController.addError(e);
    }); 
  }

  @override
  void sendMessage(dynamic message) { 
    if(!_initialized) {
      messageCache.add(message);
    } else {
      _inputController.add(message);
    }
  }

  @override
  Stream<dynamic> onReceive() => _outputController.stream;

  @override
  void kill() {
    _isolate?.kill();
  }
}