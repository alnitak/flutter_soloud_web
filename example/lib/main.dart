import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  final _flutterSoloudPlugin = FlutterSoloud();
  late SoundHash soundHash;
  late WorkerController controller;

  Future<void> initWorker() async {
    controller = WorkerController();
    if (kIsWeb) {
      controller = await WorkerController.spawn('assets/packages/flutter_soloud/web/audio_isolate.dart.js');
    } else {
      controller = await WorkerController.spawn('');
    }

    controller.onReceive().listen((dynamic event) {
      print('receive message from audio_isolate!! $event  ${event.runtimeType}');
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
                  if (kIsWeb) {
                    final result = await FilePicker.platform
                        .pickFiles(type: FileType.any, allowMultiple: false);

                    if (result != null && result.files.isNotEmpty) {
                      final fileName = result.files.first.name;
                      final fileBytes = result.files.first.bytes;

                      var sound = await _flutterSoloudPlugin.loadMem(
                        fileName,
                        fileBytes!,
                      );
                      soundHash = sound.soundHash;
                    }
                  } else {
                    var sound = await _flutterSoloudPlugin.loadMem(
                        '/home/deimos/5/12.-Animal Instinct.flac',
                        File('/home/deimos/5/12.-Animal Instinct.flac').readAsBytesSync(),
                      );
                      soundHash = sound.soundHash;
                  }
                  print('****** FILE LOADED $soundHash');
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
                onPressed: () async {
                  await initWorker();
                },
                child: const Text('INIT WORKER'),
              ),
              OutlinedButton(
                onPressed: () {
                  controller
                      .sendMessage({'event': 123});
                },
                child: const Text('SEND Map()'),
              ),
              OutlinedButton(
                onPressed: () {
                  controller
                      .sendMessage(1.2345);
                },
                child: const Text('SEND Double'),
              ),
              OutlinedButton(
                onPressed: () {
                  controller
                      .sendMessage('CIAO');
                },
                child: const Text('SEND String'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
