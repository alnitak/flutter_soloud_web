class ReceivePort {
  ReceivePort();

  SendPort get sendPort {
    return SendPort();
  }

  listen(Future<dynamic> Function(dynamic data) callback) {}
}

class SendPort {
  SendPort();

  void send(dynamic data) {}
}
