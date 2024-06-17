import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:js_util';
import 'dart:convert' show jsonDecode, jsonEncode;

import 'worker.dart' as base;
import 'dart:html' as html;
import 'package:web/web.dart' as web;
import 'package:flutter_soloud/src/worker/js_import.dart';

// Masked type: ServiceWorkerGlobalScope
@JS('self')
external JSAny get globalScopeSelf;

@JS('self.importScript')
external JSAny _importScript(String path);

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
      print('§§§§§§§§§§§§§§§§§§§§§§§§§§§  ${event.type}');
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
    print('******** sendMessage()1: $message');
    switch (message) {
      case Map():
        final mapEncoded = jsonEncode(message);
        print('********* sendMessage()2: $mapEncoded');
        _worker?.postMessage(mapEncoded.jsify());
      case num():
        _worker?.postMessage(message.toJS);
      case String():
        _worker?.postMessage(message.toJS);
      default:
        try {
          final messageJsifyed = message.jsify();
          _worker?.postMessage(messageJsifyed);
        } catch (e) {
          throw UnsupportedError(
              'sendMessage(): Type ${message.runtimeType} unsupported');
        }
    }
  }

  @override
  Stream<dynamic> onReceive() {
    return _outputController!.stream;
  }

  @override
  void kill() {
    _worker?.terminate();
  }

  // JSObject mapToJsObject(Map map) {
  //   var object = newObject();
  //   map.forEach((k, v) {
  //     if (v is Map) {
  //       setProperty(object, k, mapToJsObject(v));
  //     } else {
  //       setProperty(object, k, v);
  //     }
  //   });
  //   return object;
  // }
}

// Map jsObjectToMap(JSAny jsObject) {
//   final Map result = {};
//   final List keys = _objectKeys(jsObject);
//   for (final dynamic key in keys) {
//     final JSAny value = getProperty(jsObject, key);
//     List nestedKeys = [];
//     if (value is JSArray) {
//       nestedKeys = objectKeys(value);
//     }
//     if (nestedKeys.isNotEmpty) {
//       //nested property
//       result[key] = jsObjectToMap(value);
//     } else {
//       result[key] = value;
//     }
//   }
//   return result;
// }

// JsArray<JSString> objectKeys(JSAny jsObject) {
//   return _objectKeys(jsObject);
// }

// @JS('Object.keys')
// external JsArray<JSString> _objectKeys(jsObject);