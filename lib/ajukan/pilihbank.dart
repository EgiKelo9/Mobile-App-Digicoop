import 'package:flutter/material.dart';

class pilihbank extends StatefulWidget {
  const pilihbank({Key? key}) : super(key: key);

  @override
  _pilihbankState createState() => _pilihbankState();
}

class _pilihbankState extends State<pilihbank> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Rentang Waktu',
          style: TextStyle(color: Colors.brown, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            _buildRadioOption('DANA'),
            _buildRadioOption('OVO'),
            _buildRadioOption('GOPAY'),
            _buildRadioOption('SHOPEEPAY'),
            Divider(color: Colors.brown),
            _buildRadioOption('BANK BRI'),
            _buildRadioOption('BANK BNI'),
            _buildRadioOption('BANK BCA'),
            _buildRadioOption('BANK MANDIRI'),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Fungsi kosong untuk tombol Terapkan
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Terapkan', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.brown),
        ),
        Radio(
          value: title,
          groupValue: selectedOption,
          onChanged: (value) {
            setState(() {
              selectedOption = value as String?;
            });
          },
          activeColor: Colors.brown,
        ),
      ],
    );
  }
  }