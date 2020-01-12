import 'dart:io' as io;
import 'recorder_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> fileList = [];
  bool isLoading = true;
  int selectedItem;
  String header;

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

    header = dir.path;

    await dir.list(recursive: false).forEach((f) {
      int i = f.path.indexOf('files/');
      fileList.add(f.path.substring(i + 6));
    });

    setState(() {
      isLoading = false;
    });
  }

  ListView _buildList() {
    return ListView.separated(
      itemCount: fileList.length,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(fileList[index]),
          selected: selectedItem == index,
          onTap: () { // 클릭 가능하게 ?
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
      io.Directory(header + '/' + fileList[selectedItem])
          .deleteSync(recursive: true);
      setState(() {
        fileList.removeAt(selectedItem);
        selectedItem = null;
      });
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
            onPressed: () {
              Navigator.pushNamed(context, RecorderScreen.id);
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
      body:
          isLoading ? Center(child: CircularProgressIndicator()) : _buildList(),
      // Column(
      //   children: <Widget>[
      //     selectedItem == null
      //         ? Container()
      //         : Container(
      //             child: Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //             children: <Widget>[
      //               FlatButton(
      //                 child: Icon(Icons.play_arrow),
      //                 onPressed: () {
      //                   print("play");
      //                 },
      //               ),
      //               FlatButton(
      //                 child: Icon(Icons.pause),
      //                 onPressed: () {
      //                   print("pause");
      //                 },
      //               ),
      //               FlatButton(
      //                 child: Icon(Icons.stop),
      //                 onPressed: () {
      //                   print("stop");
      //                 },
      //               ),
      //             ],
      //           ))
      //   ],
      // ),
    );
  }
}

// import 'dart:async';
// import 'dart:io' as io;

// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// class FileScreen extends StatefulWidget {
//   static const String id = 'file_screen';
//   @override
//   _FileScreenState createState() => _FileScreenState();
// }

// class _FileScreenState extends State<FileScreen> {
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
//   ListModel<String> _list;
//   String _selectedItem;
//   int _nextItemIndex; // The next item inserted when the user presses the '+' button.
//   List<String> fileList;
//   bool isLoading = true;

//   void _getPath() async {
//     io.Directory dir;
//     if (io.Platform.isIOS) {
//       dir = await getApplicationDocumentsDirectory();
//     } else {
//       dir = await getExternalStorageDirectory();
//     }

//     print(dir.list(recursive: false));
//     // you must init
//     fileList = <String>[];
//     await dir.list(recursive: false).forEach((f) {
//       print(f.path);
//       setState(() {
//         fileList.add(f.path);
//       });
//     });
//     setState(() {
//       isLoading = false;
//     });
//     print(fileList);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getPath(); // get audio file list
//     _list = ListModel<String>(
//       listKey: _listKey,
//       initialItems: fileList,
//       removedItemBuilder: _buildRemovedItem,
//     );
//     setState(() {
//       _nextItemIndex = isLoading ? 0 : fileList.length;
//     });
//   }

//   // Used to build list items that haven't been removed.
//   Widget _buildItem(
//       BuildContext context, int index, Animation<double> animation) {
//     return CardItem(
//       animation: animation,
//       item: _list[index],
//       selected: identical(_selectedItem, _list[index]),
//       onTap: () {
//         setState(
//           () {
//             _selectedItem =
//                 identical(_selectedItem, _list[index]) ? null : _list[index];
//           },
//         );
//       },
//     );
//   }

//   // Used to build an item after it has been removed from the list. This method is
//   // needed because a removed item remains  visible until its animation has
//   // completed (even though it's gone as far this ListModel is concerned).
//   // The widget will be used by the [AnimatedListState.removeItem] method's
//   // [AnimatedListRemovedItemBuilder] parameter.
//   Widget _buildRemovedItem(
//       String item, BuildContext context, Animation<double> animation) {
//     return CardItem(
//       animation: animation,
//       item: item,
//       selected: false,
//       // No gesture detector here: we don't want removed items to be interactive.
//     );
//   }

//   // //Insert the "next item" into the list model.
//   void _insert() {
//     final int index =
//         _selectedItem == null ? _list.length : _list.indexOf(_selectedItem);
//     print(fileList[_nextItemIndex]);
//     _list.insert(index, fileList[_nextItemIndex++]);
//   }

//   // Remove the selected item from the list model.
//   void _remove() {
//     if (_selectedItem != null) {
//       _list.removeAt(_list.indexOf(_selectedItem));
//       setState(() {
//         _selectedItem = null;
//       });
//     }
//   }

//   // () {
//   //               Navigator.push(
//   //                 context,
//   //                 MaterialPageRoute(
//   //                   builder: (context) => RecordApp(),
//   //                 ),
//   //               );
//   //             },

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Loading...'),
//         ),
//       );
//     } else {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Records'),
//           actions: <Widget>[
//             IconButton(
//               icon: const Icon(Icons.add_circle),
//               onPressed: _insert,
//               tooltip: 'insert a  record',
//             ),
//             IconButton(
//               icon: const Icon(Icons.remove_circle),
//               onPressed: _remove,
//               tooltip: 'remove the selected item',
//             ),
//           ],
//         ),
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: AnimatedList(
//               key: _listKey,
//               initialItemCount: _list.length,
//               itemBuilder: _buildItem,
//             ),
//           ),
//         ),
//       );
//     }
//   }
// }

// /// Keeps a Dart List in sync with an AnimatedList.
// ///
// /// The [insert] and [removeAt] methods apply to both the internal list and the
// /// animated list that belongs to [listKey].
// ///
// /// This class only exposes as much of the Dart List API as is needed by the
// /// sample app. More list methods are easily added, however methods that mutate the
// /// list must make the same changes to the animated list in terms of
// /// [AnimatedListState.insertItem] and [AnimatedList.removeItem].
// class ListModel<E> {
//   ListModel({
//     @required this.listKey,
//     @required this.removedItemBuilder,
//     Iterable<E> initialItems,
//   })  : assert(listKey != null),
//         assert(removedItemBuilder != null),
//         _items = List<E>.from(initialItems ?? <E>[]);

//   final GlobalKey<AnimatedListState> listKey;
//   final dynamic removedItemBuilder;
//   final List<E> _items;

//   AnimatedListState get _animatedList => listKey.currentState;

//   void insert(int index, E item) {
//     _items.insert(index, item);
//     _animatedList.insertItem(index);
//   }

//   E removeAt(int index) {
//     final E removedItem = _items.removeAt(index);
//     if (removedItem != null) {
//       _animatedList.removeItem(index,
//           (BuildContext context, Animation<double> animation) {
//         return removedItemBuilder(removedItem, context, animation);
//       });
//     }
//     return removedItem;
//   }

//   int get length => _items.length;

//   E operator [](int index) => _items[index];

//   int indexOf(E item) => _items.indexOf(item);
// }

// class CardItem extends StatelessWidget {
//   CardItem(
//       {Key key,
//       @required this.animation,
//       this.onTap,
//       @required this.item,
//       this.selected: false})
//       : assert(animation != null),
//         assert(item != null && !identical(item, "")),
//         assert(selected != null),
//         super(key: key);

//   final Animation<double> animation;
//   final VoidCallback onTap;
//   final String item;
//   final bool selected;

//   void onPlayAudio(String path) async {
//     AudioPlayer audioPlayer = AudioPlayer();
//     await audioPlayer.play(path, isLocal: true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // TextStyle textStyle = Theme.of(context).textTheme.display1;
//     // if (selected)
//     //   textStyle =
//     //       textStyle.copyWith(color: Colors.lightGreenAccent[400]);
//     return SizeTransition(
//       axis: Axis.vertical,
//       sizeFactor: animation,
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: onTap,
//         child: SizedBox(
//           height: selected ? 130 : 60,
//           child: Card(
//             color: Colors.grey[100],
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Text(
//                         item,
//                         style: TextStyle(
//                           fontSize: 15.0,
//                         ),
//                       ),
//                       Text(
//                         "2020/01/02",
//                         style: TextStyle(
//                           fontSize: 15.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                   selected
//                       ? (SizedBox(
//                           child: Divider(),
//                         ))
//                       : Container(),
//                   selected
//                       ? (Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: <Widget>[
//                             FlatButton(
//                               child: Icon(Icons.play_arrow),
//                               onPressed: () {
//                                 print("play");
//                               },
//                             ),
//                             FlatButton(
//                               child: Icon(Icons.pause),
//                               onPressed: () {
//                                 print("pause");
//                               },
//                             ),
//                             FlatButton(
//                               child: Icon(Icons.stop),
//                               onPressed: () {
//                                 print("stop");
//                               },
//                             ),
//                           ],
//                         ))
//                       : Container(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
