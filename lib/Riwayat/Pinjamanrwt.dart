import 'package:digicoop/Riwayat/rentangwaktu.dart';
import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pinjamanrwt extends StatefulWidget {
  const Pinjamanrwt({super.key});

  @override
  State<Pinjamanrwt> createState() => _PinjamanrwtState();
}

class _PinjamanrwtState extends State<Pinjamanrwt> {
  int _selectedIndex = 1;
  bool _isLoading = true;
  Map<String, dynamic> data = {};

  Future<void> getData({
    String? filterType,
    String? selectedMonth,
    String? selectedYear,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenUser') ?? '';
    if (token.isNotEmpty) {
      // Pass the filter parameters to the API call
      final response = await DioProvider().getUserHistoryPinjaman(
        token,
        filterType: filterType,
        selectedMonth: selectedMonth,
        selectedYear: selectedYear,
      );
      if (response != null) {
        setState(() {
          data = response;
        });
      }
    }
  }

  Future<void> downloadTransactionData({
    // Add optional parameters for filtering
    String? filterType,
    String? selectedMonth,
    String? selectedYear,
  }) async {
    try {
      // Set loading state to true at the start
      setState(() {
        _isLoading = true;
      });
      
      // Get the authentication token from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenUser') ?? '';
      
      // Validate token existence
      if (token.isEmpty) {
        throw Exception('Token tidak ditemukan');
      }

      // Call the DioProvider function with the provided filter parameters
      final downloadedFilePath = await DioProvider().downloadPinjamanPDF(
        token,
        filterType: filterType,
        selectedMonth: selectedMonth,
        selectedYear: selectedYear,
      );

      // Show success message with the downloaded file name
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File berhasil diunduh: ${downloadedFilePath.split('/').last}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Log the error and show error message to user
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengunduh file'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset loading state regardless of success or failure
      setState(() {
        _isLoading = false;
      });
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
                  child: GestureDetector(
                    onTap: () {
                      MyApp.navigatorKey.currentState!
                          .pushNamed('/history-simpanan');
                    },
                    child: _buildTabButton("Simpanan", false),
                  ),
                ),
                SizedBox(width: 8), // Added spacing between tabs
                Expanded(
                  child: _buildTabButton("Pinjaman", true),
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
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => rentangwaktu()),
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          // Apply the filters and refresh data
                          await getData(
                            filterType: result['filter_type'],
                            selectedMonth: result['selected_month'],
                            selectedYear: result['selected_year'],
                          );
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.download, color: Color(0xFF7B5233)),
                      onPressed: () {
                        // Implement download functionality
                        _isLoading ? null : downloadTransactionData;
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1),
            Expanded(
              child: (data['pinjaman'] != null && data['pinjaman'] is List)
                  ? ListView.builder(
                      itemCount: data['pinjaman'].length,
                      itemBuilder: (context, index) {
                        final transaction = data['pinjaman'][index];
                        final transactionTypeId =
                            transaction['transaction_type_id'];
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
                        final currentDate =
                            formatDateTime(transaction['updated_at']);
                        final previousDate = index > 0
                            ? formatDateTime(
                                data['pinjaman'][index - 1]['updated_at'])
                            : '';

                        // Add spacing between different date groups
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (currentDate != previousDate)
                              _buildTransactionDate(currentDate),
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
              Icon(Icons.arrow_downward, color: Color(0xFF7B5233)),
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
