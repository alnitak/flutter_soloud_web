abstract class Worker {
  void sendMessage(dynamic message);
  Stream<dynamic> onReceive();
}

abstract class WorkerController {
  Future waitByInitialized();
  void sendMessage(dynamic message);
  Stream<dynamic> onReceive();
  void kill();
}

