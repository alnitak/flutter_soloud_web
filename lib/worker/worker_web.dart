import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:js_util';
import 'dart:convert' show jsonDecode;

import 'worker.dart' as base;
// import 'dart:html' as html;
import 'package:web/web.dart' as web;

// Masked type: ServiceWorkerGlobalScope
@JS('self')
external JSAny get globalScopeSelf;

void jsSendMessage(dynamic m) {
  globalContext.callMethod('postMessage'.toJS, m);
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

  Worker({dynamic args}) {
    _outputController = StreamController();
    callbackToStream(globalScopeSelf, 'onmessage', (web.MessageEvent e) {
      _outputController.add(getProperty(e, 'data'));
    });
  }

  @override
  Stream onReceive() => _outputController.stream;

  @override
  void sendMessage(dynamic message) {
    jsSendMessage(message);
  }
}

class WorkerController implements base.WorkerController {
  web.Worker? _worker;
  StreamController<dynamic>? _outputController;

  static Future<WorkerController> spawn(String path) async {
    var controller = WorkerController();
    controller._outputController = StreamController();
    path = (path.endsWith('.dart') ? '$path.js' : path);
    controller._worker = web.Worker(path);

    controller._worker?.onmessage = (((web.MessageEvent event) {
      controller._outputController?.add(event.data.dartify());
    })).toJS;
    return controller;
  }

  @override
  Future waitInitialized() {
    throw UnimplementedError();
  }

  @override
  void sendMessage(dynamic message) {
    if (message is Map) {
      _worker?.postMessage(mapToJsObject(message).jsify());
    } else {
      _worker?.postMessage(message);
    }
    // _worker?.postMessage(message.jsify());
  }

  @override
  Stream<dynamic> onReceive() {
    return _outputController!.stream;
  }

  @override
  void kill() {
    _worker?.terminate();
  }

  Object mapToJsObject(Map map) {
    var object = newObject();
    map.forEach((k, v) {
      if (v is Map) {
        setProperty(object, k, mapToJsObject(v));
      } else {
        setProperty(object, k, v);
      }
    });
    return object;
  }
}
