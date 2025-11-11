import 'dart:io';
import 'package:flutter/material.dart';
import '../services/model_service.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  const ResultScreen({super.key, required this.imageFile});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ModelService _mlService = ModelService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _detections = [];
  double _imageWidth = 1;
  double _imageHeight = 1;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    await _mlService.loadModel();
    final result = await _mlService.detectObjects(widget.imageFile);

    setState(() {
      _detections = result["detections"];
      _imageWidth = (result["originalWidth"] ?? 1).toDouble();
      _imageHeight = (result["originalHeight"] ?? 1).toDouble();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2DF),
      appBar: AppBar(
        title: const Text('Hasil Deteksi'),
        backgroundColor: const Color(0xFFE17826),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE17826)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Gambar dengan deteksi di atasnya
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxDisplayWidth = constraints.maxWidth;
                      final double displayHeight =
                          maxDisplayWidth *
                          (_imageHeight / _imageWidth); // jaga rasio

                      return Center(
                        child: SizedBox(
                          width: maxDisplayWidth,
                          height: displayHeight,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                widget.imageFile,
                                fit: BoxFit.contain,
                                width: maxDisplayWidth,
                              ),

                              // Gambar bounding box disesuaikan skala
                              ..._detections.map((det) {
                                final box = det["box"];
                                final left = box[0];
                                final top = box[1];
                                final right = box[2];
                                final bottom = box[3];
                                final label = det["label"];
                                final conf = det["conf"];

                             
                                return Positioned(
                                  left: left / _imageWidth * maxDisplayWidth,
                                  top: top / _imageHeight * displayHeight,
                                  width:
                                      (right - left) /
                                      _imageWidth *
                                      maxDisplayWidth,
                                  height:
                                      (bottom - top) /
                                      _imageHeight *
                                      displayHeight,

                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.orangeAccent,
                                        width: 3,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        color: Colors.orangeAccent.withOpacity(
                                          0.8,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        child: Text(
                                          "$label ${(conf * 100).toStringAsFixed(1)}%",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Detail Deteksi",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE17826),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Daftar hasil deteksi
                  ..._detections.map(
                    (d) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "${d["label"]} - "
                        "Confidence: ${(d["conf"] * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
