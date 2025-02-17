import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:perpus_isni2/page/detail_buku_page.dart';
import 'package:perpus_isni2/page/daftar_buku_page.dart';
import 'package:perpus_isni2/page/histori_page.dart';
import 'package:perpus_isni2/page/histori_pengguna.dart';
import 'package:perpus_isni2/page/login_page.dart';
import 'package:perpus_isni2/page/peminjaman_page.dart';
import 'package:perpus_isni2/page/profil_page.dart';
import 'package:perpus_isni2/page/tambah_buku_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GetStorage box = GetStorage();
  List<Map<String, dynamic>> dataBuku = [];
  String? userEmail;

  void logout() {
    box.remove('email');
    Get.offAll(() => LoginPage());
  }

  @override
  void initState() {
    super.initState();
    userEmail = box.read('email'); // Ambil email pengguna
    loadData();
  }

  void loadData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collection('buku').get();

      setState(() {
        dataBuku = querySnapshot.docs
            .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });
    } catch (e) {
      log("Gagal Mengambil Data Buku: $e");
    }
  }

  void deleteBuku(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('buku').doc(docId).delete();
      loadData();
    } catch (e) {
      log("Gagal menghapus buku: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perpustakaan App'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          children: [
            const SizedBox(height: 32),
            const ListTile(
              title: Text(
                'Perpustakaan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () => Get.to(() => ProfilePage()),
            ),
            Visibility(
              visible: userEmail == "admin01@gmail.com" ||
                  userEmail == "petugas01@gmail.com",
              child: ListTile(
                leading: const Icon(Icons.bookmark_add),
                title: const Text('Tambah Buku'),
                onTap: () => Get.to(() => TambahBukuPage())?.then(
                  (_) {
                    if (_) loadData();
                  },
                ),
              ),
            ),
            Visibility(
              visible: userEmail == "admin01@gmail.com" ||
                  userEmail == "petugas01@gmail.com",
              child: ListTile(
                leading: const Icon(Icons.perm_contact_cal),
                title: const Text('Histori Semua User'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoriPenggunaPage(),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('Histori'),
              onTap: () =>
                  Get.to(() => HistoriPage(emailUser: userEmail ?? 'guest')),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Peminjaman'),
              onTap: () =>
                  Get.to(() => PeminjamanPage(emailUser: userEmail ?? ''))
                      ?.then((_) => loadData()),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: const Text('Daftar Buku'),
              onTap: () =>
                  Get.to(() => DaftarBukuPage())?.then((_) => loadData()),
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              onTap: () => logout(),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang di Perpustakaan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Perpustakaan kami menyediakan berbagai koleksi buku mulai dari fiksi, non-fiksi, hingga referensi akademik. Temukan buku favorit Anda atau eksplorasi koleksi kami!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: dataBuku.length,
                  itemBuilder: (_, index) {
                    Map<String, dynamic> data = dataBuku[index];

                    return GestureDetector(
                      onTap: () {
                        log(data['id']);
                        Get.to(() => DetailBukuPage(
                              data: data,
                              bukuID: data['id'],
                              emailUser: userEmail ?? '',
                            ))?.then((_) => loadData());
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 6 / 5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: data['gambar'].isNotEmpty
                                    ? Image.memory(
                                        base64Decode(data['gambar']),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image,
                                            size: 50, color: Colors.grey[600]),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['judul'] ?? 'Tanpa Judul',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Penulis: ${data['penulis'] ?? 'Tidak diketahui'}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
