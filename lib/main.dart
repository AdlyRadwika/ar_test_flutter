import 'package:ar_project/ar_viewer.dart';
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
  final _lamp =
      "https://github.com/KhronosGroup/glTF-Sample-Assets/raw/main/Models/AnisotropyBarnLamp/glTF-Binary/AnisotropyBarnLamp.glb";
  final _camera =
      "https://github.com/KhronosGroup/glTF-Sample-Assets/raw/main/Models/AntiqueCamera/glTF-Binary/AntiqueCamera.glb";
  final _avocado =
      "https://github.com/KhronosGroup/glTF-Sample-Assets/raw/main/Models/Avocado/glTF-Binary/Avocado.glb";
  final _box =
      "https://github.com/KhronosGroup/glTF-Sample-Assets/raw/main/Models/Box/glTF-Binary/Box.glb";

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
                          builder: (context) => ARViewer(
                            object: _lamp,
                          ),
                        )),
                    child: const Text("Lamp")),
                ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ARViewer(
                            object: _camera,
                          ),
                        )),
                    child: const Text("Camera")),
                ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ARViewer(
                            object: _avocado,
                          ),
                        )),
                    child: const Text("Avocado")),
                ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ARViewer(
                            object: _box,
                          ),
                        )),
                    child: const Text("Box")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
