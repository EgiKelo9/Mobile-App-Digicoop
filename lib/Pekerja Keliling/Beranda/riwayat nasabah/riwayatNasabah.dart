import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatNasabah extends StatefulWidget {
  const RiwayatNasabah({super.key});

  @override
  State<RiwayatNasabah> createState() => _RiwayatNasabahState();
}

class _RiwayatNasabahState extends State<RiwayatNasabah> {
  String? _selectedPeriode;
  int _selectedIndex = 1;
  bool _isLoading = true;
  String token = '';
  Map<String, dynamic> data = {};
  final searchController = TextEditingController();
  List filteredTransactions = [];

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('tokenEmployee') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getDaftarNasabah(token);
      if (response != null) {
        setState(() {
          data = response;
          filteredTransactions = List.from(data['transactions']);
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
    print(filteredTransactions);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.only(top: 10), // Sesuaikan spacing yang diinginkan
            child: AppBar(
              title: Text(
                "Nasabah",
                style:
                    TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input ID Nasabah
            TextField(
              decoration: InputDecoration(
                hintText: "Input ID Nasabah",
                fillColor: Color(0xFFF3E8E1),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Judul Pilih Periode Pencarian
            Text(
              "Pilih Periode Pencarian:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Radio Buttons untuk memilih periode
            Column(
              children: [
                RadioListTile<String>(
                  value: "Hari ini",
                  groupValue: _selectedPeriode,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriode = value;
                    });
                  },
                  title: Text("Hari ini"),
                  activeColor: Colors.brown,
                ),
                RadioListTile<String>(
                  value: "1 Minggu",
                  groupValue: _selectedPeriode,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriode = value;
                    });
                  },
                  title: Text("1 Minggu"),
                  activeColor: Colors.brown,
                ),
                RadioListTile<String>(
                  value: "1 Bulan",
                  groupValue: _selectedPeriode,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriode = value;
                    });
                  },
                  title: Text("1 Bulan"),
                  activeColor: Colors.brown,
                ),
                RadioListTile<String>(
                  value: "Pilih Tanggal",
                  groupValue: _selectedPeriode,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriode = value;
                    });
                    if (value == "Pilih Tanggal") {
                      // Logika untuk membuka date picker
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      ).then((date) {
                        if (date != null) {
                          print(
                              "Tanggal dipilih: $date"); // Handle tanggal di sini
                        }
                      });
                    }
                  },
                  title: Text("Pilih Tanggal"),
                  activeColor: Colors.brown,
                ),
              ],
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Fungsi kosong untuk tombol Terapkan
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Terapkan',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Pilih tab "Nasabah"
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown[300],
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
        filteredTransactions = List.from(data['transactions']);
      } else {
        filteredTransactions = data['transactions'].where((transaction) {
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
