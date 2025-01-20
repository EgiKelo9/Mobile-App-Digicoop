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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 30),
              // Header with profile
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/BlankProfile.png'),
                    radius: 27,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['employee']['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.brown,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data['employee']['city'] ?? ''}, ${data['employee']['province'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.brown,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xB2CFB4A4),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications, size: 28),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: const Text(
                              '5',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date and Transaction Summary Card
              Card(
                color: const Color(0xFF69574D),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                  .format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTransactionSummaryCard(
                              data['visited']?.toString() ?? '0',
                              'Transaksi Diproses',
                              onTap: () => MyApp.navigatorKey.currentState!
                                  .pushNamed('/emp/transaksi'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTransactionSummaryCard(
                              data['remaining']?.toString() ?? '0',
                              'Transaksi Tersisa',
                              onTap: () => MyApp.navigatorKey.currentState!
                                  .pushNamed('/emp/tersisa'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Total Dana and Activities Card
              Card(
                color: const Color(0xFF69574D),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Dana',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${formatCurrency(data['total_amount'] * 1.0 ?? 0)} /hari ini',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.5,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        children: [
                          _buildMenuCard('Tabungan', Icons.arrow_upward),
                          _buildMenuCard('Penarikan', Icons.arrow_downward),
                          _buildMenuCard('Rekap Harian', Icons.calendar_today),
                          _buildMenuCard('Nasabah', Icons.person),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recent Transactions
              const Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildTransactionsList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTransactionSummaryCard(String value, String label,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF69574D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF69574D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: InkWell(
        onTap: () {
          switch (title) {
            case 'Tabungan':
              MyApp.navigatorKey.currentState!.pushNamed('/emp/daftar-tabungan');
              break;
            case 'Penarikan':
              MyApp.navigatorKey.currentState!.pushNamed('/emp/daftar-penarikan');
              break;
            case 'Rekap Harian':
              MyApp.navigatorKey.currentState!.pushNamed('/emp/rekap-harian');
              break;
            case 'Nasabah':
              MyApp.navigatorKey.currentState!.pushNamed('/emp/nasabah');
              break;
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: Colors.brown),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF543E2D),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (data['transactions'] == null || (data['transactions'] is! List)) {
      return const Center(
        child: Text("Tidak ada transaksi yang ditemukan"),
      );
    }

    return ListView.builder(
      itemCount: data['transactions'].length,
      itemBuilder: (context, index) {
        final transaction = data['transactions'][index];
        return Card(
          elevation: 1,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: -4.0),
            leading: Icon(
              transaction['transaction_type_id'] > 4
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: Colors.brown,
            ),
            title: Text(
              _getTransactionTypeName(transaction['transaction_type_id']),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              formatCurrency(transaction['amount'] * 1.0 ?? 0),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              formatDateTime(transaction['updated_at']),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        );
      },
    );
  }

  String _getTransactionTypeName(int typeId) {
    if (typeId == 1) return 'Tabungan';
    if (typeId <= 4) return 'Deposito';
    if (typeId == 5) return 'Penarikan';
    return 'Pinjaman';
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
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
          icon: ImageIcon(AssetImage('assets/home.png')),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('assets/nasabah.png')),
          label: 'Nasabah',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('assets/profile.png')),
          label: 'Profil',
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
