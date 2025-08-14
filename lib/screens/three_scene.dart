/*import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/loaders/GLTFLoader.dart';

class ThreeScene extends StatefulWidget {
  const ThreeScene({super.key});

  @override
  State<ThreeScene> createState() => _ThreeSceneState();
}

class _ThreeSceneState extends State<ThreeScene> {
  late FlutterGlPlugin flutterGlPlugin;
  late THREE.WebGLRenderer renderer;
  late THREE.Scene scene;
  late THREE.Camera camera;

  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initRenderer();
  }

  Future<void> initRenderer() async {
    flutterGlPlugin = FlutterGlPlugin();
    await flutterGlPlugin.initialize(options: {
      "antialias": true,
      "alpha": true,
      "width": 300,
      "height": 300,
    });

    await flutterGlPlugin.prepareContext();

    renderer = THREE.WebGLRenderer({
      "canvas": flutterGlPlugin.element,
      "width": 300,
      "height": 300,
      "antialias": true,
      "alpha": true,
    });

    scene = THREE.Scene();
    camera = THREE.PerspectiveCamera(75, 1, 0.1, 1000);
    camera.position.z = 5;

    await loadGLBModel();

    renderer.render(scene, camera);
    setState(() {}); // 觸發 widget 重建以顯示 canvas
  }

  Future<void> loadGLBModel() async {
    final loader = GLTFLoader();
    loader.load('assets/models/your_model.glb', (gltf) {
      final model = gltf.scene;
      scene.add(model); // ✅ 加入場景
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3D 渲染場景")),
      body: Center(
        child: flutterGlPlugin.isInitialized
            ? SizedBox(
                key: _canvasKey,
                width: 300,
                height: 300,
                child: Texture(textureId: flutterGlPlugin.textureId!),
              )
            : const Text("🔧 初始化中..."),
      ),
    );
  }

  @override
  void dispose() {
    flutterGlPlugin.dispose();
    super.dispose();
  }
}*/