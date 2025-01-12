import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ProfilPkl extends StatefulWidget {
  const ProfilPkl({super.key});

  @override
  State<ProfilPkl> createState() => _ProfilPklState();
}

class _ProfilPklState extends State<ProfilPkl> {
  int _selectedIndex = 2;
  bool _isLoading = true;
  String token = "";
  Map<String, dynamic> data = {};

  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final workAreaController = TextEditingController();
  final addressController = TextEditingController();

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('tokenEmployee') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getEmployeeProfil(token);
      if (response != null) {
        setState(() {
          data = response;
          print(data);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getData().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget _buildEditableDetailItem(
      String title, String value, TextEditingController controller,
      {bool editable = true}) {
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.brown),
                ),
                const SizedBox(height: 4),
                Text(
                  value == 'district' ? data['district'] : data['employee'][value],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A584E)),
                ),
              ],
            ),
          ),
          editable
              ? IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right,
                      color: Colors.brown),
                  onPressed: () {
                    _editField(title, controller);
                  },
                )
              : Container(), // Empty container if not editable
        ],
      ),
    );
  }

  void _editField(String title, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Edit $title",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF7B5233),
            ),
          ),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: title,
              labelText: title,
              labelStyle: TextStyle(
                color: Color(0xFF7B5233),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: Color(0xFF7B5233),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: Color(0xFF7B5233),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(
                      color: Color(0xFF7B5233),
                    ),
                  ),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(color: const Color(0xFF7B5233)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  const Color(0xFF6A584E),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                // Store context in a variable to check if mounted later
                final currentContext = context;

                try {
                  setState(() {
                    _isLoading = true;
                  });

                  dynamic profilStored;

                  // Update only the relevant field
                  switch (title) {
                    case 'Full Name':
                      profilStored = await DioProvider()
                          .updateEmployeeProfil(token, controller.text, null, null, null, null, null);
                      break;
                    case 'Username':
                      profilStored = await DioProvider()
                          .updateEmployeeProfil(token, null, controller.text, null, null, null, null);
                      break;
                    case 'Email':
                      profilStored = await DioProvider()
                          .updateEmployeeProfil(token, null, null, controller.text, null, null, null);
                      break;
                    case 'Phone Number':
                      profilStored = await DioProvider()
                          .updateEmployeeProfil(token, null, null, null, controller.text, null, null);
                      break;
                    case 'Work Area':
                      profilStored = await DioProvider()
                          .updateEmployeeProfil(token, null, null, null, null, controller.text, null);
                      break;
                    case 'Address':
                      profilStored = await DioProvider()
                          .updateEmployeeProfil(token, null, null, null, null, null, controller.text);
                      break;
                  }

                  // Check if widget is still mounted before updating state
                  if (!mounted) return;

                  setState(() {
                    _isLoading = false;
                  });

                  if (profilStored == 200) {
                    // Check if context is still valid
                    if (!mounted) return;

                    // Show success message
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      SnackBar(
                        content: Text('Profil berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Close the dialog
                    Navigator.of(currentContext).pop();
                    // Refresh user data if needed
                    await getData();

                    // You might want to add a callback here to refresh the parent widget
                  }
                } catch (e) {
                  // Check if widget is still mounted before showing error
                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception:', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditConfirmation(String field) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$field berhasil diubah!')),
    );
    initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.white, // Warna latar belakang krem
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 16),
              // Foto profil
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    AssetImage('assets/profile.png'), // Path gambar profil
              ),
              const SizedBox(height: 16),
              // Nama dan Email
              Text(
                data['employee']['name'], // Nama
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data['employee']['email'], // Email
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              // Card untuk Personal Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEDFD2), // Warna krem muda
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Personal Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Detail informasi
                    _buildEditableDetailItem('Full Name', 'name', fullNameController),
                    _buildEditableDetailItem('Username', 'username', usernameController),
                    _buildEditableDetailItem('Email', 'email', emailController, editable: false),
                    _buildEditableDetailItem('Phone', 'phone_number', phoneController, editable: false),
                    _buildEditableDetailItem('Work Area', 'district', workAreaController, editable: false),
                    _buildEditableDetailItem('Address', 'address', addressController),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tombol Log Out
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown, // Warna tombol
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Apakah Anda yakin ingin keluar akun?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            MyApp.navigatorKey.currentState!.pushNamed('/');
                          },
                          child: const Text('Keluar'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            MyApp.navigatorKey.currentState!.pushNamed('/emp/dashboard');
          } else if (index == 1) {
            MyApp.navigatorKey.currentState!.pushNamed('/emp/nasabah');
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/home.png')), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/nasabah.png')),
              label: 'Nasabah'),
          BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/profile.png')),
              label: 'Profil'),
        ],
      ),
    );
  }

}

// Widget untuk menampilkan item detail
