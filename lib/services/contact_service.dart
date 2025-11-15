import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/contact_model.dart';
import './firebase_service.dart';

class ContactService {
  static List<ContactModel> manualContacts = [];

  static Future<List<ContactModel>> getRealContacts() async {
    try {
      print('📞 Requesting contact permission...');
      
      // Request permission
      if (!await FlutterContacts.requestPermission()) {
        print('❌ Contact permission denied');
        return [];
      }

      print('✅ Permission granted, fetching contacts...');
      
      // Get all contacts
      List<Contact> contacts;
      try {
        contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
      } catch (e) {
        print('❌ Error getting contacts: $e');
        return [];
      }
      
      print('📋 Found ${contacts.length} raw contacts');
      
      // Process contacts
      List<ContactModel> validContacts = [];
      
      for (var contact in contacts) {
        if (contact.phones.isNotEmpty) {
          // Take all phone numbers from this contact
          for (var phone in contact.phones) {
            // Clean phone number (remove non-digit characters)
            String cleanNumber = phone.number.replaceAll(RegExp(r'[^\d+]'), '');
            
            if (cleanNumber.isNotEmpty) {
              validContacts.add(ContactModel(
                name: contact.displayName,
                phoneNumber: cleanNumber
              ));
            }
          }
        }
      }
      
      print('✅ Successfully processed ${validContacts.length} contacts with phone numbers');
      
      // Add manual contacts to the list
      validContacts.addAll(manualContacts);
      
      print('📊 Total contacts: ${validContacts.length} (${manualContacts.length} manual)');
      
      return validContacts;
      
    } catch (e) {
      print('❌ Error in getRealContacts: $e');
      // Fallback to manual contacts only
      return List.from(manualContacts);
    }
  }

  // Get contacts (main method)
  static Future<List<ContactModel>> getContacts() async {
    return await getRealContacts();
  }

  // Tambah kontak manual
  static void addManualContact(String name, String phoneNumber) {
    // Clean phone number
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    manualContacts.add(ContactModel(name: name, phoneNumber: cleanNumber));
    print('✅ Added manual contact: $name - $cleanNumber');
  }

  // Hapus kontak manual
  static void removeManualContact(int index) {
    if (index >= 0 && index < manualContacts.length) {
      final removed = manualContacts.removeAt(index);
      print('🗑️ Removed contact: ${removed.name}');
    }
  }

  // Get contact statistics
  static Future<Map<String, int>> getContactStats() async {
    final realContacts = await getRealContacts();
    return {
      'total': realContacts.length,
      'manual': manualContacts.length,
      'fromDevice': realContacts.length - manualContacts.length,
    };
  }

  // Get dummy contacts untuk testing
  static List<ContactModel> getDummyContacts() {
    return [
      ContactModel(name: 'Ibu', phoneNumber: '08123456789'),
      ContactModel(name: 'Ayah', phoneNumber: '08234567890'),
      ContactModel(name: 'Rumah Sakit', phoneNumber: '08345678901'),
    ];
  }

  static Future<Map<String, dynamic>> syncContactsToCloud() async {
    try {
      final contacts = await getRealContacts();
      
      if (contacts.isEmpty) {
        return {
          'success': false,
          'message': 'No contacts found to sync'
        };
      }
      
      final result = await FirebaseService.uploadContacts(contacts);
      return result;
      
    } catch (e) {
      print('❌ Error in syncContactsToCloud: $e');
      return {
        'success': false,
        'message': 'Sync failed: $e'
      };
    }
  }
}
