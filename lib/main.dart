import 'package:ar_project/example_four.dart';
import 'package:ar_project/example_one.dart';
import 'package:ar_project/example_three.dart';
import 'package:ar_project/example_two.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Future<void> _getPermission() async {
    await Permission.camera.request();
  }

  @override
  void initState() {
    super.initState();

    _getPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExampleOne(),
                        )),
                    child: const Text("Contoh Pertama")),
                ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExampleTwo(),
                        )),
                    child: const Text("Contoh Kedua")),
                ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExampleThree(),
                        )),
                    child: const Text("Contoh Ketiga")),
                ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExampleFour(),
                        )),
                    child: const Text("Contoh Keempat")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
