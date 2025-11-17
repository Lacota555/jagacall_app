import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/contact_model.dart';
import 'api_service.dart';

class ContactService {
  static List<ContactModel> manualContacts = [];

  static Future<List<ContactModel>> getRealContacts() async {
    try {
      if (!await FlutterContacts.requestPermission()) {
        return [];
      }

      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      List<ContactModel> valid = [];

      for (var c in contacts) {
        if (c.phones.isNotEmpty) {
          for (var phone in c.phones) {
            String clean = phone.number.replaceAll(RegExp(r'[^\d+]'), '');
            if (clean.isNotEmpty) {
              valid.add(ContactModel(
                name: c.displayName,
                phoneNumber: clean,
              ));
            }
          }
        }
      }

      // include manual contacts
      valid.addAll(manualContacts);

      return valid;

    } catch (e) {
      return manualContacts;
    }
  }

  static void addManualContact(String name, String phone) {
    String clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    manualContacts.add(ContactModel(name: name, phoneNumber: clean));
  }

  static void removeManualContact(int index) {
    if (index >= 0 && index < manualContacts.length) {
      manualContacts.removeAt(index);
    }
  }

  static Future<Map<String, int>> getContactStats() async {
    final contacts = await getRealContacts();
    return {
      'total': contacts.length,
      'manual': manualContacts.length,
      'fromDevice': contacts.length - manualContacts.length,
    };
  }

  // static List<ContactModel> getDummyContacts() {
  //   return [
  //     ContactModel(name: 'Ibu', phoneNumber: '08123456789'),
  //     ContactModel(name: 'Ayah', phoneNumber: '08234567890'),
  //     ContactModel(name: 'Rumah Sakit', phoneNumber: '08345678901'),
  //   ];
  // }

  static Future<Map<String, dynamic>> syncContactsToAPI() async {
    try {
      final contacts = await getRealContacts();

      if (contacts.isEmpty) {
        return {
          'success': false,
          'message': 'No contacts found'
        };
      }

      final result = await ContactApiService.uploadContacts(contacts);
      return result;

    } catch (e) {
      return {
        'success': false,
        'message': 'Sync failed: $e'
      };
    }
  }
}
