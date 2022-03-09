import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pigie_tracker/types.dart';
import 'package:pigie_tracker/utils.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pigie Tracker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(
        title: 'Pigie Tracker',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class HistoryPage extends StatefulWidget {
  HistoryPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<History> _histories = [];

  Future<void> init() async {
    final histories = historyFromJson(await getData());
    setState(() {
      _histories = histories;
    });
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pigie Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          child: ListView(
            children: _histories.map((e) {
              return Card(
                  child: ListTile(
                      onTap: () async {
                        final path = await localPath();
                        showDialog(
                            context: context,
                            builder: (BuildContext b) {
                              return SimpleDialog(
                                title: Text(e.date.toIso8601String()),
                                children: [
                                  Container(
                                      width: 400,
                                      height: 400,
                                      child: ListView(
                                        children: e.pigeons.map((p) {
                                          return Card(
                                            child: ListTile(
                                              title: Text(p.name),
                                              leading: Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: FileImage(File(
                                                              '$path/images/${p.name}.png'))))),
                                              subtitle:
                                                  Text(p.status.toString()),
                                            ),
                                          );
                                        }).toList(),
                                      ))
                                ],
                              );
                            });
                      },
                      title: Text(e.date.toIso8601String()),
                      trailing: Icon(Icons.more_vert),
                      subtitle: Text(e.time.toString())));
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  PickedFile _image;
  Map<String, File> _images = {};
  List<String> images = [];
  List<History> _histories = [];
  String _path = "";
  Map<int, bool> checkboxValues = {};
  ImagePicker picker = ImagePicker();
  final webHookUrl =
      "https://discord.com/api/webhooks/929354335001931846/iXmTOrM4I3UrDs70V5D8MOVlK-ci9wrze0I-nUvmm2dDF-Y2J5KlxDU4B4slhckHvBbo";

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    final path = await localPath();

    final imageDirectory = Directory('$path/images');

    if (!await imageDirectory.exists()) {
      await imageDirectory.create();
    }

    final files = await imageDirectory.list().toList();

    final value = files.length;

    if (!(await localFile()).existsSync()) {
      await writeData("");
    }

    final json = await getData();

    List<History> histories = [];

    if (json != "") {
      histories = historyFromJson(json);
    }

    // var array = Iterable<int>.generate(value).toList().map((idx) {
    //   final val = files[idx];
    //
    //   return File(val.path);
    // });
    var map = files.asMap().map((key, entity) {
      final name = entity.path.split("/").last.replaceAll(".png", "");

      setState(() {
        checkboxValues[key] = false;
      });

      return MapEntry(name, File(entity.path));
    });

    setState(() {
      _counter = value;
      _images = map;
      images = map.keys.toList();
      _histories = histories;
    });
  }

  Future<File> getImage() async {
    final image = await picker.getImage(source: ImageSource.camera);

    final name = await showDialog<String>(
        context: context,
        builder: (BuildContext build) {
          var value = "";
          return SimpleDialog(
            contentPadding: EdgeInsets.all(15),
            title: const Text("Name This Pigeon"),
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                    // border: OutlineInputBorder(),
                    hintText: "Pigeon Name"),
                onChanged: (String v) {
                  value = v;
                },
              ),
              MaterialButton(
                  child: const Text("Save"),
                  color: Colors.lightBlueAccent,
                  onPressed: () {
                    if (value != "") {
                      Navigator.pop(context, value);
                    }
                  })
            ],
          );
        });

    print(name);

    var bytes = await image.readAsBytes();
    await writeImage(bytes, '$name.png');
    var path = await localPath();
    setState(() {
      _image = image;
      _images[name] = File('$path/images/$name.png');
      images = _images.keys.toList();
      _path = path;
      checkboxValues[_counter] = false;
      _counter++;
    });
  }

  Future<void> saveSnapshot() async {
    final time = await showDialog<Time>(
        context: context,
        builder: (BuildContext build) {
          return SimpleDialog(
              title: const Text('Select Snapshot Time'),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, Time.Day);
                  },
                  child: const Text('Day'),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, Time.Night);
                  },
                  child: const Text('Night'),
                ),
              ]);
        });

    final date = DateTime.now();

    var content = "Daily Checkup: \n ${date.toIso8601String()}";

    var count = 0;

    final pigeons = _images.keys.map((name) {
      final status = checkboxValues[count] ? Status.Present : Status.Unknown;

      content += "```$name:${status.toString()}\n```";
      count++;
      return Pigeon(name: name, status: status);
    }).toList();

    final history = History(date: date, time: time, pigeons: pigeons);

    setState(() {
      _histories.add(history);
    });

    await writeData(historyToJson(_histories));

    final result = await http.post(Uri.parse(webHookUrl),
        body: new Discord(content: content).toJson());

    if (result.statusCode == 204) {
      showDialog(
          context: context,
          builder: (BuildContext b) {
            return AlertDialog(
                title: Text("Pigeon Snapshot Saved Successfully."));
          });
    }
  }

  final checkbox_x = -1.0993 - 0.09 - 0.01;
  final checkbox_y = -2.0993 - 0.09 - 0.01;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemCount: checkboxValues.keys.length,
                    itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext build) {
                                  var name = images[index];
                                  return SimpleDialog(
                                      title: Text('Pigeon $name'),
                                      children: <Widget>[
                                        SimpleDialogOption(
                                          onPressed: () async {
                                            var name = await showDialog(
                                                context: context,
                                                builder: (BuildContext build) {
                                                  var value = "";
                                                  return SimpleDialog(
                                                    children: [
                                                      TextField(
                                                        decoration:
                                                            InputDecoration(
                                                                // border: OutlineInputBorder(),
                                                                hintText:
                                                                    "Pigeon Name"),
                                                        onChanged: (String v) {
                                                          value = v;
                                                        },
                                                      ),
                                                      MaterialButton(
                                                          child: const Text(
                                                              "Save"),
                                                          color: Colors
                                                              .lightBlueAccent,
                                                          onPressed: () {
                                                            if (value != "") {
                                                              Navigator.pop(
                                                                  context,
                                                                  value);
                                                            }
                                                          })
                                                    ],
                                                  );
                                                });
                                            var image = images[index];
                                            var split =
                                                _images[image].path.split('/');
                                            split.removeAt(split.length - 1);
                                            var path =
                                                split.join('/') + '/$name.png';
                                            await _images[image].copy(path);
                                            await _images[image].delete();
                                            setState(() {
                                              _images.remove(image);
                                              _images[name] = File(path);
                                              images = _images.keys.toList();
                                              _histories =
                                                  _histories.map((history) {
                                                history.pigeons[index].name =
                                                    name;
                                                return history;
                                              }).toList();
                                            });
                                          },
                                          child: const Text('Edit Name'),
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () async {
                                            var images = _images.keys.toList();
                                            var image = images[index];
                                            await _images[image].delete();
                                            setState(() {
                                              checkboxValues.remove(index);
                                              _counter--;
                                              _images.remove(image);
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ]);
                                });
                          },
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: FileImage(_images[images[index]]),
                                    fit: BoxFit.cover)),
                            child: Flex(
                              direction: Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    child: Checkbox(
                                      value: checkboxValues[index],
                                      onChanged: (bool value) => {
                                        setState(() =>
                                            {checkboxValues[index] = value})
                                      },
                                    ),
                                    margin: EdgeInsets.only(left: 0,top: 0,bottom: 65,right: 10),
                                    alignment:
                                        Alignment(checkbox_x, checkbox_y)),
                                Expanded(child: Container(
                                  child: Text(images[index],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 19)),
                                  width: 160,
                                  height: 20,
                                  margin: EdgeInsets.all(0.5),
                                  alignment: Alignment(0, 0),
                                  color: Colors.blueGrey,
                                ))
                              ],
                            ),
                            // alignment: Alignment(checkbox_x, checkbox_y)
                          ),
                        )))),
        floatingActionButton: Wrap(
          direction: Axis.vertical,
          children: [
            Container(
              margin: EdgeInsets.all(3),
              child: FloatingActionButton(
                onPressed: getImage,
                tooltip: 'Camera',
                child: Icon(Icons.camera_alt),
              ),
            ),
            Container(
              margin: EdgeInsets.all(3),
              child: FloatingActionButton(
                onPressed: _images.length > 0
                    ? saveSnapshot
                    : () {
                        showDialog(
                            context: context,
                            builder: (BuildContext b) {
                              return AlertDialog(
                                  title: Text("There are no pigeons present."));
                            });
                      },
                tooltip: 'Snapshot',
                child: Icon(Icons.save),
              ),
            )
          ],
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Settings'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('History'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HistoryPage()));
                },
              ),
            ],
          ),
        ));
  }
}
