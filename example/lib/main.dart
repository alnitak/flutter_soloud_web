// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/audio_isolate.dart';
import 'package:flutter_soloud/audio_source.dart';
import 'dart:async';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter_soloud/soloud_controller.dart';
import 'package:flutter_soloud/audio_source.dart';
import 'package:flutter_soloud/sound_hash.dart';
import 'package:flutter_soloud/sound_handle.dart';
import 'package:flutter_soloud/enums.dart';
import 'package:flutter_soloud/worker/js_import.dart';

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
  late AudioSource audioSource;
  late SoundHash soundHash;
  late SoundHandle soundHandle;
  late WorkerController controller;

  Future<void> initWorker() async {
    controller = WorkerController();
    if (kIsWeb) {
      controller = await WorkerController.spawn(
          'assets/packages/flutter_soloud/web/audio_isolate.dart.js');
    } else {
      controller = await WorkerController.spawn('');
    }

    controller.onReceive().listen((dynamic event) {
      // if ((event as Map)['event'] == MessageEvents.loadWaveform) {
      //   soundHash = (event['return']['sound'] as AudioSource).soundHash;
      // }
      Map m = jsonDecode(event);
      if (m['event'] == MessageEvents.loadSoLoudJS.index) {
        print(']]]]]]]]]]]]]]] MAIN MessageEvents.loadSoLoudJS');
        JSImport.import(
            source: 'web/libflutter_soloud_plugin.js',
            package: 'flutter_soloud');
      }

      print(
          'receive message from audio_isolate!! $event  ${event.runtimeType}');
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
                onPressed: () async {
                  _flutterSoloudPlugin.init();
                },
                child: const Text('init'),
              ),
              OutlinedButton(
                onPressed: () async {
                  audioSource = _flutterSoloudPlugin.loadWaveform();
                  soundHash = audioSource.soundHash;
                  print('main loadWaveform audioSource: $soundHash');
                },
                child: const Text('load waveform'),
              ),
              // OutlinedButton(
              //   onPressed: () async {
              //     if (kIsWeb) {
              //       final result = await FilePicker.platform
              //           .pickFiles(type: FileType.any, allowMultiple: false);

              //       if (result != null && result.files.isNotEmpty) {
              //         final fileName = result.files.first.name;
              //         final fileBytes = result.files.first.bytes;

              //         var sound = await _flutterSoloudPlugin.loadMem(
              //           fileName,
              //           fileBytes!,
              //         );
              //         soundHash = sound.soundHash;
              //       }
              //     } else {
              //       var sound = await _flutterSoloudPlugin.loadMem(
              //         '/home/deimos/5/12.-Animal Instinct.flac',
              //         File('/home/deimos/5/12.-Animal Instinct.flac')
              //             .readAsBytesSync(),
              //       );
              //       soundHash = sound.soundHash;
              //     }
              //     print('****** FILE LOADED $soundHash');
              //   },
              //   child: const Text('load mem'),
              // ),
              OutlinedButton(
                onPressed: () {
                  soundHandle = _flutterSoloudPlugin.play(soundHash);
                },
                child: const Text('play'),
              ),
              OutlinedButton(
                onPressed: () {
                  print('main getIsValidVoiceHandle1: $soundHandle');
                  // final b = _flutterSoloudPlugin
                  //     .getIsValidVoiceHandle(soundHandle);
                  print('main getIsValidVoiceHandle: $soundHandle ');
                },
                child: const Text('get is valid'),
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
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  controller.sendMessage({'event': 123});
                },
                child: const Text('SEND Map()'),
              ),
              OutlinedButton(
                onPressed: () {
                  controller.sendMessage(1.2345);
                },
                child: const Text('SEND Double'),
              ),
              OutlinedButton(
                onPressed: () {
                  controller.sendMessage('CIAO');
                },
                child: const Text('SEND String'),
              ),

              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  print('******** main() MessageEvents.loadSoLoudJS');
                  controller.sendMessage({
                    'event': MessageEvents.loadSoLoudJS.index,
                    'args': {'handle': audioSource.soundHash.hash},
                  });
                },
                child: const Text('MessageEvents.loadSoLoudJS'),
              ),
              OutlinedButton(
                onPressed: () {
                  print('******** main() MessageEvents.initEngine');
                  controller.sendMessage({
                    'event': MessageEvents.initEngine.index,
                    'args': {},
                  });
                },
                child: const Text('MessageEvents.initEngine'),
              ),
              OutlinedButton(
                onPressed: () {
                  controller.sendMessage({
                    'event': MessageEvents.loadWaveform.index,
                    'args': {
                      'waveForm': WaveForm.fSquare,
                      'superWave': true,
                      'scale': 1.0,
                      'detune': 1.0,
                    },
                  });
                },
                child: const Text('MessageEvents.loadWaveform'),
              ),
              OutlinedButton(
                onPressed: () {
                  controller.sendMessage({
                    'event': MessageEvents.play.index,
                    'args': {
                      'soundHash': audioSource.soundHash,
                      'volume': 1.0,
                      'pan': 1.0,
                      'paused': false,
                      'looping': false,
                      'loopingStartAt': Duration.zero,
                    },
                  });
                },
                child: const Text('MessageEvents.play'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
