import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter_soloud/sound_hash.dart';

import 'package:flutter_soloud/worker/worker_web.dart'
    if (dart.library.io) 'package:flutter_soloud/worker/worker_io.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterSoloudPlugin = FlutterSoloud();
  late SoundHash soundHash;
  late WorkerController controller;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    controller = WorkerController();
    controller.spawn('assets/packages/flutter_soloud/web/worker.dart.js');
    // controller.spawn('worker.dart');

    controller.onReceive().listen((dynamic event) {
      print('worker: receive message!! $event  ${event.runtimeType}');
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _flutterSoloudPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              OutlinedButton(
                onPressed: () {
                  _flutterSoloudPlugin.init();
                },
                child: const Text('init'),
              ),
              OutlinedButton(
                onPressed: () async {
                  var sound = _flutterSoloudPlugin.loadWaveform();
                  soundHash = sound.soundHash;
                },
                child: const Text('load waveform'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final result = await FilePicker.platform
                      .pickFiles(type: FileType.any, allowMultiple: false);

                  if (result != null && result.files.isNotEmpty) {
                    final fileBytes = result.files.first.bytes;
                    final fileName = result.files.first.name;

                    var sound = await _flutterSoloudPlugin.loadMem(
                      fileName,
                      fileBytes!,
                    );
                    soundHash = sound.soundHash;
                  }
                },
                child: const Text('load mem'),
              ),
              OutlinedButton(
                onPressed: () {
                  _flutterSoloudPlugin.play(soundHash);
                },
                child: const Text('play'),
              ),
              OutlinedButton(
                onPressed: () {
                  _flutterSoloudPlugin.deinit();
                },
                child: const Text('dispose'),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  controller
                    // .sendMessage(12345);
                    .sendMessage({'event': 123});
                },
                child: const Text('WORKER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
