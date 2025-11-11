import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelService {
  Interpreter? _interpreter;
  List<Map<String, dynamic>> detections = [];

  // memuat model
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/model/best_float32.tflite',
    );
    print("Model YOLOv11 loaded");
  }

  Future<Map<String, dynamic>> detectObjects(File imageFile) async {
    if (_interpreter == null) {
      print("Model belum dimuat. Jalankan loadModel() dulu.");
      return {"detections": [], "originalWidth": 0, "originalHeight": 0};
    }

    // decode gambar
    final bytes = await imageFile.readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      print("Gagal decode gambar.");
      return {"detections": [], "originalWidth": 0, "originalHeight": 0};
    }

    // resize
    final ResizeResult resizedResult = resizeWithPadding(decoded, 640, 640);
    final img.Image resized = resizedResult.image;
    final double scale = resizedResult.scale;
    final int padX = resizedResult.padX;
    final int padY = resizedResult.padY;

    // normalisasi input ke [0,1]
    final Float32List inputList = Float32List(1 * 640 * 640 * 3);
    int index = 0;
    for (int y = 0; y < 640; y++) {
      for (int x = 0; x < 640; x++) {
        final pixel = resized.getPixel(x, y);
        inputList[index++] = pixel.r / 255.0;
        inputList[index++] = pixel.g / 255.0;
        inputList[index++] = pixel.b / 255.0;
      }
    }

    // bentuk tensor input dan output
    var input = inputList.reshape([1, 640, 640, 3]);
    var output = List.generate(
      1,
      (_) => List.generate(300, (_) => List.filled(6, 0.0)),
    );

    // jalankan inferensi
    _interpreter!.run(input, output);
    final outputData = output[0]; // [300, 6]

    const double confThreshold = 0.4;
    List<Map<String, dynamic>> detections = [];

    for (var i = 0; i < outputData.length; i++) {
      final det = outputData[i];

      double x1 = det[0];
      double y1 = det[1];
      double x2 = det[2];
      double y2 = det[3];
      double conf = det[4];
      int classId = det[5].toInt();

      if (conf < confThreshold) continue;

      //  Koreksi arah scaling
      x1 = ((x1 * 640 - padX) / scale).clamp(0, decoded.width.toDouble());
      y1 = ((y1 * 640 - padY) / scale).clamp(0, decoded.height.toDouble());
      x2 = ((x2 * 640 - padX) / scale).clamp(0, decoded.width.toDouble());
      y2 = ((y2 * 640 - padY) / scale).clamp(0, decoded.height.toDouble());


      detections.add({
        "label": _getLabel(classId),
        "conf": conf,
        "box": [x1, y1, x2, y2],
      });
    }

    print("${detections.length} objek terdeteksi");
    if (detections.isEmpty) print(" Tidak ada objek di atas threshold.");

    this.detections = detections;
    return {
      "detections": detections,
      "originalWidth": decoded.width,
      "originalHeight": decoded.height,
    };
  }

  String _getLabel(int index) {
    const labels = [
      'AyamBakar',
      'AyamBumbu',
      'Dendeng',
      'LeleGoreng',
      'Nasi',
      'NilaGoreng',
      'TahuGoreng',
      'TelurRebus',
      'TempeGoreng',
      'piring',
      'sendok',
    ];
    if (index < 0 || index >= labels.length) return "Unknown";
    return labels[index];
  }

  // resize + padding
  ResizeResult resizeWithPadding(
    img.Image src,
    int targetWidth,
    int targetHeight,
  ) {
    final double ratioX = targetWidth / src.width;
    final double ratioY = targetHeight / src.height;
    final double scale = ratioX < ratioY ? ratioX : ratioY;

    final int newWidth = (src.width * scale).round();
    final int newHeight = (src.height * scale).round();

    final img.Image resized = img.copyResize(
      src,
      width: newWidth,
      height: newHeight,
    );

    final int padX = ((targetWidth - newWidth) / 2).round();
    final int padY = ((targetHeight - newHeight) / 2).round();

    final img.Image padded = img.Image(
      width: targetWidth,
      height: targetHeight,
    );
    img.fill(padded, color: img.ColorRgb8(0, 0, 0));
    img.compositeImage(padded, resized, dstX: padX, dstY: padY);

    return ResizeResult(padded, scale, padX, padY);
  }
}

class ResizeResult {
  final img.Image image;
  final double scale;
  final int padX;
  final int padY;

  ResizeResult(this.image, this.scale, this.padX, this.padY);
}
