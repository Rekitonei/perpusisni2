import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:perpus_isni2/page/detail_buku_page.dart'; // Ganti dengan halaman detail buku

class DaftarBukuPage extends StatefulWidget {
  const DaftarBukuPage({super.key});

  @override
  State<DaftarBukuPage> createState() => _DaftarBukuPageState();
}

class _DaftarBukuPageState extends State<DaftarBukuPage> {
  List<Map<String, dynamic>> dataBuku = [];
  List idBukuFirebase = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collection('buku').get();

      setState(() {
        dataBuku = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id; // Simpan ID dokumen Firebase
          return data;
        }).toList();
      });
    } catch (e) {
      log("Gagal Mengambil Data Buku: $e");
    }
  }

  void validationDelete(String idFirebase) {
    Get.dialog(
      AlertDialog(
        title: Text('Ingin Menghapus Buku ini?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () => deleteBuku(idFirebase),
            child: Text('Iya'),
          ),
        ],
      ),
    );
  }

  void deleteBuku(String idFirebase) {
    try {
      FirebaseFirestore.instance.collection('buku').doc(idFirebase).delete();
    } catch (e) {
      log('Gagal Hapus Buku');
    }
    loadData();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: dataBuku.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: dataBuku.length,
              itemBuilder: (_, index) {
                Map<String, dynamic> data = dataBuku[index];

                return GestureDetector(
                  onTap: () {
                    Get.to(() => DetailBukuPage(
                          data: data,
                          bukuID: data['id'],
                          emailUser: 'email',
                        ));
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: data['gambar'] != null &&
                                    data['gambar'].isNotEmpty
                                ? Image.memory(
                                    base64Decode(data['gambar']),
                                    width: 80,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 80,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image,
                                        size: 50, color: Colors.grey[600]),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['judul'] ?? 'Tanpa Judul',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Penulis: ${data['penulis'] ?? 'Tidak diketahui'}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[700]),
                                ),
                                Text(
                                  "Tahun: ${data['tahunterbit'] ?? '-'}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => validationDelete(data['id']),
                            icon: const Icon(
                              Icons.delete,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
