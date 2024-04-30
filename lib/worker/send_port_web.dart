import 'dart:async';

/// Web implementation of the `dart:isolate`'s SendPort.
class SendPort {
  void send(Object? message) {}
}

/// Web implementation of the `dart:isolate`'s ReceivePort.
// class ReceivePort {
//   late SendPort sendPort;
//   late Stream<dynamic> _stream;

//   ReceivePort() { _stream = Stream. };

//   /// Returns a stream of messages received by this port.
//   Stream<dynamic> get stream => _stream;

//   StreamSubscription listen(
//     void Function(dynamic event)? onData, {
//     Function? onError,
//     void Function()? onDone,
//     bool? cancelOnError,
//   }) {
//     return _stream.listen(
//           onData,
//           onError: onError,
//           onDone: onDone,
//           cancelOnError: cancelOnError,
//         );
//   }

//   /// Close the receive port, ignoring any further messages.
//   // void close() => _stream.close();
// }
