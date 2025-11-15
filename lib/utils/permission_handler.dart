import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<bool> requestContactPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  static Future<bool> requestPhonePermission() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  static Future<bool> hasAllPermissions() async {
    final contactsGranted = await Permission.contacts.isGranted;
    final phoneGranted = await Permission.phone.isGranted;
    
    print('📱 Contacts Permission: $contactsGranted');
    print('📞 Phone Permission: $phoneGranted');
    
    return contactsGranted && phoneGranted;
  }
}