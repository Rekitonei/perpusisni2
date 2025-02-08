import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:perpus_isni2/page/home_page.dart';
import 'package:perpus_isni2/page/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GetStorage box = GetStorage();
  bool password = true;

  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();

  @override
  void initState() {
    cekLogin();
    super.initState();
  }

  void cekLogin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    String? email = box.read('email');
    if (email?.isNotEmpty ?? false) {
      Get.offAll(() => const HomePage());
    }
  }

  Future<Map> checkUser() async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('user')
        .where('email', isEqualTo: emailController.text)
        .get();

    if (querySnapshot.docs.isEmpty) return {};
    return querySnapshot.docs[0].data();
  }

  void login(String email, String password) async {
    Map data = await checkUser();

    if (data.isEmpty) {
      log('USER TIDAK DITEMUKAN');
    } else if (password != data['password']) {
      log('PASSWORD SALAH');
    } else {
      box.write('email', email);
      Get.offAll(() => const HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('LOGIN'),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email',
              ),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: password,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => password = !password),
                  icon: Icon(password
                      ? Icons.remove_red_eye
                      : Icons.remove_red_eye_outlined),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => login(
                emailController.text,
                passwordController.text,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Belum Punya Akun?'),
                TextButton(
                  onPressed: () => Get.off(() => ResgisterPage()),
                  child: Text(
                    'Buat Akun',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
