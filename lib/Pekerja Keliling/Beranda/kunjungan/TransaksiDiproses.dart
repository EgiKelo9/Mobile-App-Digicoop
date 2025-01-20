import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TransaksiDiproses extends StatefulWidget {
  const TransaksiDiproses({super.key});

  @override
  State<TransaksiDiproses> createState() => _TransaksiDiprosesState();
}

class _TransaksiDiprosesState extends State<TransaksiDiproses> {
  int _selectedIndex = 0;
  String token = '';
  bool _isLoading = true;
  Map<String, dynamic> data = {};

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('tokenEmployee') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getTransaksiDiproses(token);
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
    initializeDateFormatting('id_ID', null).then((_) {
      getData().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
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
            padding: EdgeInsets.only(top: 10),
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.brown),
                onPressed: () {
                  MyApp.navigatorKey.currentState!.pushNamed('/emp/dashboard');
                },
              ),
              title: Text(
                "Transaksi Diproses",
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
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF6A584E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        MyApp.navigatorKey.currentState!
                            .pushNamed('/emp/transaksi');
                      },
                      child: const Text(
                        "Transaksi Diproses",
                        style: (TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.brown[50],
                        foregroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        MyApp.navigatorKey.currentState!
                            .pushNamed('/emp/tersisa');
                      },
                      child: const Text("Transaksi Tersisa"),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Akun Pegawai",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "EMP${data['employee']['id']}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Added for spacing between elements
            Expanded(
              child: ListView.builder(
                itemCount: data['transactions'].length,
                itemBuilder: (context, index) {
                  final customer = data['transactions'][index]['card']['user'];
                  final type =
                      data['transactions'][index]['transaction_type_id'];
                  final trxNumber = data['transactions'][index]['trx_number'];
                  final status = data['transactions'][index]['status'];
                  final transaction = data['transactions'][index];
                  // Group transactions by updated_at date
                  final currentDate = formatDateTime(transaction['updated_at']);
                  final previousDate = index > 0
                      ? formatDateTime(
                          data['transactions'][index - 1]['updated_at'])
                      : '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentDate != previousDate)
                          _buildTransactionDate(currentDate),
                        _buildTransactionItem(
                          customer['name'],
                          type == 1
                              ? 'Tabungan'
                              : (type <= 4)
                                  ? 'Deposito'
                                  : (type == 5)
                                      ? 'Penarikan'
                                      : 'Pinjaman',
                          trxNumber,
                          status,
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

  Widget _buildTransactionItem(
      String name, String type, String trxNumber, String status) {
    return Card(
      color: const Color(0xFFFFEFE2),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.brown),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          'Transaksi $type' '\n' '#$trxNumber',
          style: const TextStyle(color: Colors.brown, fontSize: 12),
        ),
        trailing: Text(
          status,
          style: const TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  String formatDateTime(String inputDate) {
    // Parsing input tanggal string ke objek DateTime
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);
    return formattedDate;
  }

  Widget _buildTransactionDate(String date) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        date,
        style: TextStyle(
          color: Color(0xFF7B5233),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
