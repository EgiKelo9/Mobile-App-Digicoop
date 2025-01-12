import 'package:digicoop/Riwayat/rentangwaktu.dart';
import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Riwayat extends StatefulWidget {
  const Riwayat({super.key});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  int _selectedIndex = 1;
  bool _isLoading = true;
  Map<String, dynamic> data = {};

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenUser') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getUserHistorySimpanan(token);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Riwayat",
              style: TextStyle(
                color: Color(0xFF7B5233),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 24),

            // Fixed Tab buttons implementation
            Row(
              children: [
                Expanded(
                  child: _buildTabButton("Simpanan", true),
                ),
                SizedBox(width: 8), // Added spacing between tabs
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      MyApp.navigatorKey.currentState!
                          .pushNamed('/history-pinjaman');
                    },
                    child: _buildTabButton("Pinjaman", false),
                  ),
                ),
                SizedBox(width: 8), // Added spacing between tabs
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      MyApp.navigatorKey.currentState!
                          .pushNamed('/history-penarikan');
                    },
                    child: _buildTabButton("Penarikan", false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Filter section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['card']['card_number'],
                  style: TextStyle(
                    color: Color(0xFF7B5233),
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.filter_list_alt, color: Color(0xFF7B5233)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => rentangwaktu()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.download, color: Color(0xFF7B5233)),
                      onPressed: () {
                        // Implement download functionality
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1),
            Expanded(
              child: (data['simpanan'] != null && data['simpanan'] is List)
                  ? ListView.builder(
                      itemCount: data['simpanan'].length,
                      itemBuilder: (context, index) {
                        final transaction = data['simpanan'][index];
                        final transactionTypeId = transaction['transaction_type_id'];
                        final status = transaction['status'];

                        // Determine transaction title based on type ID
                        String title = '';
                        if (transactionTypeId == 1) {
                          title = 'Tabungan';
                        } else if ([2, 3, 4].contains(transactionTypeId)) {
                          title = 'Deposito';
                        } else if (transactionTypeId == 5) {
                          title = 'Penarikan';
                        } else {
                          title = 'Pinjaman';
                        }

                        Color statusColor = status == 'Pending'
                            ? Colors.orange
                            : (status == 'Ditolak' ? Colors.red : Colors.green);

                        // Group transactions by updated_at date
                        final currentDate = formatDateTime(transaction['updated_at']);
                        final previousDate = index > 0
                            ? formatDateTime(data['simpanan'][index - 1]['updated_at'])
                            : '';

                        // Add spacing between different date groups
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (currentDate != previousDate) _buildTransactionDate(currentDate),
                            _buildTransactionItem(
                              index,
                              transaction['amount'].toDouble(),
                              title,
                              status,
                              statusColor,
                            ),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Text('Tidak ada transaksi yang ditemukan.'),
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

  Widget _buildTabButton(String label, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF6A584E) : Color(0xFFFFEBDC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? Colors.white : Color(0xFF7B5233),
          fontWeight: FontWeight.w600,
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

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )},00';
  }

  Widget _buildTransactionDate(String date) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Text(
        date,
        style: TextStyle(
          color: Color(0xFF7B5233),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    int index,
    double amount,
    String title,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF6EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_upward, color: Color(0xFF7B5233)),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatCurrency(amount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7B5233),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7B5233),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
