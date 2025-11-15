import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact_model.dart';
import '../utils/device_info.dart';

class ApiService {
  static const String baseUrl = 'http://10.210.76.36:8000/api';

  static Future<Map<String, dynamic>> sendContacts(List<ContactModel> contacts) async {
    try {
      final deviceId = await DeviceInfo.getDeviceId();
      
      print('📤 Preparing to send ${contacts.length} contacts...');
      print('📱 Device ID: $deviceId');
      print('🌐 URL: $baseUrl/contacts');
      print('🔧 Method: POST');
      
      // Prepare data
      final requestData = {
        'contacts': contacts.map((contact) => contact.toJson()).toList(),
        'device_id': deviceId,
      };
      
      print('📦 Request Data: ${jsonEncode(requestData)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/contacts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Headers: ${response.headers}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Contacts sent successfully');
        final data = jsonDecode(response.body);
        return {
          'success': true, 
          'message': data['message'] ?? 'Contacts sent successfully',
          'saved_count': data['saved_count']
        };
      } else {
        print('❌ Failed to send contacts: ${response.statusCode}');
        return {
          'success': false, 
          'message': 'HTTP ${response.statusCode}: ${response.body}',
          'error': response.body
        };
      }
    } catch (e) {
      print('❌ Error sending contacts: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🔗 Testing GET connection to: $baseUrl/test');
      
      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: {'Accept': 'application/json'},
      );

      print('📡 Test Response Status: ${response.statusCode}');
      print('📡 Test Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': '✅ ${data['message']}'
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': '❌ Server returned: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('❌ Connection test failed: $e');
      return {
        'success': false,
        'message': '❌ Cannot reach server: $e'
      };
    }
  }

  static Future<List<String>> getBlockedPrefixes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/blocked-prefixes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item.toString()).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting blocked prefixes: $e');
      return [];
    }
  }
}