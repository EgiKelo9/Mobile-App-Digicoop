import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _selectedIndex = 3;
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
    token = prefs.getString('tokenUser') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getUserProfil(token);
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

  void _showEditConfirmation(String field) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$field berhasil diubah!')),
    );
    initState();
  }

  Widget _buildEditableDetailItem(
      String title, String value, TextEditingController controller,
      {bool editable = true}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  data['user'][value],
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
                          .updateUserProfil(token, controller.text, null, null);
                      break;
                    case 'Username':
                      profilStored = await DioProvider()
                          .updateUserProfil(token, null, controller.text, null);
                      break;
                    case 'Address':
                      profilStored = await DioProvider()
                          .updateUserProfil(token, null, null, controller.text);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/BlankProfile.png'),
            ),
            const SizedBox(height: 15),
            Text(
              data['user']['name'],
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A584E)),
            ),
            Text(
              data['user']['email'],
              style: TextStyle(fontSize: 13, color: Color(0xFF6A584E)),
            ),
            const SizedBox(height: 30),

            // Bagian Personal Details
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Container(
                width: 333,
                height: 40,
                color: const Color(0xFFFFEFE2), // Background color
                alignment: Alignment.center,
                child: const Text(
                  "Personal Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A584E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                _buildEditableDetailItem(
                    "Full Name", 'name', fullNameController),
                _buildEditableDetailItem(
                    "Username", 'username', usernameController),
                _buildEditableDetailItem("Email", 'email', emailController,
                    editable: false),
                _buildEditableDetailItem(
                    "Phone", 'phone_number', phoneController,
                    editable: false),
                _buildEditableDetailItem(
                    "Address", 'address', addressController),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        'Log Out',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      content:
                          const Text('Apakah Anda yakin ingin keluar akun?'),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A584E),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (_selectedIndex != index) {
            setState(() {
              _selectedIndex = index;
            });
            Future.microtask(() {
              if (index == 0) {
                MyApp.navigatorKey.currentState!.pushNamed('/dashboard');
              } else if (index == 1) {
                MyApp.navigatorKey.currentState!.pushNamed('/history-simpanan');
              } else if (index == 2) {
                MyApp.navigatorKey.currentState!.pushNamed('/ajukan-simpanan');
              } else if (index == 3) {
                MyApp.navigatorKey.currentState!.pushNamed('/profil');
              }
            });
          }
        },
          items: const [
          BottomNavigationBarItem(icon: ImageIcon(AssetImage('assets/home.png')), label: 'Beranda'),
          BottomNavigationBarItem(icon: ImageIcon(AssetImage('assets/riwayat.png')), label: 'Riwayat'),
          BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/ajukan.png')), label: 'Ajukan'),
          BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/profile.png')), label: 'Profil'),
        ],
      ),
    );
  }
}

