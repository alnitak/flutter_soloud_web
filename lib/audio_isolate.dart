// ignore_for_file: require_trailing_commas, public_member_api_docs,
// ignore_for_file: unnecessary_breaks
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:html' as html;

import 'package:flutter_soloud/worker/js_import.dart';
import 'package:flutter_soloud/worker/send_port_io.dart';
import 'package:flutter_soloud/worker/worker_web.dart'
    if (dart.library.io) 'package:flutter_soloud/worker/worker_io.dart';

import 'audio_source.dart';
import 'enums.dart';
import 'soloud_controller.dart';
import 'sound_handle.dart';
import 'sound_hash.dart';

/// print some infos when isolate receive events
/// from main isolate and vice versa
void debugIsolates(String text) {
  // TODO(filiph): Decide how to forward logging from isolate to main thread?
  print(text);
}

enum MessageEvents {
  initEngine,
  startLoop,
  loop,
  loadFile,
  loadWaveform,
  speechText,
  play,
  play3d,
  stop,
  disposeSound,
  disposeAllSound,
  loadSoLoudJS,
}

// /// definitions to be checked in main isolate
typedef ArgsInitEngine = ();
typedef ArgsDisposeEngine = ();
typedef ArgsLoadFile = ({String completeFileName, LoadMode mode});
typedef ArgsLoadWaveform = ({
  int waveForm,
  bool superWave,
  double scale,
  double detune,
});
typedef ArgsSpeechText = ({String textToSpeech});
typedef ArgsPlay = ({
  SoundHash soundHash,
  double volume,
  double pan,
  bool paused,
  bool looping,
  Duration loopingStartAt,
});
typedef ArgsPlay3d = ({
  SoundHash soundHash,
  double posX,
  double posY,
  double posZ,
  double velX,
  double velY,
  double velZ,
  double volume,
  bool paused,
  bool looping,
  Duration loopingStartAt,
});
typedef ArgsStop = ({SoundHandle handle});
typedef ArgsDisposeSound = ({SoundHash soundHash});
typedef ArgsDisposeAllSound = ();

/// [data] comes with Map type when usig Isolate. It is a jsonEncoded string
/// on web worker
Map _parseEventData(dynamic data) {
  Map ret = {};
  switch (data) {
    case Map():
      ret = data;

    /// A String can be a Map() or a String. Try the Map() first
    case String():
      try {
        ret = jsonDecode(data);
      } catch (e) {
        print('_parseEventData: failed to parse [$data]');
      }
  }
  return ret;
}

/// Top Level audio isolate function
///
/// The purpose of this isolate is:
/// - send back to main isolate the communication port
/// - listen to messages from main isolate
/// - when a new message come, execute it and send back the result
/// Since from C is difficult to call dart function from another thread for now,
/// I did this isolate with the main purpose to make use of some callbacks
/// like playEndedCallback. Ref: https://github.com/dart-lang/sdk/issues/37022
/// MD https://github.com/mraleph/language/blob/shared-memory/working/333%20-%20shared%20memory%20multithreading/proposal.md
/// PR doc Shared Memory Multithreading https://github.com/dart-lang/language/pull/3531
void audioIsolate(SendPort? isolateToMainStream) async {
  print('Worker created. isolateToMainStream: $isolateToMainStream\n');

  // html.WorkerGlobalScope.instance.self
  //     .importScripts('libflutter_soloud_plugin.js');

  var worker = Worker(args: isolateToMainStream);
  final mainToIsolateStream = worker.onReceive();
  final soLoudController = SoLoudController();

  /// the active sounds
  final activeSounds = <AudioSource>[];
  var loopRunning = false;

  /// Tell the main isolate how to communicate with this isolate
  // worker.sendMessage(mainToIsolateStream.sendPort);

  /// Listen to events from the main isolate
  mainToIsolateStream.listen((data) {
    final newData = _parseEventData(data);

    print('******** audioIsolate()1: $newData');
    final event = MessageEvents.values[newData['event'] as int];
    print('******** audioIsolate()2: $event');
    Map args = _parseEventData(newData['args']);

    print('******** audioIsolate()3: $args');
    if (event != MessageEvents.loop) {
      /// don't print the loop message
      debugIsolates('******** ISOLATE EVENT data: $data');
    }

    switch (event) {
      case MessageEvents.loadSoLoudJS:
        // var m =
        //     jsonEncode({'event': newData['event'], 'args': {}, 'return': {}});
        // print(']]]]]]]]]]]]]]] WORKER MessageEvents.loadSoLoudJS  $m');

        // worker.sendMessage(m);
        final s = SoundHandle(args['handle']);
        print(']]]]]]]]]]]]]]] WORKER MessageEvents.loadSoLoudJS  $s');
        final isValid =
            soLoudController.soLoudFFI.getIsValidVoiceHandle(s);
        print(']]]]]]]]]]]]]]] WORKER MessageEvents.loadSoLoudJS  $isValid');
        break;

      case MessageEvents.initEngine:
        final ret = soLoudController.soLoudFFI.initEngine();
        print('*** INITENGINE1  $ret');

        final ret2 = soLoudController.soLoudFFI.loadWaveform(
          WaveForm.fSaw,
          true,
          1.0,
          1.0,
        );
        var s = ret2['soundHash'] as SoundHash;
        print('*** INITENGINE2  ${s.hash}');

        final ret3 = soLoudController.soLoudFFI.play(s);
        print('*** INITENGINE3  $ret3');

        var m =
            jsonEncode({'event': newData['event'], 'args': {}, 'return': {}});
        print('@@@@@@@@@@@ MessageEvents.initEngine ret: $m');
        worker.sendMessage(
            jsonEncode({'event': newData['event'], 'args': {}, 'return': 0}));
        break;

      case MessageEvents.loadFile:
        final ret = soLoudController.soLoudFFI.loadFile(
          args['completeFileName'],
          args['mode'],
        );
        print('@@@@@@@@@@@ ret: $ret');
        // add the new sound handler to the list
        AudioSource? newSound;
        if (ret.error == PlayerErrors.noError) {
          newSound = AudioSource(ret.soundHash);
          activeSounds.add(newSound);
        } else if (ret.error == PlayerErrors.fileAlreadyLoaded) {
          /// the file is already loaded.
          /// Check if it is already in [activeSound] else add it
          var isAlreadyThere = true;
          newSound = activeSounds.firstWhere(
            (s) => s.soundHash == ret.soundHash,
            orElse: () {
              isAlreadyThere = false;
              return AudioSource(ret.soundHash);
            },
          );
          if (!isAlreadyThere) activeSounds.add(newSound);
        }
        worker.sendMessage({
          'event': event,
          'args': args,
          'return': (error: ret.error, sound: newSound),
        });
        break;

      case MessageEvents.loadWaveform:
        final ret = soLoudController.soLoudFFI.loadWaveform(
          args['waveForm'] as WaveForm,
          args['superWave'] as bool,
          args['scale'] as double,
          args['detune'] as double,
        );
        // add the new sound handler to the list
        AudioSource? newSound;
        if (ret['error'] == PlayerErrors.noError) {
          newSound = AudioSource(ret['soundHash']);
          activeSounds.add(newSound);
        } else if (ret['error'] == PlayerErrors.fileAlreadyLoaded) {
          /// the file is already loaded.
          /// Check if it is already in [activeSound] else add it
          var isAlreadyThere = true;
          newSound = activeSounds.firstWhere(
            (s) => s.soundHash == ret['soundHash'],
            orElse: () {
              isAlreadyThere = false;
              return AudioSource(ret['soundHash']);
            },
          );
          if (!isAlreadyThere) activeSounds.add(newSound);
        }
        worker.sendMessage({
          'event': event,
          'args': args,
          'return': {'error': ret['error'], 'sound': newSound},
        });
        break;

      case MessageEvents.speechText:
        final ret = soLoudController.soLoudFFI.speechText(args['textToSpeech']);
        final newSound = AudioSource(SoundHash.random());
        newSound.handlesInternal.add(ret.handle);
        if (ret.error == PlayerErrors.noError) {
          // Add the new sound to the list
          activeSounds.add(newSound);
        }
        worker.sendMessage({
          'event': event,
          'args': args,
          'return': (error: ret.error, sound: newSound),
        });
        break;

      case MessageEvents.play:
        final ret = soLoudController.soLoudFFI.play(
          args['soundHash'] as SoundHash,
          volume: args['volume'] as double,
          pan: args['pan'] as double,
          paused: args['paused'] as bool,
          looping: args['looping'] as bool,
          loopingStartAt: args['loopingStartAt'] as Duration,
        );

        if (ret.error != PlayerErrors.noError) {
          worker.sendMessage({
            'event': event,
            'args': args,
            'return': {
              'error': ret.error,
              'newHandle': SoundHandle.error(),
            },
          });
          break;
        }

        // add the new handle to the [activeSound] hash list
        try {
          activeSounds
              .firstWhere((s) => s.soundHash == args['soundHash'] as SoundHash)
              .handlesInternal
              .add(ret.newHandle);
        } catch (e) {
          print('No sound with soundHash ${args['soundHash']} found!');
          worker.sendMessage({
            'event': event,
            'args': args,
            'return': (
              error: PlayerErrors.soundHashNotFound,
              newHandle: SoundHandle.error(),
            ),
          });
          break;
        }
        worker.sendMessage({
          'event': event,
          'args': args,
          'return': (error: PlayerErrors.noError, newHandle: ret.newHandle),
        });
        break;

      case MessageEvents.stop:
        soLoudController.soLoudFFI.stop(args['handle']);

        /// find a sound with this handle and remove that handle from the list
        for (final sound in activeSounds) {
          sound.handlesInternal
              .removeWhere((element) => element == args['handle']);
        }

        worker.sendMessage({'event': event, 'args': args, 'return': ()});
        break;

      case MessageEvents.disposeSound:
        soLoudController.soLoudFFI.disposeSound(args['soundHash']);

        /// find a sound with this handle and remove that handle from the list
        activeSounds
            .removeWhere((element) => element.soundHash == args['soundHash']);

        worker.sendMessage({'event': event, 'args': args, 'return': ()});
        break;

      case MessageEvents.disposeAllSound:
        soLoudController.soLoudFFI.disposeAllSound();

        /// send the [SoundEvent.soundDisposed] event to main isolate
        for (final sound in activeSounds) {
          worker.sendMessage(
            (
              event: SoundEventType.soundDisposed,
              sound: sound,
              handle: 0,
            ),
          );
        }

        /// Clear the sound list
        activeSounds.clear();

        worker.sendMessage({'event': event, 'args': args, 'return': ()});
        break;

      //////////////////////////////////
      /// 3D audio

      case MessageEvents.play3d:
        final ret = soLoudController.soLoudFFI.play3d(
          args['soundHash'],
          args['posX'],
          args['posY'],
          args['posZ'],
          velX: args['velX'],
          velY: args['velY'],
          velZ: args['velZ'],
          volume: args['volume'],
          paused: args['paused'],
          looping: args['looping'],
          loopingStartAt: args['loopingStartAt'],
        );

        if (ret.error != PlayerErrors.noError) {
          worker.sendMessage({
            'event': event,
            'args': args,
            'return': (
              error: ret.error,
              newHandle: SoundHandle.error(),
            ),
          });
          break;
        }

        // add the new handle to the [activeSound] hash list
        try {
          activeSounds
              .firstWhere((s) => s.soundHash == args['soundHash'])
              .handlesInternal
              .add(ret.newHandle);
        } catch (e) {
          print('No sound with soundHash ${args['soundHash']} found!');
          worker.sendMessage({
            'event': event,
            'args': args,
            'return': (
              error: PlayerErrors.soundHashNotFound,
              newHandle: SoundHandle.error(),
            ),
          });
          break;
        }
        worker.sendMessage({
          'event': event,
          'args': args,
          'return': (error: PlayerErrors.noError, newHandle: ret.newHandle),
        });
        break;

      //////////////////////////////////
      /// LOOP
      case MessageEvents.startLoop:
        loopRunning = true;
        worker.sendMessage(
            {'event': MessageEvents.startLoop, 'args': (), 'return': ()});
        worker.sendMessage(
          {
            'event': MessageEvents.loop,
            'args': (),
          },
        );
        break;

      case MessageEvents.loop:
        if (loopRunning) {
          for (final sound in activeSounds) {
            final removeInvalid = <void Function()>[];
            // check valid handles in [sound] list
            for (final handle in sound.handlesInternal) {
              final isValid =
                  soLoudController.soLoudFFI.getIsValidVoiceHandle(handle);
              if (!isValid) {
                /// later, outside the loop, remove the handle
                removeInvalid.add(() {
                  sound.handlesInternal.remove(handle);

                  worker.sendMessage(
                    (
                      event: SoundEventType.handleIsNoMoreValid,
                      sound: sound,
                      handle: handle,
                    ),
                  );
                });
              }
            }
            for (final f in removeInvalid) {
              f();
            }
          }

          /// Call again this isolate after N ms to let other messages
          /// to be managed
          Future.delayed(const Duration(milliseconds: 10), () {
            // TODO(marco): is 10 ms ok to loop again?
            worker.sendMessage(
              {'event': MessageEvents.loop, 'args': ()},
            );
          });
        }
        break;
    }
  });

  // for (var i = 0; i < 999999999; i++) {
  //   print('audio_isolate: $i');
  //   await Future.delayed(const Duration(milliseconds: 5000), () {});
  // }
}

/// The main() function is needed only when compiling a .dart file to .js.
/// It will be called only when spawing a web worker.
void main() {
  audioIsolate(null);
}
