import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class ARViewer extends StatefulWidget {
  const ARViewer({super.key, required this.object});
  final String object;

  @override
  State<ARViewer> createState() => _ARViewerState();
}

class _ARViewerState extends State<ARViewer> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  ARNode? webObjectNode;
  bool isAdd = false;
  double scaleValue = 0;

  @override
  void dispose() {
    arSessionManager.dispose();
    super.dispose();
  }

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    this.arSessionManager.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          customPlaneTexturePath: "assets/triangle.png",
          showWorldOrigin: true,
          showAnimatedGuide: false,
          handlePans: true,
          handleRotation: true,
        );
    this.arObjectManager.onInitialize();

    this.arObjectManager.onPanStart = _onPanStarted;
    this.arObjectManager.onPanChange = _onPanChanged;
    this.arObjectManager.onPanEnd = _onPanEnded;
    this.arObjectManager.onRotationStart = _onRotationStarted;
    this.arObjectManager.onRotationChange = _onRotationChanged;
    this.arObjectManager.onRotationEnd = _onRotationEnded;
  }

  _onPanStarted(String nodeName) {
    debugPrint("Started panning node $nodeName");
  }

  _onPanChanged(String nodeName) {
    debugPrint("Continued panning node $nodeName");
  }

  _onPanEnded(String nodeName, Matrix4 newTransform) {
    debugPrint("Ended panning node $nodeName");
    // final pannedNode = webObjectNode;

    // pannedNode?.transform = newTransform;
  }

  _onRotationStarted(String nodeName) {
    debugPrint("Started rotating node $nodeName");
  }

  _onRotationChanged(String nodeName) {
    debugPrint("Continued rotating node $nodeName");
  }

  _onRotationEnded(String nodeName, Matrix4 newTransform) {
    debugPrint("Ended rotating node $nodeName");
    // final rotatedNode = webObjectNode;

    // rotatedNode?.transform = newTransform;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;

    final rotationMatrix = Matrix4.identity()
      ..rotateY(dx * 0.01)
      ..rotateX(dy * 0.01);

    if (webObjectNode != null) {
      final newTransform = rotationMatrix * webObjectNode!.transform;
      webObjectNode!.transform = newTransform;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      scaleValue *= details.scale;
    });

    if (webObjectNode != null) {
      webObjectNode!.scale = Vector3.all(scaleValue);
    }
  }

  Future onWebObjectAtButtonPressed() async {
    setState(() {
      isAdd = !isAdd;
    });

    if (webObjectNode != null) {
      arObjectManager.removeNode(webObjectNode!);
      webObjectNode = null;
    } else {
      var newNode = ARNode(
          type: NodeType.webGLB,
          uri: widget.object,
          scale: Vector3(0.2, 0.2, 0.2));
      bool? didAddWebNode = await arObjectManager.addNode(newNode);
      webObjectNode = (didAddWebNode!) ? newNode : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onScaleUpdate: _onScaleUpdate,
        onPanUpdate: _onPanUpdate,
        child: ARView(
          onARViewCreated: onARViewCreated,
          planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onWebObjectAtButtonPressed,
        child: Icon(isAdd ? Icons.remove : Icons.add),
      ),
    );
  }
}
