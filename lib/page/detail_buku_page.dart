import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:perpus_isni2/page/ulasan_page.dart';

class DetailBukuPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String bukuID;
  final String emailUser;

  const DetailBukuPage({
    Key? key,
    required this.data,
    required this.bukuID,
    required this.emailUser,
  }) : super(key: key);

  @override
  State<DetailBukuPage> createState() => _DetailBukuPageState();
}

class _DetailBukuPageState extends State<DetailBukuPage> {
  DateTime? selectedReturnDate;

  Future<void> pilihTanggalPengembalian() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (pickedDate != null) {
      setState(() {
        selectedReturnDate = pickedDate;
      });
    }
  }

  Future<void> pinjamBuku() async {
  if (selectedReturnDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pilih tanggal pengembalian terlebih dahulu")),
    );
    return;
  }

  // Simpan data peminjaman ke Firebase
  DocumentReference docRef = await FirebaseFirestore.instance.collection('peminjaman').add({
    'idBuku': widget.bukuID,
    'email': widget.emailUser,
    'tanggalPeminjaman': DateTime.now(),
    'tanggalPengembalian': null,
    'batasPengembalian': selectedReturnDate,
  });

  await docRef.update({'idPeminjaman': docRef.id});

  // Simpan histori peminjaman
  await FirebaseFirestore.instance.collection('histori').add({
    'idBuku': widget.bukuID,
    'email': widget.emailUser,
    'judulBuku': widget.data['judul'],
    'tanggalPeminjaman': DateTime.now(),
    'tanggalPengembalian': null,
    'aksi': 'peminjaman',
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Buku berhasil dipinjam")),
  );

  Get.back();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Detail Buku'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: widget.data['gambar'].isNotEmpty
                  ? Image.memory(
                      base64Decode(widget.data['gambar']),
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 16),
            Text('Judul: ${widget.data['judul']}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Penulis: ${widget.data['penulis']}',
                style: TextStyle(fontSize: 16)),
            Text('Penerbit: ${widget.data['penerbit']}',
                style: TextStyle(fontSize: 16)),
            Text('Tahun Terbit: ${widget.data['tahunterbit']}',
                style: TextStyle(fontSize: 16)),
            Text('Deskripsi: ${widget.data['deskripsi']}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 14),


            // BAGIAN ULASAN BUKU
            Text(
              'Ulasan Buku',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Get.to(() => UlasanBukuPage(bukuID: 'idbuku'));
                  },
                  icon: Icon(Icons.rate_review),
                ),
                Text('Ulasan'),
              ],
            ),

            // Tombol Pilih Tanggal Pengembalian
            Row(
              children: [
                ElevatedButton(
                  onPressed: pilihTanggalPengembalian,
                  child: Text("Pilih Tanggal Pengembalian"),
                ),
                SizedBox(width: 10),
                if (selectedReturnDate != null)
                  Text(DateFormat('yyyy-MM-dd').format(selectedReturnDate!)),
              ],
            ),

            SizedBox(height: 20),

            // Tombol Pinjam Buku
            Center(
              child: ElevatedButton(
                onPressed: pinjamBuku,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text("Pinjam"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BAGIAN ULASAN BUKU
            // Text(
            //   'Ulasan Buku',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // SizedBox(height: 8),
            // Row(
            //   children: [
            //     IconButton(
            //       onPressed: () {
            //         Get.to(() => UlasanBukuPage(bukuID: 'idbuku'));
            //       },
            //       icon: Icon(Icons.rate_review),
            //     ),
            //     Text('Ulasan'),
            //   ],
            // ),
