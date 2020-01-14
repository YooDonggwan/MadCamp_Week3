import 'dart:io' as io;
import 'dart:async';
import 'dart:convert';

import 'package:mindonglody/home_screen.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file/file.dart';
import 'package:http/http.dart' as http;

class RecorderScreen extends StatefulWidget {
  static const String id = 'recorder_screen';
  final LocalFileSystem localFileSystem;

  RecorderScreen({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _RecorderScreenState createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  String mSound; // sound 파일 담을 곳
  AudioFile audioFile = new AudioFile();
  String name = "";

  @override
  void initState() {
    super.initState();
    _init();
  }

  _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("녹음 저장"),
          content: TextField(
            decoration: InputDecoration(
              hintText: "녹음 파일 이름",
            ),
            onChanged: (text) {
              setState(() {
                audioFile.name = text + ".wav";
              });
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("취소"),
              onPressed: () {
                setState(() {
                  audioFile.name = name;
                });
                print(audioFile.name);
                Navigator.of(context).pop(audioFile);
              },
            ),
            FlatButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop(audioFile);
              },
            )
          ],
        );
      },
    );
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        setState(() {
          name = 'audio_' +
              DateTime.now().millisecondsSinceEpoch.toString() +
              '.wav';
          audioFile.name = name;
        });
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        audioFile.path = appDocDirectory.path;
        audioFile.position = new Duration(seconds: 0);
        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder = FlutterAudioRecorder(audioFile.path + '/' + name,
            audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
        });
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("You must accept permissions"),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  // _resume() async {
  //   await _recorder.resume();
  //   setState(() {});
  // }

  // _pause() async {
  //   await _recorder.pause();
  //   setState(() {});
  // }

  final gServerIp = 'http://34.84.158.57:7081'; // 서버 주소

  _stop() async {
    var result = await _recorder.stop();

    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    audioFile.duration = result.duration;
    var date = DateTime.fromMicrosecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch * 1000);
    audioFile.date = date.toString().split(' ')[0];
    File file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });

    await _showDialog();

    await _postRequest(result);
  }

  _postRequest(var result) async {
    var serverAddr = gServerIp + "/pitch_shift";

    var request = http.MultipartRequest('POST', Uri.parse(serverAddr))
      ..fields['method'] = 'PUT'
      ..fields['key1'] = '4'
      ..fields['key2'] = '7'
      ..files.add(await http.MultipartFile.fromPath('file', result.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Uploaded!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(audioFile),
          ),
          title: Text('Record Room')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Icon(
                  Icons.fiber_manual_record,
                  color: Colors.red,
                  size: 100.0,
                ),
                onPressed: () {
                  _start();
                },
              ),
              FlatButton(
                child: Icon(
                  Icons.stop,
                  color: Colors.black54,
                  size: 100.0,
                ),
                onPressed: (() async {
                  await _stop();
                  await _showDialog();
                  Navigator.of(context).pop(audioFile);
                }),
              ),
            ],
          ),
          SizedBox(height: 30.0),
          Text(
            "녹음 시간: ${_current?.duration?.inSeconds ?? 0}초",
            style: TextStyle(
              fontSize: 30.0,
            ),
          ),
        ],
      ),
    );
  }
}
