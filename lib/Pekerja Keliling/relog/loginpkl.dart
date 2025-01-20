import 'package:digicoop/Models/auth_model.dart';
import 'package:digicoop/main.dart';
import 'package:digicoop/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class loginpkl extends StatefulWidget {
  const loginpkl({super.key});

  @override
  State<loginpkl> createState() => _loginpklState();
}

class _loginpklState extends State<loginpkl> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.brown),
                onPressed: () {
                  MyApp.navigatorKey.currentState!.pushNamed('/');
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Hai, Pegawai!',
                  style: TextStyle(
                    color: Color(0xFF7B5233),
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login akunmu dengan lengkapi data dirimu!',
                  style: TextStyle(
                    color: Color(0xFFD68F59),
                    fontSize: 28,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.email, color: Color(0xFFC5AA95)),
                    hintText: 'Masukkan Email Anda',
                    hintStyle:
                        const TextStyle(color: Color(0xFFC5AA95), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFFFEBDC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock, color: Color(0xFFC5AA95)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFFC5AA95)),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                    hintText: 'Masukkan Password Anda',
                    hintStyle:
                        const TextStyle(color: Color(0xFFC5AA95), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFFFEBDC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                Spacer(),
                Consumer<AuthModel>(
                  builder: (context, auth, child) {
                    return Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A584E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () async {
                            final token = await DioProvider().getTokenEmployee(
                                _emailController.text,
                                _passwordController.text);
                            if (token != null) {
                              auth.loginSuccess();
                              MyApp.navigatorKey.currentState!
                                  .pushNamed('/emp/dashboard');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal Login'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 0),
                            child: Text(
                              'Masuk',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
