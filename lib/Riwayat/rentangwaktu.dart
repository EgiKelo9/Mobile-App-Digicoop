import 'package:flutter/material.dart';

class rentangwaktu extends StatefulWidget {
  const rentangwaktu({Key? key}) : super(key: key);

  @override
  _rentangwaktuState createState() => _rentangwaktuState();
}

class _rentangwaktuState extends State<rentangwaktu> {
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
          'Pilih E-wallet/Bank',
          style: TextStyle(color: Colors.brown, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            _buildRadioOption('Hari ini'),
            _buildRadioOption('7 Hari Terakhir'),
            _buildRadioOption('30 Hari Terakhir'),
            _buildRadioOption('365 Hari Terakhir'),
            Divider(color: Colors.brown),
            _buildListOption('Pilih Hari', Icons.chevron_right),
            _buildListOption('Pilih Bulan', Icons.chevron_right),
            _buildListOption('Pilih Tahun', Icons.chevron_right),
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

  Widget _buildListOption(String title, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Colors.brown),
      ),
      trailing: Icon(icon, color: Colors.brown),
      onTap: () async {
        if (title == 'Pilih Hari' || title == 'Pilih Bulan' || title == 'Pilih Tahun') {
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (selectedDate != null) {
            print("Tanggal dipilih: $selectedDate"); // Handle the selected date here
            // Additional logic for Pilih Bulan or Pilih Tahun if needed
          }
        }
        // Implement other navigation or actions if necessary
      },
    );
  }
}