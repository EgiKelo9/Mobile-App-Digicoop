import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  int _selectedIndex = 0;
  int _saldoIndex = 0;
  int saldoItemsLength = 3;
  bool _isLoading = true;
  Map<String, dynamic> data = {};

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenUser') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getUser(token);
      if (response != null) {
        setState(() {
          data = response; // Langsung assign response.data ke user
          // print(data);
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

    double tabungan = data['balance_tabungan'] ?? 0.0;
    double penarikan = data['balance_penarikan'] ?? 0.0;
    double selisih = tabungan - penarikan;
    bool isPositive = selisih >= 0;

    String formattedSelisih = formatCurrency(selisih.abs());

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await getData();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/BlankProfile.png'),
                        radius: 28,
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            data['user']['name'],
                            // data['user']("name"),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          MyApp.navigatorKey.currentState!
                              .pushNamed('/notification');
                        },
                        child: Icon(
                          Icons.notifications,
                          size: 32,
                          color: Colors.grey[700],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            data['announcements'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  setState(() {
                    if (details.primaryVelocity! > 0) {
                      // Swipe right to go to the previous item, if possible
                      _saldoIndex =
                          (_saldoIndex - 1 + saldoItemsLength) % saldoItemsLength;
                    } else if (details.primaryVelocity! < 0) {
                      // Swipe left to go to the next item
                      _saldoIndex = (_saldoIndex + 1) % saldoItemsLength;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A584E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _saldoIndex == 0
                            ? 'Saldo Tabungan'
                            : _saldoIndex == 1
                                ? 'Saldo Deposito'
                                : 'Sisa Pinjaman',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _saldoIndex == 0
                            ? formatCurrency(
                                data['card']['balance_tabungan'] ?? 0.0)
                            : _saldoIndex == 1
                                ? formatCurrency(
                                    data['card']['balance_deposito'] ?? 0.0)
                                : formatCurrency(
                                    data['card']['balance_pinjaman'] ?? 0.0),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            data['card']['card_number'] ?? 'Belum memiliki kartu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: data['card']['card_number'] ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Nomor akun disalin ke clipboard')),
                              );
                            },
                            child: const Icon(Icons.copy,
                                size: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMenuButton(Icons.savings, 'Simpanan', '/ajukan-simpanan'),
                  _buildMenuButton(
                      Icons.attach_money, 'Pinjaman', '/ajukan-pinjaman'),
                  _buildMenuButton(
                      Icons.money_off, 'Penarikan', '/ajukan-penarikan'),
                  _buildMenuButton(
                      Icons.receipt_long, 'Rekap', '/history-simpanan'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Ringkasan Keuangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Tabungan',
                          style: TextStyle(color: Colors.green),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formatCurrency(tabungan),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Penarikan',
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formatCurrency(penarikan),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selisih',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    '${isPositive ? '+' : '-'} $formattedSelisih',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    (data['transactions'] != null && data['transactions'] is List)
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
                            child: Text('Tidak ada transaksi yang ditemukan.'),
                          ),
              ),
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
            MyApp.navigatorKey.currentState!.pushNamed('/dashboard');
          } else if (index == 1) {
            MyApp.navigatorKey.currentState!.pushNamed('/history-simpanan');
          } else if (index == 2) {
            MyApp.navigatorKey.currentState!.pushNamed('/ajukan-simpanan');
          } else if (index == 3) {
            MyApp.navigatorKey.currentState!.pushNamed('/profil');
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/home.png')), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/riwayat.png')),
              label: 'Riwayat'),
          BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/ajukan.png')),
              label: 'Ajukan'),
          BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/profile.png')),
              label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String label, String redirectPage) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            MyApp.navigatorKey.currentState!.pushNamed(redirectPage);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFEBDC),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, color: const Color(0xFF7B5233), size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7B5233),
            fontSize: 14,
          ),
        ),
      ],
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


