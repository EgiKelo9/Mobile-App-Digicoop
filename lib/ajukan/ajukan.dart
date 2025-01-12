import 'dart:ui';

import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import 'package:shared_preferences/shared_preferences.dart';

class Ajukan extends StatefulWidget {
  const Ajukan({super.key});

  @override
  State<Ajukan> createState() => _AjukanState();
}

class _AjukanState extends State<Ajukan> {
  final _nominalController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> data = {};

  List<double> nominalTabungan = [20000, 50000, 100000, 200000, 500000];
  List<double> nominalDeposito = [
    1000000,
    2000000,
    5000000,
    10000000,
    20000000
  ];
  double selectedNominal = 0.0;
  int selectedJangkaWaktu = 0;
  bool isChecked = false;
  final bool _isSelected = false;
  int _selectedIndex = 2;
  String? selectedTransaksi = "Tabungan";
  String token = "";
  bool _isLoading = true;

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('tokenUser') ?? '';
    if (token.isNotEmpty) {
      final response = await DioProvider().getUserCard(token);
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

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFEBDC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Syarat dan Ketentuan",
            textAlign: TextAlign.center,
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
                      "Anggota yang ingin membuka rekening simpanan di DigiCoop wajib terdaftar sebagai anggota koperasi dan telah memiliki akun pada aplikasi DigiCoop. Simpanan dapat berupa Simpanan Harian atau Simpanan Deposito, dengan nominal minimal Rp1.000.000. Jangka waktu untuk Simpanan Deposito tersedia dalam pilihan 3 bulan, 6 bulan, dan 12 bulan, sedangkan Simpanan Harian dapat dicairkan kapan saja sesuai kebijakan yang berlaku.\n\n"
                      "Anggota wajib memberikan data yang valid dan benar saat melakukan pendaftaran simpanan. Bunga simpanan akan dihitung berdasarkan kebijakan suku bunga yang berlaku dan akan diberikan secara berkala sesuai dengan ketentuan yang telah disepakati. Anggota juga diwajibkan menjaga saldo minimum sesuai dengan jenis simpanan yang dipilih.\n\n"
                      "Pencairan Simpanan Deposito sebelum jatuh tempo akan dikenakan penalti sesuai dengan ketentuan yang berlaku. Data pribadi anggota akan diproses sesuai dengan kebijakan privasi DigiCoop. Dengan membuka rekening simpanan, anggota dianggap telah membaca, memahami, dan menyetujui seluruh syarat dan ketentuan ini. Ketentuan ini dapat berubah sewaktu-waktu tanpa pemberitahuan sebelumnya.",
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
                Navigator.of(context).pop();
                // Implement logic for submission here
              },
              child: const Text(
                "Kembali",
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
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ajukan",
                style: TextStyle(
                  color: Color(0xFF7B5233),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 24),
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
                            .pushNamed('/ajukan-pinjaman');
                      },
                      child: _buildTabButton("Pinjaman", false),
                    ),
                  ),
                  SizedBox(width: 8), // Added spacing between tabs
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        MyApp.navigatorKey.currentState!
                            .pushNamed('/ajukan-penarikan');
                      },
                      child: _buildTabButton("Penarikan", false),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: DropdownButton<String>(
                  value: selectedTransaksi,
                  icon: Icon(Icons.arrow_drop_down),
                  style: TextStyle(
                    color: Color(0xFF7B5233),
                    fontSize: 16,
                  ),
                  underline: Container(
                    height: 2,
                    color: Colors.transparent,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTransaksi = newValue;
                    });
                  },
                  items: <String>['Tabungan', 'Deposito']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Nominal",
                style: TextStyle(
                  color: Color(0xFF7B5233),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...selectedTransaksi == 'Tabungan'
                          ? List.generate(
                              nominalTabungan.length,
                              (index) => _buildNominalButton(
                                  formatCurrency(nominalTabungan[index]),
                                  selectedNominal))
                          : List.generate(
                              nominalDeposito.length,
                              (index) => _buildNominalButton(
                                  formatCurrency(nominalDeposito[index]),
                                  selectedNominal)),
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
                                  "Masukkan Nominal",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7B5233),
                                  ),
                                ),
                                content: TextFormField(
                                  controller: _nominalController,
                                  decoration: InputDecoration(
                                    labelText: 'Nominal',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF7B5233),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Color(0xFF7B5233),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Color(0xFF7B5233),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onFieldSubmitted: (value) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      selectedNominal = double.parse(value);
                                    });
                                  },
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          side: BorderSide(
                                            color: Color(0xFF7B5233),
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: const Color(0xFF7B5233)),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      backgroundColor: WidgetStateProperty.all(
                                        const Color(0xFF6A584E),
                                      ),
                                    ),
                                    child: Text(
                                      'Next',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedNominal = double.parse(
                                            _nominalController.text);
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 113,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: _isSelected
                                ? Color(0xFF6A584E)
                                : Color(0xFFFFEBDC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Lainnya",
                            style: TextStyle(
                              color: _isSelected
                                  ? Color(0xFFFFEBDC)
                                  : Color(0xFF6A584E),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                '${formatCurrency(selectedNominal)},00',
                style: TextStyle(
                  color: Color(0xFF7B5233),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Minimum nominal ${selectedTransaksi == 'Tabungan' ? formatCurrency(nominalTabungan[0]) : formatCurrency(nominalDeposito[0])},00",
                style: TextStyle(
                  color: Color(0xFF7B5233),
                  fontSize: 12,
                ),
              ),
              (selectedTransaksi == 'Deposito')
                  ? SizedBox(height: 24)
                  : SizedBox(height: 0),
              (selectedTransaksi == 'Deposito')
                  ? Text(
                      "Jangka Waktu",
                      style: TextStyle(
                        color: Color(0xFF7B5233),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : SizedBox(height: 0),
              SizedBox(height: 8),
              (selectedTransaksi == 'Deposito')
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: _buildMonthButton(
                              "3 Bulan", selectedJangkaWaktu.toDouble()),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: _buildMonthButton(
                              "6 Bulan", selectedJangkaWaktu.toDouble()),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: _buildMonthButton(
                              "12 Bulan", selectedJangkaWaktu.toDouble()),
                        ),
                      ],
                    )
                  : SizedBox(height: 0),
              SizedBox(height: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Deskripsi Transaksi",
                      style: TextStyle(
                        color: Color(0xFF7B5233),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _deskripsiController,
                      decoration: InputDecoration(
                        hintText: "Masukkan deskripsi transaksi",
                        hintStyle: TextStyle(
                          color: Color(0xFF7B5233),
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF7B5233),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF7B5233),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF7B5233),
                  ),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        text: "Saya menyetujui ",
                        style: const TextStyle(
                          color: Color(0xB0B35933),
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "syarat dan ketentuan ",
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFFB35933),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _showConfirmationDialog(); // Display modal
                              },
                          ),
                          const TextSpan(
                            text: "yang berlaku",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isChecked
                    ? () async {
                        setState(() {
                          _isLoading = true;
                        });
                        if (selectedTransaksi == 'Deposito' &&
                            data['card']['status_deposito'] ==
                                'Tidak Tersedia') {
                          _showStatusDialog(
                              "Pengajuan Gagal",
                              "Anda masih memiliki deposito aktif. Silakan tunggu hingga durasi deposito berakhir atau ajukan penarikan ke kantor cabang terdekat. Terima kasih.",
                              '/ajukan-simpanan');
                        } else if ((selectedTransaksi == 'Tabungan' &&
                                selectedNominal < nominalTabungan[0]) ||
                            (selectedTransaksi == 'Deposito' &&
                                selectedNominal < nominalDeposito[0])) {
                          _showStatusDialog(
                            "Pengajuan Gagal",
                            "Nominal minimal untuk transaksi ini adalah ${formatCurrency(nominalTabungan[0])},00 untuk Tabungan dan ${formatCurrency(nominalDeposito[0])},00 untuk Deposito.",
                            '/ajukan-simpanan',
                          );
                        } else {
                          final simpananStored = await DioProvider()
                              .storeUserAjukanSimpanan(
                                  token,
                                  selectedTransaksi!,
                                  selectedNominal,
                                  selectedJangkaWaktu,
                                  _deskripsiController.text);
                          setState(() {
                            _isLoading = false;
                          });
                          if (simpananStored == 200) {
                            _showStatusDialog(
                                "Pengajuan Berhasil",
                                "Pengajuan berhasil dilakukan. Pengajuan Anda akan diproses paling lambat 1x24 jam setelah transaksi diajukan. Terima kasih.",
                                "/history-simpanan");
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A584E),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Ajukan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 16),
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
                } else if (index == 1) {
                  MyApp.navigatorKey.currentState!
                      .pushNamed('/history-simpanan');
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

  Widget _buildNominalButton(String label, double selectedValue) {
    bool isSelected = parseCurrency(label) == selectedValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == "Lainnya") {
            selectedNominal = double.parse(_nominalController.text);
            isSelected = false;
          } else if (label.contains("Rp")) {
            selectedNominal = parseCurrency(label);
          }
        });
      },
      child: Container(
        width: 113,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6A584E) : Color(0xFFFFEBDC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF6A584E),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthButton(String label, double selectedValue) {
    bool isSelected = selectedValue == int.parse(label[0]);
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedJangkaWaktu = int.parse(label[0]);
        });
      },
      child: Container(
        width: 113,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6A584E) : Color(0xFFFFEBDC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF6A584E),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  double parseCurrency(String currency) {
    return double.tryParse(
          currency.replaceAll(RegExp(r'[Rp\s.,]'), '').replaceAll(',', '.'),
        ) ??
        0.0;
  }
}
