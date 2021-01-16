import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      title: 'Flutter Demo',
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
        title: 'Flutter Demo Home Page',
        storage: CounterStorage(),
      ),
    );
  }
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}

class MyHomePage extends StatefulWidget {
  final CounterStorage storage;

  MyHomePage({Key key, this.title, @required this.storage}) : super(key: key);

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
  File _image;
  List<File> _images = [];
  List<String> text = [];
  List<int> bytes = [];
  String _path = "";
  Map<int, bool> checkboxValues = {};

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    var value = await readData();

    final path = await _localPath;

    var imageDirectory = Directory('$path/images');

    if (!await imageDirectory.exists()) {
      await imageDirectory.create();
    }

    List<File> array = [];
    for (var i = 0; i < value; i++) {
      array.add(await _localImage('$i.png'));
      setState(() {
        checkboxValues[i] = false;
      });
    }
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

  Future<int> readData() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeData(int data) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString('$data');
  }

  Future<File> getImage() async {
    // await writeData(_counter);
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    bytes = await image.readAsBytes();
    await writeImage(bytes, '$_counter.png');
    await writeData(_counter);
    // writeImage("hank ssss");
    var path = await _localPath;
    setState(() {
      _image = image;
      _images.add(_image);
      _path = path;
      _counter++;
    });
    return writeData(_counter);
  }

  // void addText() async {
  //   // var ss = await writeImage("hank ssss");
  //   // var path = p.basename(ss.path);
  //   setState(() {
  //     _path = path;
  //     // text.add("hello guys");
  //   });
  // }
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

      //  Container(
      //   height: 100.0,
      //   color: Colors.black,
      //   alignment: Alignment.center,
      //   ),
      //  Container(
      //   height: 100.0,
      //   color: Colors.blue,
      //   alignment: Alignment.center,
      //   ),
      //  Container(
      //   height: 100.0,
      //   color: Colors.red,
      //   alignment: Alignment.center,
      //   ),
      //  Container(
      //   height: 100.0,
      //   color: Colors.green,
      //   alignment: Alignment.center,
      //   ),
      //  Container(
      //   height: 100.0,
      //   color: Colors.grey,
      //   alignment: Alignment.center,
      //   ),
      //  Container(
      //   height: 100.0,
      //   color: Colors.orange,
      //   alignment: Alignment.center,
      //   ),
      //   Container(
      //   height: 100.0,
      //   color: Colors.orange,
      //   alignment: Alignment.center,
      //   ),
      //   Container(
      //   height: 100.0,
      //   color: Colors.orange,
      //   alignment: Alignment.center,
      //   ),
      //   Container(
      //   height: 100.0,
      //   color: Colors.orange,
      //   alignment: Alignment.center,
      //   ),
      // )
      // ],
      // )
      //     Row(

      //       child: CustomScrollView(
      //   slivers: <Widget>[
      //   SliverGrid(
      //       gridDelegate:
      //       SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      //     delegate: SliverChildListDelegate([
      //       // _path == null ? Text("PATH UNKNOWN") : Text('$_counter' + _path),
      //     if (_images != null)
      //     for (var image in _images)
      // Stack(
      //     children: checkboxValues.keys
      //         .map(
      //           (keys) => new Container(
      //           width: 160,
      //           height: 160,
      //           decoration: BoxDecoration(
      //             image: DecorationImage(
      //                 image: FileImage(image),
      //                 fit: BoxFit.cover),
      //           ),
      //           child: image == null
      //               ? Text("no image selected")
      //               : Container(
      //             child: Checkbox(
      //               value: checkboxValues[keys],
      //               onChanged: (bool value) {
      //                 setState(() {
      //                   checkboxValues[keys] = value;
      //                 });
      //               },
      //             ),
      //             alignment:
      //             Alignment(checkbox_x, checkbox_y),
      //           )),
      //     )
      //         .toList())

      //       // Column is also a layout widget. It takes a list of children and
      //       // arranges them vertically. By default, it sizes itself to fit its
      //       // children horizontally, and tries to be as tall as its parent.
      //       //
      //       // Invoke "debug painting" (press "p" in the console, choose the
      //       // "Toggle Debug Paint" action from the Flutter Inspector in Android
      //       // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
      //       // to see the wireframe for each widget.
      //       //
      //       // Column has various properties to control how it sizes itself and
      //       // how it positions its children. Here we use mainAxisAlignment to
      //       // center the children vertically; the main axis here is the vertical
      //       // axis because Columns are vertical (the cross axis would be
      //       // horizontal).
      //       mainAxisAlignment: MainAxisAlignment.start,
      //       children: <Widget>[
      //         Wrap(
      //           direction: Axis.vertical,
      //           children: <Widget>[
      //             if (text != null)
      //               for (var image in text)
      //                 Container(
      //                   child: image == null
      //                       ? Text("no image selected")
      //                       : Text(image)// Image.file(image),
      //                 ),
      //             //Container(child: _image==null? Text("no image selected"):Image.file(_image),)
      //           ],
      //         ),
      //     //     // Row(children: <Widget>[
      //     //     // Container(child: _image==null? Text("no image selected"):Image.file(_image),)
      //     //     // ],),
      //     //     // Row(children: <Widget>[
      //     //     // Container(child: _image==null? Text("no image selected"):Image.file(_image),)
      //     //     // ],),
      //     //     // Row(children: <Widget>[
      //     //     // Container(child: _image==null? Text("no image selected"):Image.file(_image),)
      //     //     // ],),
      //     //     // Text(
      //     //     //   'You have pushed the button this many times:',
      //     //     //   style: TextStyle(fontSize: initialSize + _counter),
      //     //     // ),
      //     //     // Text(
      //     //     //   '$_counter',
      //     //     //   style: Theme.of(context).textTheme.display1,
      //     //     // ),
      //     //     // Center(child: _image==null? Text("no image selected"):Image.file(_image)),
      //     //   ],
      //     // ),
      //     // ListView.builder(
      //     //   shrinkWrap: true,
      //     //   itemBuilder: (context, position) {
      //     //     return Wrap(
      //     //       direction: Axis.vertical,
      //     //       children: <Widget>[
      //     //         if (text != null)
      //     //           for (var image in text)
      //     //             Container(
      //     //               constraints: BoxConstraints(minHeight: 100,minWidth: 100,maxHeight: 160,maxWidth: 160),
      //     //               child: image == null
      //     //                   ? Text("no image selected")
      //     //                   : Text(image),
      //     //             ),
      //     //       ],
      //     //     );
      //     //   },
      //     // )

      // ),
      // ],

      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Camera',
        child: Icon(Icons.camera_alt),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
      drawer: Drawer(),
    );
  }
}
