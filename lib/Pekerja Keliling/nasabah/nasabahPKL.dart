import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NasabahPkl extends StatefulWidget {
  const NasabahPkl({super.key});

  @override
  State<NasabahPkl> createState() => _NasabahPklState();
}

class _NasabahPklState extends State<NasabahPkl> {
  int _selectedIndex = 1;
  bool _isLoading = true;
  String token = '';
  Map<String, dynamic> data = {};
  final searchController = TextEditingController();
  List filteredUsers = [];

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('tokenEmployee') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getDaftarNasabah(token);
      if (response != null) {
        setState(() {
          data = response;
          filteredUsers = List.from(data['user']);
          // print(data);
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
    searchController.addListener(() {
      filterTransactions(searchController.text);
    });
    print(filteredUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.only(top: 40), // Sesuaikan spacing yang diinginkan
            child: AppBar(
              title: Text(
                "Nasabah",
                style:
                    TextStyle(color: Colors.brown, fontWeight: FontWeight.bold, fontSize: 24),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pencarian nasabah
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari Nasabah',
                filled: true,
                fillColor: const Color(0xFFFDEFEA), // Warna cream muda
                prefixIcon: const Icon(Icons.search, color: Colors.brown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Daftar nasabah
            Expanded(
              child: ListView.builder(
                itemCount: data['user'].length,
                itemBuilder: (context, index) {
                  final nasabah = data['user'][index];
                  return Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEFEA),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Status icon
                            Icon(
                              nasabah['status']
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  nasabah['status'] == 'Aktif' ? Colors.green : Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            // Nama dan alamat nasabah
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nasabah['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                                Text(
                                  nasabah['address'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.brown,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(width: 12),
                        // Tombol View Details
                        ElevatedButton(
                          onPressed: () {
                            // Navigasi ke halaman detail
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailNasabahPage(nasabah: nasabah),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFFF2E6), // Warna cream button
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9.0, vertical: 8.0),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
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
          } else if (index == 2) {
            MyApp.navigatorKey.currentState!.pushNamed('/emp/profil');
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

  // Fungsi untuk filter transactions
  void filterTransactions(String query) {
    if (data['transactions'] == null) return; // Early return jika data null

    setState(() {
      if (query.isEmpty) {
        filteredUsers = List.from(data['transactions']);
      } else {
        filteredUsers = data['transactions'].where((transaction) {
          if (transaction == null) return false;

          var cardId = transaction['card_id']?.toString() ?? '';
          var cardNumber = data['card_numbers']?[cardId]?.toString() ?? '';
          return cardNumber.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

// Halaman Detail Nasabah
class DetailNasabahPage extends StatelessWidget {
  final Map<String, dynamic> nasabah;

  const DetailNasabahPage({required this.nasabah, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail ${nasabah['name']}'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama: ${nasabah['name']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Alamat: ${nasabah['address']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${nasabah['status'] ? 'Selesai' : 'Belum'}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
