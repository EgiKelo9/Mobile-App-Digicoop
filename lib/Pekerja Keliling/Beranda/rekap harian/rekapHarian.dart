import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RekapHarian extends StatefulWidget {
  const RekapHarian({super.key});

  @override
  State<RekapHarian> createState() => _RekapHarianState();
}

class _RekapHarianState extends State<RekapHarian> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String token = '';
  Map<String, dynamic> data = {};
  DateTime _selectedDate = DateTime.now();
  final _filterController = TextEditingController();
  final _dateController = TextEditingController();
  List filteredTransactions = [];

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('tokenEmployee') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getRekapHarianForEmployee(
        token,
        _filterController.text.isNotEmpty ? _filterController.text : "Semua",
        _selectedDate,
      );
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
    print(filteredTransactions);
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
            padding: EdgeInsets.only(top: 40),
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.brown),
                onPressed: () {
                  MyApp.navigatorKey.currentState!.pushNamed('/emp/dashboard');
                },
              ),
              title: Text(
                "Rekap Harian",
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
            SizedBox(height: 8),
            // Dropdown untuk Pilih Transaksi
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: "Pilih Transaksi",
                fillColor: Color(0xFFF3E8E1),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                DropdownMenuItem(
                    value: "Semua", child: Text("Semua Transaksi")),
                DropdownMenuItem(
                    value: "Tabungan", child: Text("Transaksi Tabungan")),
                DropdownMenuItem(
                    value: "Penarikan", child: Text("Transaksi Penarikan")),
              ],
              onChanged: (value) async {
                setState(() {
                  _filterController.text = value ?? 'Semua';
                });
                await getData();
              },
            ),
            SizedBox(height: 16),
            // Date Picker
            TextField(
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
                suffixIcon: Icon(Icons.calendar_today, color: Colors.brown),
              ),
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2030),
                ).then((pickedDate) {
                  if (pickedDate == null) {
                    return;
                  }
                  setState(() {
                    _selectedDate = pickedDate;
                    _dateController.text =
                        "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                  });
                  getData();
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              "Daftar Transaksi:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Daftar Transaksi
            Expanded(
              child: (filteredTransactions.isNotEmpty)
                  ? ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        return transaksiCard(
                          data['card_numbers'][filteredTransactions[index]
                                      ['card_id']
                                  .toString()]
                              .toString(),
                          filteredTransactions[index]['amount'] as double,
                          filteredTransactions[index]['updated_at'].toString(),
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

  @override
  void dispose() {
    super.dispose();
  }

  Widget transaksiCard(String nomorKartu, double nominal, String tanggal) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF3E8E1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "#$nomorKartu",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 4),
              Text(
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.brown,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(formatCurrency(nominal)),
        ],
      ),
    );
  }
}

String formatDateTime(String inputDate) {
  // Parsing input tanggal string ke objek DateTime
  DateTime dateTime = DateTime.parse(inputDate);
  String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
  String formattedTime = DateFormat('HH:mm').format(dateTime);
  return '$formattedDate\n$formattedTime';
}

String formatCurrency(double amount) {
  return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      )},00';
}
