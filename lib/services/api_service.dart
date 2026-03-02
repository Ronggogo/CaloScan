import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>?> predictWeight({
    required int classId,
    required double ratio,
  }) async {
    final url = Uri.parse("http://192.168.1.46:8000/predict");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"class_id": classId, "ratio": ratio}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      print("Error: ${response.body}");
      return null;
    }
  }
}
