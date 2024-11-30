import 'package:camera/camera.dart';
import 'package:camera_compresed/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Recorder'),
      ),
      body: GetBuilder<HomeController>(
        builder: (controller) {
          // Pastikan kamera sudah diinisialisasi
          if (controller.cameraController == null || !controller.cameraController!.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Membungkus CameraPreview dengan Expanded agar mengisi ruang
              Expanded(
                child: AspectRatio(
                  aspectRatio: controller.cameraController!.value.aspectRatio,
                  child: CameraPreview(controller.cameraController!), // Pastikan ini non-null
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.isRecording
                    ? controller.stopRecording
                    : controller.startRecording,
                child: Text(controller.isRecording ? 'Stop Recording' : 'Start Recording'),
              ),
            ],
          );
        },
      ),
    );
  }
}
