import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraApp(camera: cameras.first),
    ),
  );
}

class CameraApp extends StatefulWidget {
  final CameraDescription camera;

  const CameraApp({super.key, required this.camera});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController camera;
  XFile? foto;

  @override
  void initState() {
    super.initState();

    camera = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    camera.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }

  Future<void> tirarFoto() async {
    foto = await camera.takePicture();
    setState(() {});
  }

  Future<void> abrirCamera() async {
    foto = null;

    await camera.initialize();

    setState(() {});
  }

  Future<void> galeria() async {
    foto = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!camera.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Câmera')),

      body: Column(
        children: [
          Expanded(
            child: foto == null
                ? CameraPreview(camera)
                : FutureBuilder(
                    future: foto!.readAsBytes(),
                    builder: (_, imagem) {
                      if (!imagem.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Image.memory(imagem.data!, fit: BoxFit.contain);
                    },
                  ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CÂMERA / NOVA FOTO
              FloatingActionButton(
                onPressed: foto == null ? tirarFoto : abrirCamera,
                child: Icon(foto == null ? Icons.camera_alt : Icons.camera),
              ),

              const SizedBox(width: 30),

              // GALERIA
              FloatingActionButton(
                onPressed: galeria,
                child: const Icon(Icons.photo),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
