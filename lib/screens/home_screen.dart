import 'package:flutter/material.dart';
import '../services/contact_service.dart';
import '../utils/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String _status = 'Menunggu aksi...';
  int _contactCount = 0;
  
  // Controller untuk input form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    // Load dummy contacts untuk testing
    // _loadDummyContacts();
  }

  // METHOD - _loadDummyContacts
  // void _loadDummyContacts() {
  //   // Tambahkan dummy contacts untuk testing
  //   final dummyContacts = ContactService.getDummyContacts();
  //   for (var contact in dummyContacts) {
  //     ContactService.addManualContact(contact.name, contact.phoneNumber);
  //   }
  //   setState(() {
  //     _contactCount = ContactService.manualContacts.length;
  //   });
  // }

  Future<void> _checkPermissions() async {
    print('🔍 Checking permissions...');
    final hasPermissions = await PermissionHandler.hasAllPermissions();
    
    if (!hasPermissions) {
      setState(() {
        _status = 'Izin diperlukan untuk fitur lengkap';
      });
    } else {
      setState(() {
        _status = 'Semua izin telah diberikan';
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _status = 'Meminta izin...';
    });

    final contactGranted = await PermissionHandler.requestContactPermission();
    final phoneGranted = await PermissionHandler.requestPhonePermission();

    setState(() {
      _isLoading = false;
      if (contactGranted && phoneGranted) {
        _status = '✅ Semua izin diberikan';
      } else {
        _status = '❌ Beberapa izin ditolak';
      }
    });
  }

  // Tambahkan method untuk test real contacts
  Future<void> _testRealContacts() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing akses kontak real...';
    });

    try {
      final stats = await ContactService.getContactStats();
      
      setState(() {
        _isLoading = false;
        _status = 'Test berhasil!\n'
                  'Total: ${stats['total']} kontak\n'
                  'Dari perangkat: ${stats['fromDevice']}\n'
                  'Manual: ${stats['manual']}';
        _contactCount = stats['total']!;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Test gagal: $e';
      });
    }
  }

  // Update method _syncContacts untuk handle response:
  Future<void> _syncToCloud() async {
  setState(() {
    _isLoading = true;
    _status = 'Syncing contacts to cloud...';
  });

  try {
    final result = await ContactService.syncContactsToAPI();
    
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _status = '✅ ${result['message']}\n'
                  'Uploaded: ${result['uploaded_count']} contacts\n'
                  'Device: ${result['device_id']}';
      } else {
        _status = '❌ ${result['message']}';
      }
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
      _status = '❌ Cloud sync error: $e';
    });
  }
}

  void _addManualContact() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      setState(() {
        _status = '❌ Nama dan nomor harus diisi';
      });
      return;
    }

    ContactService.addManualContact(name, phone);
    
    setState(() {
      _contactCount = ContactService.manualContacts.length;
      _status = '✅ Kontak ditambahkan: $name';
      _nameController.clear();
      _phoneController.clear();
    });

    // Close keyboard
    FocusScope.of(context).unfocus();
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Kontak Manual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                hintText: 'Masukkan nama',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                hintText: 'Masukkan nomor telepon',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _addManualContact();
              Navigator.pop(context);
            },
            child: Text('Tambah'),
          ),
        ],
      ),
    );
  }


  // Future<void> _syncToCloud() async {
  //   setState(() {
  //     _isLoading = true;
  //     _status = 'Mengupload kontak ke cloud...';
  //   });

  //   try {
  //     final contacts = await ContactService.getContacts();
  //     final deviceId = await DeviceInfo.getDeviceId();
      
  //     if (contacts.isEmpty) {
  //       setState(() {
  //         _status = 'Tidak ada kontak yang ditemukan';
  //         _isLoading = false;
  //       });
  //       return;
  //     }
      
  //     setState(() {
  //       _status = 'Mengupload ${contacts.length} kontak ke Firebase...';
  //       _contactCount = contacts.length;
  //     });

  //     final result = await ContactService.syncContactsToCloud(contacts, deviceId);
      
  //     setState(() {
  //       if (result['success'] == true) {
  //         _status = '✅ ${result['message']}\n'
  //                   'Total: ${result['uploaded_count']} kontak\n'
  //                   'Device: ${result['device_id']}';
  //       } else {
  //         _status = '❌ ${result['message']}';
  //       }
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _status = '❌ Cloud sync error: $e';
  //     });
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // METHOD - _showContactsList
  void _showContactsList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Daftar Kontak Manual'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ContactService.manualContacts.length,
            itemBuilder: (context, index) {
              final contact = ContactService.manualContacts[index];
              return ListTile(
                title: Text(contact.name),
                subtitle: Text(contact.phoneNumber),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ContactService.removeManualContact(index);
                    setState(() {
                      _contactCount = ContactService.manualContacts.length;
                    });
                    Navigator.pop(context);
                    _showContactsList(); // Refresh dialog
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jagacall'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _showContactsList,
            tooltip: 'Lihat Daftar Kontak',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_callback,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'Jagacall',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Blokir panggilan otomatis dari nomor tidak dikenal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 30),
              
              // Status Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Status:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10),
                      if (_contactCount > 0)
                        Text(
                          'Kontak tersimpan: $_contactCount',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Buttons
              if (!_isLoading) ...[
                ElevatedButton.icon(
                  onPressed: _requestPermissions,
                  icon: Icon(Icons.lock_open),
                  label: Text('Minta Izin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _showAddContactDialog,
                  icon: Icon(Icons.person_add),
                  label: Text('Tambah Kontak Manual'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),

                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _syncToCloud,
                  icon: Icon(Icons.cloud_upload),
                  label: Text('Sync to Cloud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _testRealContacts,
                  icon: Icon(Icons.contacts),
                  label: Text('Test Kontak Real'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                // SizedBox(height: 10),
                // ElevatedButton.icon(
                //   onPressed: _syncToCloud,
                //   icon: Icon(Icons.sync),
                //   label: Text('Sync Kontak ke Server'),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue,
                //     foregroundColor: Colors.white,
                //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                //   ),
                // ),
              ],
              
              if (_isLoading) ...[
                SizedBox(height: 20),
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Loading...'),
              ],

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}