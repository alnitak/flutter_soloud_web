import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:js_util';

import 'worker.dart' as base;
import 'dart:html' as html;

// Masked type: ServiceWorkerGlobalScope
@JS('self')
external JSAny get globalScopeSelf;

void jsSendMessage(dynamic m) {
  globalContext.callMethod('postMessage'.toJS, m.jsify());
}

Stream<T> callbackToStream<J, T>(
  dynamic object,
  String name,
  T Function(J jsValue) unwrapValue,
) {
  var controller = StreamController<T>.broadcast(sync: true);
  setProperty(object, name, allowInterop((J event) {
    controller.add(unwrapValue(event));
  }));
  return controller.stream;
}

class Worker implements base.Worker {
  late StreamController<dynamic> _outputController;

  Worker() {
    _outputController = StreamController();
    callbackToStream(globalScopeSelf, 'onmessage', (html.MessageEvent e) {
      _outputController.add(getProperty(e, 'data'));
    });
  }
  
  @override
  Stream onReceive() => _outputController.stream;

  @override
  void sendMessage(message) {
    jsSendMessage(message);
  }
}

class WorkerController implements base.WorkerController {
  html.Worker? _worker;
  StreamController<dynamic>? _outputController;

  @override
  void spawn(String path) async {
    _outputController = StreamController();
    path = (path.endsWith('.dart') ? '$path.js' : path);
    _worker = html.Worker(path);
    _worker?.onMessage.listen((event) {
      _outputController?.add(event.data);
    });
  }

  @override
  Future waitByInitialized() {
    throw UnimplementedError();
  }

  @override
  void sendMessage(dynamic message) {
    _worker?.postMessage(message);
  }

  @override
  Stream<dynamic> onReceive() {
    return _outputController!.stream;
  }

  @override
  void kill() {
    _worker?.terminate();
  }
}
