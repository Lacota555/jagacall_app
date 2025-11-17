import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact_model.dart';

class ContactApiService {
  static const String baseUrl = "http://192.168.1.10:8000/api";

  static Future<Map<String, dynamic>> uploadContacts(List<ContactModel> contacts) async {
    try {
      
      final response = await http.post(
        Uri.parse("$baseUrl/contacts/sync"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "device_id": "myphone_001",
          "contacts": contacts.map((c) => c.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
          "body": response.body,
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
