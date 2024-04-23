import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
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
  ARSessionManager? _arSessionManager;
  late ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;
  ARNode? _webObjectNode;

  List<ARAnchor> _anchors = [];
  bool _isAdd = true;
  late Quaternion _cumulativeRotation;

  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;

    _arSessionManager?.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: false,
      showAnimatedGuide: false,
    );
    _arObjectManager?.onInitialize();

    _addARObjectInFrontOfCamera();
  }

  void _addARObjectInFrontOfCamera() async {
    final cameraPose = await _arSessionManager?.getCameraPose();
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

      _arObjectManager?.addNode(newNode);
      _webObjectNode = newNode;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_webObjectNode != null) {
      final touchDelta = details.delta;

      final rotationAmountX = touchDelta.dy * 0.01;
      final rotationAmountY = touchDelta.dx * 0.01;

      final rotationX = Quaternion.axisAngle(Vector3(1, 0, 0), rotationAmountX);
      final rotationY = Quaternion.axisAngle(Vector3(0, 1, 0), rotationAmountY);

      final totalRotation = rotationX * rotationY;

      _cumulativeRotation *= totalRotation;

      _webObjectNode!.rotationFromQuaternion = _cumulativeRotation;
    }
  }

  Future<void> _onWebObjectAtButtonPressed() async {
    setState(() {
      _isAdd = !_isAdd;
    });

    if (_webObjectNode != null) {
      _arObjectManager?.removeNode(_webObjectNode!);
      _webObjectNode = null;
    } else {
      _addARObjectInFrontOfCamera();
    }
  }

  Future<void> _onRemoveEverything() async {
    setState(() {
      for (var anchor in _anchors) {
        _arAnchorManager?.removeAnchor(anchor);
      }
      _anchors = [];
      if (_webObjectNode != null) {
        _arObjectManager?.removeNode(_webObjectNode!);
        _webObjectNode = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _cumulativeRotation = Quaternion.identity();
  }

  @override
  void dispose() {
    _arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        child: ARView(
          onARViewCreated: _onARViewCreated,
          planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _onRemoveEverything,
            heroTag: null,
            child: const Icon(Icons.delete),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: null,
            onPressed: _onWebObjectAtButtonPressed,
            child: Icon(_isAdd ? Icons.visibility_off : Icons.visibility),
          ),
        ],
      ),
    );
  }
}
