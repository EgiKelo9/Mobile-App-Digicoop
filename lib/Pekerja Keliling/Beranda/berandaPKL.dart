import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class BerandaPkl extends StatefulWidget {
  const BerandaPkl({super.key});

  @override
  State<BerandaPkl> createState() => _BerandaPklState();
}

class _BerandaPklState extends State<BerandaPkl> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic> data = {};

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenEmployee') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getEmployee(token);
      if (response != null) {
        setState(() {
          data = response; // Langsung assign response.data ke user
          print(data);
        });
      } else {
        _isLoading = false;
      }
    } else {
      _isLoading = false;
    }
  }

  Future<List<dynamic>> getTransactions(Map<String, dynamic> data) async {
    final List<dynamic> transactions = data['transactions']?.cast<dynamic>();
    return transactions;
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/BlankProfile.png'), // Sesuaikan gambar
                      radius: 27,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['employee']['name'],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.brown),
                        ),
                        Text(
                          '${data['employee']['city']}, ${data['employee']['province']}',
                          style: TextStyle(fontSize: 14, color: Colors.brown),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xB2CFB4A4)),
                  padding: EdgeInsets.all(6),
                  child: Stack(
                    children: [
                      Icon(Icons.notifications, size: 28),
                      Positioned(
                        right: 0,
                        // Adjusted position for notification icon
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 8,
                          child: Text(
                            '5',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Ringkasan Kunjungan
            Card(
              color: Color(0xFF69574D),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      // Start a Row to add an icon next to the text
                      mainAxisAlignment: MainAxisAlignment
                          .start, // Align children to the start (left)
                      children: [
                        Icon(
                          Icons.calendar_today, // Add the calendar icon
                          color: Colors.white,
                        ),
                        SizedBox(
                            width:
                                8), // Add some space between the icon and the text
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                              .format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffffffff),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // 25 customer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // TODO
                            MyApp.navigatorKey.currentState!.pushNamed('/emp/transaksi');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(13.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  data['visited'].toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF69574D),
                                  ),
                                ),
                                Text(
                                  'Transaksi Diproses',
                                  style: TextStyle(
                                    color: Color(0xFF67554B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 11 customer remaining
                        GestureDetector(
                          onTap: () {
                            // TODO
                            MyApp.navigatorKey.currentState!.pushNamed('/emp/tersisa');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(13.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  data['remaining'].toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF69574D),
                                  ),
                                ),
                                Text(
                                  'Transaksi Tersisa',
                                  style: TextStyle(
                                    color: Color(0xFF69574D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),

            // Total Dana and Navigasi Aktivitas combined
            Card(
              color: Color(0xFF69574D),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Dana
                    Text(
                      'Total Dana',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${formatCurrency(data['total_amount'])} /hari ini',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktivitas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Navigasi Aktivitas
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 0, // Remove spacing between columns
                          mainAxisSpacing: 0, // Remove spacing between rows
                          childAspectRatio:
                              2.7, // Keep the child aspect ratio to make cards wider
                          children: [
                            _buildMenuCard('Tabungan', Icons.arrow_upward),
                            _buildMenuCard('Penarikan', Icons.arrow_downward),
                            _buildMenuCard(
                                'Rekap Harian', Icons.calendar_today),
                            _buildMenuCard('Riwayat Nasabah', Icons.person),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Transaksi Terbaru
            Text(
              'Transaksi Terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: (data['transactions'] != null &&
                      data['transactions'] is List)
                  ? ListView.builder(
                      itemCount: data['transactions'].length,
                      itemBuilder: (context, index) {
                        final transaction = data['transactions'][index];
                        return ListTile(
                          leading: Icon(
                              data['transactions'][index]
                                          ['transaction_type_id'] >
                                      4
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: Colors.brown),
                          title: Text(
                            data['transactions'][index]
                                        ['transaction_type_id'] ==
                                    1
                                ? 'Tabungan'
                                : (data['transactions'][index]
                                            ['transaction_type_id'] <=
                                        4
                                    ? 'Deposito'
                                    : (data['transactions'][index]
                                                ['transaction_type_id'] ==
                                            5)
                                        ? 'Penarikan'
                                        : 'Pinjaman'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            formatCurrency(transaction['amount'] ?? 0),
                          ),
                          trailing: Text(
                            formatDateTime(
                                data['transactions'][index]['updated_at']),
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text("Tidak ada transaksi yang ditemukan"),
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
          if (index == 1) {
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

  Widget _buildMenuCard(String title, IconData icon) {
    return Card(
      color: Colors.white, // Set color for each menu card
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Logika navigasi berdasarkan title
          switch (title) {
            case 'Tabungan':
              MyApp.navigatorKey.currentState!.pushNamed('/emp/daftar-tabungan');
              break;
            case 'Penarikan':
              MyApp.navigatorKey.currentState!.pushNamed('/emp/daftar-penarikan'); // Ganti dengan page Penarikan
              break;
            case 'Rekap Harian':
              MyApp.navigatorKey.currentState!.pushNamed('/emp/rekap-harian');
              break;
            case 'Riwayat Nasabah':
              MyApp.navigatorKey.currentState!.pushNamed('/emp/nasabah');
              break;
          }
        }, // Add navigation if needed
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: Colors.brown),
              SizedBox(width: 8), // Fixed width compared to height
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF543E2D),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 0.15,
                  letterSpacing: -0.32,
                ),
              ),
            ],
          ),
        ),
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

String formatDateTime(String inputDate) {
  // Parsing input tanggal string ke objek DateTime
  DateTime dateTime = DateTime.parse(inputDate);
  String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
  String formattedTime = DateFormat('HH:mm').format(dateTime);
  return '$formattedDate\n$formattedTime';
}
