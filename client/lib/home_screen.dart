import 'dart:io' as io;

import 'package:mindonglody/recorder_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> fileList = [];
  bool isLoading = true;
  // bool reallyDelete = false;
  int selectedItem;
  AudioPlayer audioPlayer = AudioPlayer();
  Duration d;

  @override
  void initState() {
    super.initState();
    _getFiles();
  }

  void _getFiles() async {
    io.Directory dir;
    if (io.Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getExternalStorageDirectory();
    }

    await dir.list(recursive: false).forEach((f) {
      fileList.add(f.path);
    });

    setState(() {
      isLoading = false;
    });
  }

  ListView _buildList() {
    return ListView.separated(
      itemCount: fileList.length,
      separatorBuilder: (BuildContext context, int index) =>
          Divider(color: Colors.grey),
      itemBuilder: (BuildContext context, int index) {
        String milliseconds = fileList[index].split(new RegExp('[./_]'))[13];
        String date =
            DateTime.fromMillisecondsSinceEpoch(int.parse(milliseconds))
                .toString()
                .split(' ')[0];

        return ListTile(
          title: Text(fileList[index].split('/')[8]),
          subtitle: Text(date),
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
      io.Directory(fileList[selectedItem]).deleteSync(recursive: true);
      setState(() {
        fileList.removeAt(selectedItem);
        selectedItem = null;
      });
    }
  }

  _play() async {
    int result = await audioPlayer.play(fileList[selectedItem]);
    if (result == 1) {
      // success
    }
  }

  _pause() async {
    int result = await audioPlayer.pause();
    if (result == 1) {
      // success
    }
  }

  _stop() async {
    int result = await audioPlayer.stop();
    if (result == 1) {
      // success
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
              : Container(
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
                          _play();
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
            onPressed: () => Navigator.pushNamed(context, RecorderScreen.id),
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
