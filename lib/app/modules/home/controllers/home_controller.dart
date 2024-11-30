import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:get/get.dart';
import 'package:external_path/external_path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart' as path;

class HomeController extends GetxController {
  CameraController? _cameraController; // Ubah menjadi nullable
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  bool isRecording = false;

  CameraController? get cameraController => _cameraController;

  @override
  void onInit() async {
    super.onInit();
    await initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar('Error', 'No cameras found!');
        return;
      }

      // Inisialisasi kamera hanya jika belum diinisialisasi
      if (_cameraController == null) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        update();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize camera: $e');
    }
  }

  Future<void> startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return; // Jika kamera belum diinisialisasi, jangan lanjutkan
    }
    final directory = await getTemporaryDirectory();
    final filePath = path.join(directory.path, 'video.mp4');
    await _cameraController!.startVideoRecording();
    isRecording = true;
    update();
  }

  Future<void> stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo) {
      return;
    }

    final file = await _cameraController!.stopVideoRecording();
    isRecording = false;
    update();

    final compressedPath = await compressVideo(file.path);
    await saveToExternalStorage(compressedPath);
  }

  Future<String> compressVideo(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final compressedPath = path.join(directory.path, 'compressed_video.mp4');

    await _flutterFFmpeg.execute(
      '-i $filePath -vcodec h264 -crf 28 $compressedPath',
    );

    return compressedPath;
  }

 Future<void> saveToExternalStorage(String filePath) async {
  try {
    final directory = await getExternalStorageDirectory();
    final videoDirectory = Directory(path.join(directory!.path, 'Video'));

    if (!await videoDirectory.exists()) {
      await videoDirectory.create(recursive: true);
    }

    final fileName = path.basename(filePath);
    final newFilePath = path.join(videoDirectory.path, fileName);

    await File(filePath).copy(newFilePath);
    Get.snackbar('Success', 'Video saved to external storage!');
  } catch (e) {
    Get.snackbar('Error', 'Failed to save video: $e');
  }
}

  @override
  void onClose() {
    _cameraController?.dispose();
    super.onClose();
  }
}
