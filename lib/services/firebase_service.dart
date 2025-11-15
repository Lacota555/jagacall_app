// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/contact_model.dart';
import '../utils/device_info.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      await Firebase.initializeApp();
      _initialized = true;
      print('✅ Firebase initialized successfully');
    }
  }

  static Future<Map<String, dynamic>> uploadContacts(List<ContactModel> contacts) async {
    try {
      final deviceId = await DeviceInfo.getDeviceId();
      final timestamp = DateTime.now();
      
      print('📤 Uploading ${contacts.length} contacts to Firebase...');
      
      final batch = _firestore.batch();
      int successCount = 0;
      
      for (var contact in contacts) {
        final docRef = _firestore.collection('contacts').doc();
        batch.set(docRef, {
          'name': contact.name,
          'phone_number': contact.phoneNumber,
          'device_id': deviceId,
          'uploaded_at': timestamp,
          'processed': false,
          'processed_at': null,
        });
        successCount++;
      }
      
      await batch.commit();
      
      print('✅ Successfully uploaded $successCount contacts to Firebase');
      
      return {
        'success': true,
        'message': 'Uploaded $successCount contacts to cloud',
        'uploaded_count': successCount,
        'device_id': deviceId,
        'timestamp': timestamp.toIso8601String(),
      };
      
    } catch (e) {
      print('❌ Error uploading to Firebase: $e');
      return {
        'success': false,
        'message': 'Upload failed: $e',
        'uploaded_count': 0,
      };
    }
  }
}