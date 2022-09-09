import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:ffi/ffi.dart';

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
  String _zlibVersion = 'Unknown';

  void _incrementCounter() {
    setState(() {
      _zlibVersion = zlibVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              _zlibVersion,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
