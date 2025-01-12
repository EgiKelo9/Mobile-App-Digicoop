import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Penarikan extends StatefulWidget {
  const Penarikan({super.key});

  @override
  State<Penarikan> createState() => _PenarikanState();
}

class _PenarikanState extends State<Penarikan> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String token = '';
  Map<String, dynamic> data = {};
  final searchController = TextEditingController();
  List filteredTransactions = [];

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('tokenEmployee') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getPenarikanForEmployee(token);
      if (response != null) {
        setState(() {
          data = response;
          filteredTransactions = List.from(data['transactions']);
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
    print(filteredTransactions);
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
        preferredSize: Size.fromHeight(100),
        child: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.only(top: 40), // Sesuaikan spacing yang diinginkan
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.brown),
                onPressed: () {
                  MyApp.navigatorKey.currentState!.pushNamed('/emp/dashboard');
                },
              ),
              title: Text(
                "Penarikan",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Cari Nomor Kartu",
                prefixIcon: Icon(Icons.search, color: Colors.brown),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.brown),
                        onPressed: () {
                          searchController.clear();
                          filterTransactions('');
                        },
                      )
                    : null,
                fillColor: Color(0xFFF3E8E1),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Daftar Penarikan:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // List of Tabungan
            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Text(
                          'Tidak ada data')) // Tampilkan pesan jika tidak ada data
                  : ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        if (transaction == null) {
                          return SizedBox(); // Skip jika transaksi null
                        }
                        var cardId = transaction['card_id']?.toString() ?? '';
                        var cardNumber =
                            data['card_numbers']?[cardId]?.toString() ??
                                'No Card Number';

                        return tabunganCard(
                          transaction['id'],
                          cardNumber,
                          transaction['amount'] ?? 0,
                          transaction['description'] ?? 'Tidak ada deskripsi',
                        );
                      },
                    ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // atau .endFloat
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 16), // Tambahkan padding bottom
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/emp/tambah-penarikan');
          },
          backgroundColor: Colors.white,
          child: Icon(Icons.add),
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

  Widget tabunganCard(
      id, String nomorKartu, double nominal, String? deskripsi) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF3E8E1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nasabah #$nomorKartu",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.brown,
            ),
          ),
          SizedBox(height: 4),
          Text(
            formatCurrency(nominal),
            style: TextStyle(
              fontSize: 20,
              color: Colors.brown,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Text(
                    deskripsi ?? "Transaksi Penarikan",
                    style: TextStyle(
                      color: Colors.brown,
                    ),
                    maxLines: 2, // Batasi menjadi 2 baris
                    overflow: TextOverflow
                        .ellipsis, // Akan menampilkan ... jika text terpotong
                  ),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            "Proses Transaksi",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7B5233),
                            ),
                          ),
                          content: Text(
                            "Pilih aksi untuk memproses transaksi. Anda bisa memilih untuk menerima atau menolak transaksi.",
                            textAlign: TextAlign.justify,
                          ),
                          actions: <Widget>[
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
                                'Tolak',
                                style:
                                    TextStyle(color: const Color(0xFF7B5233)),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                                setState(() {
                                  _isLoading = true;
                                });
                                final processed = await DioProvider()
                                    .processPenarikanForEmployee(
                                        token, id, 'Tolak');
                                setState(() {
                                  _isLoading = false;
                                });
                                if (processed == 200) {
                                  _showStatusDialog(
                                      "Transaksi Ditolak",
                                      "Transaksi telah ditolak. Saldo pada nasabah tidak diperbarui.",
                                      "/daftar-penarikan");
                                  await getData();
                                }
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
                                'Terima',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                                setState(() {
                                  _isLoading = true;
                                });
                                final processed = await DioProvider()
                                    .processPenarikanForEmployee(
                                        token, id, 'Terima');
                                setState(() {
                                  _isLoading = false;
                                });
                                if (processed == 200) {
                                  _showStatusDialog(
                                      "Transaksi Diterima",
                                      "Transaksi telah diterima. Saldo pada nasabah telah diperbarui.",
                                      "/daftar-penarikan");
                                  await getData();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 80,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF6A584E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Proses",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String formatCurrency(double amount) {
  return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      )},00';
}
