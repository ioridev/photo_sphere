import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_share/flutter_share.dart';

import 'package:panorama/panorama.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
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

  final double _aspectRatio = 1.0;

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
    for (int i = 0; i < 21; i++) {
      _hotspots.add(
        Hotspot(
            latitude: 0,
            longitude: i * 17 - 170,
            width: 50,
            height: 50,
            widget: CircleAvatar(
              backgroundColor: Colors.white,
              child: Container(),
            )),
      );
    }
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
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Panorama(
              animSpeed: 0.1,
              hotspots: picList,
              sensorControl: SensorControl.Orientation,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: CameraPreview(_controller),
              ),
            ),
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1.0, color: Colors.white),
                    left: BorderSide(width: 1.0, color: Colors.white),
                    right: BorderSide(width: 1.0, color: Colors.white),
                    bottom: BorderSide(width: 1.0, color: Colors.white),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                width: 60,
                height: 60,
              ),
            ),
            Panorama(
              hotspots: _hotspots,
              onViewChanged: onViewChanged,
              animSpeed: 0.1,
              sensorControl: SensorControl.Orientation,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("${picFiles.length}枚"),
                        const Text('1080p'),
                        InkWell(
                            onTap: (() {
                              setState(() {
                                picFiles.clear();
                                picList.clear();
                              });
                            }),
                            child: const Text('リセット')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () async {
// ロード表示
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );

              // picListの写真をiPhoneの写真に保存する
              for (var element in picFiles) {
                await PhotoManager.editor
                    .saveImageWithPath(element.path, title: "");
              }
              // picList<Xfile>をList<File>に変換
              List<File> files = [];
              for (var element in picFiles) {
                files.add(File(element.path));
              }
              Directory? appDocDirectory =
                  await getApplicationDocumentsDirectory();

              final sourceDir = Directory(picFiles.first.path);
              debugPrint("${sourceDir.path}  ${sourceDir.parent.path}");
              // Zip the FILES files into a folder.

              String zipPath = appDocDirectory.path +
                  '/' +
                  DateTime.now().toString() +
                  ".zip";

              await ZipFile.createFromFiles(
                files: files,
                sourceDir: sourceDir.parent,
                zipFile: File(zipPath),
              );

              // zipFileを共有する
              await FlutterShare.shareFile(
                title: 'test',
                text: 'test',
                filePath: zipPath,
              );

              //    ロード表示を消す
              Navigator.pop(context);
            },
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            child: const Icon(Icons.check),
          ),
          Container(
            // 枠線
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.white),
                left: BorderSide(width: 1.0, color: Colors.white),
                right: BorderSide(width: 1.0, color: Colors.white),
                bottom: BorderSide(width: 1.0, color: Colors.white),
              ),
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            width: 80,
            height: 80,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: FloatingActionButton(
                onPressed: _shutter,
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                picList.removeLast();
                picFiles.removeLast();
              });
            },
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            child: const Icon(CupertinoIcons.arrow_uturn_left),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
