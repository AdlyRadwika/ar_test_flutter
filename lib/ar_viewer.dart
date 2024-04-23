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

    _addARObjectInFrontOfCamera();
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

  void _addARObjectInFrontOfCamera() async {
    final cameraPose = await arSessionManager.getCameraPose();
    if (cameraPose != null) {
      final translation = cameraPose.getTranslation();
      final rotation = cameraPose.getRotation();

      final newPosition = translation + rotation * Vector3(0, 0, -1);

      final newTransform = Matrix4.compose(
        newPosition,
        Quaternion.identity(),
        Vector3.all(0.2),
      );

      final newNode = ARNode(
        type: NodeType.webGLB,
        uri: widget.object,
        transformation: newTransform,
      );

      arObjectManager.addNode(newNode);
      webObjectNode = newNode;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (webObjectNode != null) {
      // Calculate the rotation based on the pan delta
      final dx = details.delta.dx;
      final dy = details.delta.dy;

      // Calculate the rotation axis (the camera's up vector)
      final upVector = Vector3(0, 1, 0);

      // Calculate the rotation angle based on pan deltas
      final rotationAngleX = dx * 0.01;
      final rotationAngleY = dy * 0.01;

      // Convert current rotation to a quaternion
      final currentRotation = webObjectNode!.rotation;
      final currentQuaternion = Quaternion.fromRotation(currentRotation);

      // Apply rotation around the camera's up vector
      final rotationX = Quaternion.axisAngle(upVector, rotationAngleX);
      final rotationY = Quaternion.axisAngle(upVector, rotationAngleY);

      // Combine rotations
      final newRotation = rotationX * rotationY * currentQuaternion;

      // Set the new rotation back to the object
      webObjectNode!.rotationFromQuaternion = newRotation;
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
      _addARObjectInFrontOfCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
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
