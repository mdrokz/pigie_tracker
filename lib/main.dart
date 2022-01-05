import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
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

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double initialSize = 20;
  bool hasInit;
  PickedFile _image;
  List<File> _images = [];
  List<String> text = [];
  String _path = "";
  Map<int, bool> checkboxValues = {};
  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    final path = await _localPath;

    final imageDirectory = Directory('$path/images');

    final files = await imageDirectory.list().toList();

    final value = files.length;

    if (!await imageDirectory.exists()) {
      await imageDirectory.create();
    }

    // var array = Iterable<int>.generate(value).toList().map((idx) {
    //   final val = files[idx];
    //
    //   return File(val.path);
    // });
    var array = files.asMap().entries.map((entry) {
      final index = entry.key;
      final file = entry.value;

      setState(() {
        checkboxValues[index] = false;
      });

      return File(file.path);
    }).toList();

    setState(() {
      _counter = value;
      _images = array;
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<File> _localImage(String fileName) async {
    final path = await _localPath;
    return File('$path/images/$fileName');
  }

  Future<File> writeImage(List<int> bytes, String fileName) async {
    final file = await _localImage(fileName);

    // write the file
    return file.writeAsBytes(bytes);
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
    var path = await _localPath;
    setState(() {
      _image = image;
      _images.add(File(image.path));
      _path = path;
      checkboxValues[_counter] = false;
      _counter++;
    });
  }

  final checkbox_x = -1.0993 - 0.09 - 0.01;
  final checkbox_y = -1.0993 - 0.09 - 0.01;

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
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: checkboxValues.keys.length,
              itemBuilder: (context, index) => Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(_images[index]), fit: BoxFit.cover)),
                  child: Checkbox(
                    value: checkboxValues[index],
                    onChanged: (bool value) => {
                      setState(() => {checkboxValues[index] = value})
                    },
                  ),
                  alignment: Alignment(checkbox_x, checkbox_y)),
            ))),
        floatingActionButton: Wrap(
          direction: Axis.vertical,
          children: [
            Container(
              margin: EdgeInsets.all(3),
              child:  FloatingActionButton(
                onPressed: getImage,
                tooltip: 'Camera',
                child: Icon(Icons.camera_alt),
              ),
            ),
            Container(
              margin: EdgeInsets.all(3),
              child: FloatingActionButton(
                onPressed: getImage,
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
                onTap: () async {},
              ),
            ],
          ),
        ));
  }
}
