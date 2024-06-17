// ignore_for_file: avoid_print

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/src/audio_source.dart';
import 'dart:async';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter_soloud/src/sound_handle.dart';
import 'package:flutter_soloud/src/sound_hash.dart';
import 'package:flutter_soloud/src/soloud.dart';
import 'package:flutter_soloud/src/enums.dart';
import 'package:flutter_soloud/src/filter_params.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final _flutterSoloudPlugin = FlutterSoloudWeb();
  final _flutterSoloudPlugin = SoLoud.instance;
  late AudioSource audioSource;
  late SoundHash soundHash;
  late SoundHandle soundHandle;

  @override
  void initState() {
    super.initState();
    _flutterSoloudPlugin.init();
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
                  // _flutterSoloudPlugin.sendMessage('voiceEndedCallback',7777);
                },
                child: const Text('send to worker'),
              ),
              OutlinedButton(
                onPressed: () async {
                  _flutterSoloudPlugin
                      .getFilterParamNames(FilterType.biquadResonantFilter);
                },
                child: const Text('getFilterParamNames'),
              ),
              OutlinedButton(
                onPressed: () async {
                  audioSource = await _flutterSoloudPlugin.loadWaveform(
                    WaveForm.bounce,
                    true,
                    1,
                    1,
                  );
                  soundHash = audioSource.soundHash;
                  print('main loadWaveform audioSource: $soundHash');
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
                      File('/home/deimos/5/12.-Animal Instinct.flac')
                          .readAsBytesSync(),
                    );
                    soundHash = sound.soundHash;
                  }
                  print('****** FILE LOADED $soundHash');
                },
                child: const Text('load mem'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final byteData =
                      await rootBundle.load('assets/explosion.mp3');
                  final buffer = byteData.buffer;
                  audioSource = await _flutterSoloudPlugin.loadMem(
                    'assets/explosion.mp3',
                    buffer.asUint8List(),
                  );
                  soundHash = audioSource.soundHash;
                },
                child: const Text('loadMem explosion'),
              ),
              OutlinedButton(
                onPressed: () async {
                  soundHandle = await _flutterSoloudPlugin.play(audioSource);
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
