import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ffi/ffi.dart';
import 'package:panorama/panorama.dart';
import 'package:camera/camera.dart';
import 'package:photo_manager/photo_manager.dart';

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

  double _aspectRatio = 1.0;

  double _lon = 0;
  double _lat = 0;
  double _tilt = 0;

  void onViewChanged(longitude, latitude, tilt) {
    _lon = longitude;
    _lat = latitude;
    _tilt = tilt;
  }

  final List<Hotspot> picList = [];
  final List<XFile> picFiles = [];

  @override
  void initState() {
    super.initState();
    initPhotoLibrary();
    initCamera();
  }

  void initPhotoLibrary() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
  }

  //
  // カメラを準備
  //
  initCamera() async {
    _cameras = await availableCameras();

    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.veryHigh);
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
  final String _zlibVersion = 'Unknown';

  void _shutter() {
    setState(() {
      debugPrint("$_lon $_lat $_tilt");
      // 静止画を撮影
      _controller.takePicture().then((value) {
        picFiles.add(value);
        picList.add(Hotspot(
            longitude: _lon,
            latitude: _lat,
            width: 400,
            height: 400,
            widget: Image.file(
              //   width: MediaQuery.of(context).size.width - 80,
              File(value.path),
            )));
      });
    });
  }

  final List<Hotspot> _hotspots = [];

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < 21; i++) {
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
    for (int i = 0; i < 21; i++) {
      _hotspots.add(
        Hotspot(
            latitude: -20,
            longitude: i * 17 - 170,
            width: 50,
            height: 50,
            widget: CircleAvatar(
              backgroundColor: Colors.red,
              child: Container(),
            )),
      );
    }
    for (int i = 0; i < 11; i++) {
      _hotspots.add(
        Hotspot(
            latitude: -40,
            longitude: i * 34 - 170,
            width: 50,
            height: 50,
            widget: CircleAvatar(
              backgroundColor: Colors.red,
              child: Container(),
            )),
      );
    }
    for (int i = 0; i < 11; i++) {
      _hotspots.add(
        Hotspot(
            latitude: -60,
            longitude: i * 34 - 170,
            width: 50,
            height: 50,
            widget: CircleAvatar(
              backgroundColor: Colors.red,
              child: Container(),
            )),
      );
    }
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Panorama(
              animSpeed: 0.1,
              //   onViewChanged: onViewChanged,
              hotspots: picList,
              sensorControl: SensorControl.Orientation,
              //    child: Image.asset(
              //     'assets/panorama.jpeg',
              //    fit: BoxFit.cover,
              // ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: CameraPreview(_controller),
              ),
            ),
            Panorama(
              hotspots: _hotspots,
              onViewChanged: onViewChanged,
              animSpeed: 0.1,
              sensorControl: SensorControl.Orientation,
            ),
            SafeArea(
              child: IconButton(
                onPressed: () {
                  // picList2の写真をiPhoneの写真に保存する
                  for (var element in picFiles) {
                    PhotoManager.editor
                        .saveImageWithPath(element.path, title: "");
                  }
                },
                icon: const Icon(Icons.check),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _shutter,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
