import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  GetStorage box = GetStorage();
  String email = '';
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    email = box.read('email') ?? '';
    fetchUserData();
  }

  
  Future<void> fetchUserData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('user')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userData = querySnapshot.docs[0].data();
        });
      }
    } catch (e) {
      log('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Pengguna'),
        backgroundColor: Colors.lightBlue,
      ),
      body: userData.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Nama Lengkap: ${userData['nama_lengkap'] ?? '-'}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Username: ${userData['username'] ?? '-'}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Email: ${userData['email'] ?? '-'}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Alamat: ${userData['alamat'] ?? '-'}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  
                ],
              ),
            ),
    );
  }
}
