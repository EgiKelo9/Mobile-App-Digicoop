import 'package:flutter/material.dart';

class rentangwaktu extends StatefulWidget {
  const rentangwaktu({super.key});

  @override
  State<rentangwaktu> createState() => _rentangwaktuState();
}

class _rentangwaktuState extends State<rentangwaktu> {
  // State variables to manage selections
  String? selectedOption;
  String? selectedMonth;
  String? selectedYear;
  
  // List of months in Indonesian
  final List<String> months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  
  // Generate list of years (current year - 5 years)
  List<String> getYears() {
    final currentYear = DateTime.now().year;
    return List.generate(6, (index) => (currentYear - index).toString());
  }

  void applyFilter(BuildContext context) {
    // Prepare the filter parameters
    String? filterMonth;
    String? filterYear;
    
    if (selectedOption == 'Pilih Bulan') {
      if (selectedMonth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih bulan')),
        );
        return;
      }
      filterMonth = selectedMonth;
    }
    
    if (selectedOption == 'Pilih Tahun') {
      if (selectedYear == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih tahun')),
        );
        return;
      }
      filterYear = selectedYear;
    }
    
    // Return the selected filters to the previous screen
    Navigator.pop(context, {
      'filter_type': selectedOption,
      'selected_month': filterMonth,
      'selected_year': filterYear,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.brown),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                'Pilih E-wallet/Bank',
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildRadioOption('Hari ini'),
            _buildRadioOption('7 Hari Terakhir'),
            _buildRadioOption('30 Hari Terakhir'),
            
            // Month selection with dropdown
            Column(
              children: [
                _buildRadioOption('Pilih Bulan'),
                if (selectedOption == 'Pilih Bulan')
                  Container(
                    margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEFEA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.brown.withOpacity(0.3)),
                    ),
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      isExpanded: true,
                      hint: const Text('Pilih Bulan'),
                      underline: Container(), // Remove the default underline
                      items: months.map((String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMonth = newValue;
                        });
                      },
                    ),
                  ),
              ],
            ),
            
            // Year selection with dropdown
            Column(
              children: [
                _buildRadioOption('Pilih Tahun'),
                if (selectedOption == 'Pilih Tahun')
                  Container(
                    margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEFEA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.brown.withOpacity(0.3)),
                    ),
                    child: DropdownButton<String>(
                      value: selectedYear,
                      isExpanded: true,
                      hint: const Text('Pilih Tahun'),
                      underline: Container(), // Remove the default underline
                      items: getYears().map((String year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedYear = newValue;
                        });
                      },
                    ),
                  ),
              ],
            ),
            
            const Spacer(),
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
                  applyFilter(context);
                  // Handle the selected values
                  String result = '';
                  switch (selectedOption) {
                    case 'Pilih Bulan':
                      result = 'Selected Month: $selectedMonth';
                      break;
                    case 'Pilih Tahun':
                      result = 'Selected Year: $selectedYear';
                      break;
                    default:
                      result = 'Selected Option: $selectedOption';
                  }
                  print(result); // For debugging
                  // Add your logic here to handle the selection
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Terapkan',
                    style: TextStyle(color: Colors.white, fontSize: 16)
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
          style: const TextStyle(fontSize: 16, color: Colors.brown),
        ),
        Radio(
          value: title,
          groupValue: selectedOption,
          onChanged: (value) {
            setState(() {
              selectedOption = value;
              // Reset selections when changing options
              if (value != 'Pilih Bulan') selectedMonth = null;
              if (value != 'Pilih Tahun') selectedYear = null;
            });
          },
          activeColor: Colors.brown,
        ),
      ],
    );
  }
}