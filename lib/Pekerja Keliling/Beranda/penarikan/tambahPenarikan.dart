import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahPenarikan extends StatefulWidget {
  const TambahPenarikan({super.key});

  @override
  State<TambahPenarikan> createState() => _TambahPenarikanState();
}

class _TambahPenarikanState extends State<TambahPenarikan> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String token = '';
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> data = {};
  final _cardNumberController = TextEditingController();
  final _nominalController = TextEditingController();
  final _dateController = TextEditingController();
  final _deskripsiController = TextEditingController();

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('tokenEmployee') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getAddPenarikanForEmployee(token);
      if (response != null) {
        setState(() {
          data = response;
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
  }

  void _showStatusDialog(String title, String message, String actionUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFEBDC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF7B5233),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(thickness: 1.0, color: Color(0xFFC4C4C4)),
                const SizedBox(height: 0.5),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: TextStyle(fontSize: 14, color: Color(0xFF6A584E)),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                const SizedBox(height: 0.5),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                alignment: Alignment.center,
                backgroundColor: const Color(0xFF7B5233),
                minimumSize: const Size(300, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                MyApp.navigatorKey.currentState!.popAndPushNamed(actionUrl);
                // Implement logic for submission here
              },
              child: const Text(
                "Lanjut",
                style: TextStyle(color: Colors.white),
              ),
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.only(top: 10), // Sesuaikan spacing yang diinginkan
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.brown),
                onPressed: () {
                  MyApp.navigatorKey.currentState!
                      .pushNamed('/emp/daftar-penarikan');
                },
              ),
              title: Text(
                "Tambah Penarikan",
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.brown[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nomor Kartu",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _cardNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Masukkan Nomor Kartu",
                      filled: true,
                      fillColor: Colors.brown[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Nominal Penarikan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nominalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: "Rp. ",
                      hintText: "0",
                      filled: true,
                      fillColor: Colors.brown[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Tanggal",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "dd/mm/yy",
                            filled: true,
                            fillColor: Colors.brown[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Colors.brown),
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2022),
                            lastDate: DateTime(2030),
                          ).then((pickedDate) {
                            if (pickedDate == null) {
                              return;
                            }
                            // Tambahkan pengecekan mounted
                            if (mounted) {
                              // Cek apakah widget masih ada di tree
                              setState(() {
                                _selectedDate = pickedDate;
                                _dateController.text =
                                    "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Deskripsi",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _deskripsiController,
                    decoration: InputDecoration(
                      hintText: "Masukkan Deskripsi",
                      filled: true,
                      fillColor: Colors.brown[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
                try {
                  final response =
                      await DioProvider().storeAddPenarikanForEmployee(
                    token,
                    _cardNumberController.text.trim(),
                    double.parse(_nominalController.text),
                    _selectedDate,
                    _deskripsiController.text.trim(),
                  );

                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  if (response == 203) {
                    if (mounted) {
                      _showStatusDialog(
                        "Penarikan Ditolak",
                        "Transaksi gagal diproses. Saldo pada nasabah tidak mencukupi untuk melakukan penarikan.",
                        "/emp/daftar-penarikan",
                      );
                    }
                    await getData();
                  }
                  else if (response == 200) {
                    if (mounted) {
                      _showStatusDialog(
                        "Penarikan Diproses",
                        "Transaksi berhasil diproses. Saldo pada nasabah telah diperbarui.",
                        "/emp/dashboard",
                      );
                    }
                    await getData();
                  }
                } catch (error) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                    // Tambahkan logika untuk menampilkan dialog atau pemberitahuan error
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(16.0),
              ),
              child: Text(
                "Simpan Transaksi",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
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

  @override
  void dispose() {
    super.dispose();
  }
}
