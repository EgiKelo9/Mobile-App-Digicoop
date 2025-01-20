import 'package:digicoop/main.dart';
import 'package:flutter/material.dart';

class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  bool isNasabahSelected = false;
  bool isPegawaiSelected = false;

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Menghitung padding yang responsif
    final horizontalPadding = screenWidth * 0.08; // 8% dari lebar layar
    final buttonWidth = (screenWidth - (horizontalPadding * 2) - 10) / 2; // Membagi ruang yang tersedia untuk 2 tombol

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            // Minimum height untuk memastikan konten tidak terpotong
            constraints: BoxConstraints(
              minHeight: screenHeight,
            ),
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  SizedBox(height: screenHeight * 0.08), // Spacing yang responsif
                  Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      color: const Color(0xFF7B5233),
                      fontSize: screenWidth * 0.1, // Ukuran font responsif
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Pilih Role Anda\nterlebih dahulu.',
                    style: TextStyle(
                      color: const Color(0xFFD68F59),
                      fontSize: screenWidth * 0.075, // Ukuran font responsif
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  // Role Selection Section
                  SizedBox(height: screenHeight * 0.05),
                  Center(
                    child: Text(
                      'Login Sebagai',
                      style: TextStyle(
                        color: const Color(0xFF7B5233),
                        fontSize: screenWidth * 0.06, // Ukuran font responsif
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Role Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nasabah Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isNasabahSelected = true;
                            isPegawaiSelected = false;
                          });
                        },
                        child: Container(
                          width: buttonWidth,
                          height: screenHeight * 0.05,
                          decoration: BoxDecoration(
                            color: isNasabahSelected
                                ? const Color(0xFF6A584E)
                                : const Color(0xFFFFEBDC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Nasabah',
                              style: TextStyle(
                                color: isNasabahSelected
                                    ? const Color(0xFFFFEBDC)
                                    : const Color(0xFF6A584E),
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Pegawai Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPegawaiSelected = true;
                            isNasabahSelected = false;
                          });
                        },
                        child: Container(
                          width: buttonWidth,
                          height: screenHeight * 0.05,
                          decoration: BoxDecoration(
                            color: isPegawaiSelected
                                ? const Color(0xFF6A584E)
                                : const Color(0xFFFFEBDC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Pegawai',
                              style: TextStyle(
                                color: isPegawaiSelected
                                    ? Colors.white
                                    : const Color(0xFF7B5233),
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Illustration
                  SizedBox(height: screenHeight * 0.05),
                  Center(
                    child: Image.asset(
                      'assets/illustration.png',
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.3,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Continue Button
                  SizedBox(height: screenHeight * 0.05),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (isNasabahSelected) {
                          MyApp.navigatorKey.currentState!.pushNamed('/login');
                        } else if (isPegawaiSelected) {
                          MyApp.navigatorKey.currentState!.pushNamed('/emp/login');
                        }
                      },
                      child: Container(
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.06,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A584E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Lanjutkan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}