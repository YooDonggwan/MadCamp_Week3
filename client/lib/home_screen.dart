import 'dart:io' as io;

import 'package:mindonglody/recorder_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class AudioFile {
  String filePath;
  String fileName;
  String fileDate;
  Duration fileDuration;
  Duration filePosition;

  String get path {
    return filePath;
  }

  String get name {
    return fileName;
  }

  String get date {
    return fileDate;
  }

  Duration get duration {
    return fileDuration;
  }

  Duration get position {
    return filePosition;
  }

  set path(String path) {
    this.filePath = path;
  }

  set name(String name) {
    this.fileName = name;
  }

  set date(String date) {
    this.fileDate = date;
  }

  set duration(Duration duration) {
    this.fileDuration = duration;
  }

  set position(Duration position) {
    this.filePosition = position;
  }
}

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AudioFile> audioFiles = [];
  bool isLoading = true;
  bool isStopped = false;
  // bool reallyDelete = false;
  int selectedItem;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _getFiles();

    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() => audioFiles[selectedItem].duration = d);
    });
    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      setState(() => audioFiles[selectedItem].position = p);
    });
  }

  void _getFiles() async {
    io.Directory dir;
    if (io.Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getExternalStorageDirectory();
    }

    await dir.list(recursive: false).forEach((f) {
      AudioFile audioFile = new AudioFile();
      var path = f.path.split('/');
      audioFile.path =
          path.sublist(0, path.length - 1).reduce((acc, e) => acc + '/' + e) +
              '/';
      audioFile.name = path[path.length - 1];
      audioFile.date =
          io.File(f.path).statSync().changed.toString().split(' ')[0];
      audioFile.duration =
          Duration(seconds: io.File(f.path).statSync().size ~/ 32000);
      audioFile.position = new Duration(seconds: 0);

      audioFiles.add(audioFile);
    });
    setState(() {
      isLoading = false;
    });
  }

  ListView _buildList() {
    return ListView.separated(
      itemCount: audioFiles.length,
      separatorBuilder: (BuildContext context, int index) =>
          Divider(color: Colors.grey),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(audioFiles[index].name),
          subtitle: Text(audioFiles[index].date),
          selected: selectedItem == index,
          onTap: () {
            setState(() {
              selectedItem = (selectedItem == index) ? null : index;
            });
          },
        );
      },
    );
  }

  void _removeItem() {
    if (selectedItem != null) {
      io.Directory(audioFiles[selectedItem].path).deleteSync(recursive: true);
      setState(() {
        audioFiles.removeAt(selectedItem);
        selectedItem = null;
      });
    }
  }

  _play() async {
    int result = await audioPlayer
        .play(audioFiles[selectedItem].path + audioFiles[selectedItem].name);
    if (result == 1) {
      // success
    }
  }

  _pause() async {
    int result = await audioPlayer.pause();
    if (result == 1) {
      // success
      setState(() {
        isStopped = true;
      });
    }
  }

  _stop() async {
    int result = await audioPlayer.stop();
    if (result == 1) {
      // success
      setState(() {
        audioFiles[selectedItem].position = new Duration(seconds: 0);
      });
    }
  }

  _resume() async {
    int result = await audioPlayer.resume();
    if (result == 1) {
      // success
      setState(() {
        isStopped = false;
      });
    }
  }

  String sDuration(Duration duration) {
    if (duration == null) {
      return "00:00";
    } else {
      var minute = duration.inMinutes.remainder(60);
      var second = duration.inSeconds.remainder(60);
      return "${minute >= 10 ? minute : '0' + minute.toString()}:${second >= 10 ? second : '0' + second.toString()}";
    }
  }

  Widget _showBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: <Widget>[
          Expanded(
            child: _buildList(),
          ),
          selectedItem == null
              ? Container()
              : Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          LinearPercentIndicator(
                            lineHeight: 5.0,
                            percent: (audioFiles[selectedItem]
                                    .position
                                    .inSeconds) /
                                (audioFiles[selectedItem].duration.inSeconds),
                            progressColor: Colors.blue,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${sDuration(audioFiles[selectedItem].position)}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                "${sDuration(audioFiles[selectedItem].duration)}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.grey[300],
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FlatButton(
                            child: Icon(
                              Icons.play_arrow,
                              size: 40.0,
                            ),
                            onPressed: () {
                              isStopped ? _resume() : _play();
                            },
                          ),
                          FlatButton(
                            child: Icon(
                              Icons.pause,
                              size: 40.0,
                            ),
                            onPressed: () {
                              _pause();
                            },
                          ),
                          FlatButton(
                            child: Icon(
                              Icons.stop,
                              size: 40.0,
                            ),
                            onPressed: () {
                              _stop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Records'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              size: 30.0,
            ),
            onPressed: () async {
              AudioFile audioFile = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RecorderScreen()));
              // print("Test: ${audioFile.name}");
              // print("Test: ${audioFile.path}");
              // print("Test: ${audioFile.position}");
              // print("Test: ${audioFile.duration}");
              setState(() {
                audioFiles.add(audioFile);
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              size: 30.0,
            ),
            onPressed: () => _removeItem(),
          ),
        ],
      ),
      body: _showBody(),
    );
  }
}
