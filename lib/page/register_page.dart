import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:perpus_isni2/page/home_page.dart';
import 'package:perpus_isni2/page/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResgisterPage extends StatefulWidget {
  const ResgisterPage({super.key});

  @override
  State<ResgisterPage> createState() => _ResgiterPageState();
}

class _ResgiterPageState extends State<ResgisterPage> {
  GetStorage box = GetStorage();

  TextEditingController usernameController = TextEditingController(),
  emailController = TextEditingController(),
  passwordController = TextEditingController(),
  confirmController = TextEditingController(),
  namaLenkapController = TextEditingController(),
  alamatController = TextEditingController();  

  Future<void> add(
    Map<String, dynamic> data,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('user').add(data);
    } catch (_) {
      log('DATA GAGAL DITAMBAHKAN');
    }
  }

  void register() async {
    if (passwordController.text == confirmController.text) {
      Map check = await checkUser(emailController.text);
      if (check.isEmpty) {
        add({
          'email': emailController.text,
          'username': usernameController.text,
          'password': passwordController.text,
          'nama_lengkap': namaLenkapController.text,  
          'alamat': alamatController.text,    
        });
        box.write('email', emailController.text);
        Get.offAll(() => const HomePage());
      } else {
        log('EMAIL SUDAH DIGUNAKAN');
      }
    } else {
      log('PASSWORD TIDAK SAMA');
    }
  }

    Future<Map> checkUser(String email) async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('user')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isEmpty) return {};
    return querySnapshot.docs[0].data();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Register'),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Username',
              ),
            ),
            TextFormField(
              controller: namaLenkapController, 
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nama Lengkap',
              ),
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email',
              ),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
            TextFormField(
              controller: confirmController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Konfirmasi Password',
              ),
            ),
            TextFormField(
              controller: alamatController, // Input alamat
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Alamat',
              ),
            ),
            ElevatedButton(
              onPressed: () => register(),
              style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
              child: Text('Register',style: TextStyle(color: Colors.white),),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah Punya Akun?'),
                TextButton(
                  onPressed: () => Get.off(() => LoginPage()),
                  child: Text(
                    'Login Disini',style: TextStyle(color: Colors.lightBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
