import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:ffi/ffi.dart';
import 'package:panorama/panorama.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const MyApp());
}

String zlibVersion() {
  final z = DynamicLibrary.open('libz.so');
  final zlibVersionPointer =
      z.lookup<NativeFunction<Pointer<Utf8> Function()>>('zlibVersion');
  final zlibVersion = zlibVersionPointer.asFunction<Pointer<Utf8> Function()>();
  final result = zlibVersion().toDartString();
  return result;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //カメラリスト
  late List<CameraDescription> _cameras;

  //カメラコントローラ
  late CameraController _controller;

  //
  double _aspectRatio = 1.0;

  @override
  void initState() {
    super.initState();

    initCamera();
  }

  //
  // カメラを準備
  //
  initCamera() async {
    _cameras = await availableCameras();

    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.high);
      _controller.initialize().then((_) {
        if (!mounted) {
          return;
        }

        //カメラ接続時にbuildするようsetStateを呼び出し
        setState(() {});
      });
    }
  }

  //
  // カメラの表示比率を変更する
  //
  _toggle() {
    setState(() {
      _aspectRatio = _aspectRatio == 1.0 ? 0.7 : 1.0;
    });
  }

  ///
  String _zlibVersion = 'Unknown';

  void _incrementCounter() {
    setState(() {
      _zlibVersion = zlibVersion();
    });
  }

  final List<Hotspot> _hotspots = [];

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < 20; i++) {
      _hotspots.add(
        Hotspot(
            latitude: 0,
            longitude: i * 17 - 170,
            width: 50,
            height: 50,
            widget: CircleAvatar(
              backgroundColor: Colors.red,
              child: Container(),
            )),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Scaffold(
        body: Center(
          child: Stack(
            children: [
              Panorama(
                animSpeed: 0.1,
                sensorControl: SensorControl.Orientation,
                child: Image.asset(
                  'assets/panorama.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(100),
                child: CameraPreview(_controller),
              ),
              Panorama(
                hotspots: _hotspots,
                animSpeed: 0.1,
                sensorControl: SensorControl.Orientation,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
