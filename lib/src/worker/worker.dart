abstract class Worker {
  void sendMessage(dynamic message);
  Stream<dynamic> onReceive();
}

abstract class WorkerController {
  Future waitInitialized();
  void sendMessage(dynamic message);
  Stream<dynamic> onReceive();
  void kill();
}
