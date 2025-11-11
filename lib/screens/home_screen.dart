import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(imageFile: File(picked.path)),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2DF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE17826),
        title: const Text(
          'CaloScan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Ambil atau Unggah Gambar Makanan",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE17826)),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Ambil Gambar"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE17826),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(220, 55)),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo),
              label: const Text("Upload Foto"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE17826),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(220, 55)),
            ),
          ],
        ),
      ),
    );
  }
}
