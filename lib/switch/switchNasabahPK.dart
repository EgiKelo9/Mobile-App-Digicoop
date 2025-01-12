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
    return Scaffold(
      body: Container(
        width: 393,
        height: 852,
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            // Welcome Text
            const Positioned(
              left: 30,
              top: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      color: Color(0xFF7B5233),
                      fontSize: 40,
                      // fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Pilih Role Anda\nterlebih dahulu.',
                    style: TextStyle(
                      color: Color(0xFFD68F59),
                      fontSize: 30,
                      // fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            // Role Selection
            Positioned(
              left: 30,
              top: 290,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Login Sebagai',
                      style: TextStyle(
                        color: Color(0xFF7B5233),
                        fontSize: 24,
                        // fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                          width: 157,
                          height: 40,
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
                                fontSize: 18,
                                // fontFamily: 'Inter',
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
                          width: 157,
                          height: 40,
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
                                fontSize: 18,
                                // fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Illustration Placeholder
            Positioned(
              left: 45,
              top: 400,
              child: Image.asset(
                'assets/illustration.png', // Replace with your asset path
                width: 300,
                height: 300,
              ),
            ),
            // Continue Button
            Positioned(
              left: 110,
              top: 752,
              child: GestureDetector(
                onTap: () {
                  if (isNasabahSelected) {
                    // Nasabah action here
                    MyApp.navigatorKey.currentState!.pushNamed('/login');
                  } else if (isPegawaiSelected) {
                    MyApp.navigatorKey.currentState!.pushNamed('/emp/login');
                  }
                },
                child: Container(
                  width: 180,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A584E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Lanjutkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        // fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}