import 'package:digicoop/Dashboard/dashboard.dart';
import 'package:digicoop/Dashboard/notifikasipage.dart';
import 'package:digicoop/Models/auth_model.dart';
import 'package:digicoop/Pekerja%20Keliling/Beranda/berandaPKL.dart';
import 'package:digicoop/Pekerja%20Keliling/Beranda/kunjungan/TransaksiDiproses.dart';
import 'package:digicoop/Pekerja%20Keliling/Beranda/kunjungan/TransaksiTersisa.dart';
import 'package:digicoop/Pekerja%20Keliling/Beranda/penarikan/Penarikan.dart';
import 'package:digicoop/Pekerja%20Keliling/Beranda/penarikan/tambahPenarikan.dart';
import 'package:digicoop/Pekerja%20Keliling/Beranda/rekap%20harian/rekapHarian.dart';
import 'package:digicoop/Pekerja%20Keliling/Beranda/simpanan/Tabungan.dart';
import 'package:digicoop/Pekerja%20Keliling/Beranda/simpanan/tambahTabungan.dart';
import 'package:digicoop/Pekerja%20Keliling/nasabah/nasabahPKL.dart';
import 'package:digicoop/Pekerja%20Keliling/profil/profilPKL.dart';
import 'package:digicoop/Pekerja%20Keliling/relog/loginpkl.dart';
import 'package:digicoop/Profil/profil.dart';
import 'package:digicoop/Riwayat/Penarikanrwt.dart';
import 'package:digicoop/Riwayat/Pinjamanrwt.dart';
import 'package:digicoop/Riwayat/riwayat.dart';
import 'package:digicoop/ajukan/ajukan.dart';
import 'package:digicoop/ajukan/penarikan.dart';
import 'package:digicoop/ajukan/pinjaman.dart';
import 'package:digicoop/registrasiNasabah/loginnb.dart';
import 'package:provider/provider.dart';
import 'switch/switchNasabahPK.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This is a recommended approach for navigator key
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthModel>(
      create: (context) => AuthModel(),
      child: MaterialApp(
        navigatorKey: navigatorKey, // Add navigator key to MaterialApp
        debugShowCheckedModeBanner: false,
        title: 'Digicoop',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        // Remove initialRoute if you're using home
        initialRoute: '/',
        routes: {
          // role
          '/': (context) => const RolePage(),
          '/login': (context) => const loginnb(),
          '/emp/login': (context) => const loginpkl(),
          // nasabah
          '/dashboard': (context) => const Beranda(),
          '/notification': (context) => const NotifikasiNb(),
          '/history-simpanan': (context) => const Riwayat(),
          '/history-penarikan': (context) => const Penarikanrwt(),
          '/history-pinjaman': (context) => const Pinjamanrwt(),
          '/ajukan-simpanan': (context) => const Ajukan(),
          '/ajukan-penarikan': (context) => const penarikan(),
          '/ajukan-pinjaman': (context) => const pinjaman(),
          '/profil': (context) => const Profil(),
          // pegawai
          '/emp/dashboard': (context) => const BerandaPkl(),
          '/emp/transaksi': (context) => const TransaksiDiproses(),
          '/emp/tersisa': (context) => const TransaksiTersisa(),
          '/emp/daftar-tabungan': (context) => const Tabungan(),
          '/emp/daftar-penarikan': (context) => const Penarikan(),
          '/emp/rekap-harian': (context) => const RekapHarian(),
          '/emp/tambah-tabungan': (context) => const TambahTabungan(),
          '/emp/tambah-penarikan': (context) => const TambahPenarikan(),
          '/emp/nasabah': (context) => const NasabahPkl(),
          '/emp/profil': (context) => const ProfilPkl(),
        },
      ),
    );
  }
}