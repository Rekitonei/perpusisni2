import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoriPage extends StatelessWidget {
  final String emailUser;

  const HistoriPage({Key? key, required this.emailUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Histori Peminjaman"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('histori')
            .where('email', isEqualTo: emailUser)
            .orderBy('tanggalPengembalian', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Tidak ada histori peminjaman"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Cek apakah data memiliki semua field yang diperlukan
              if (!data.containsKey('idBuku')) {
                return SizedBox
                    .shrink(); // Jika tidak ada idBuku, lewati item ini
              }

              // Periksa apakah tanggal ada sebelum mengaksesnya
              Timestamp? tanggalPeminjaman =
                  data['tanggalPeminjaman'] as Timestamp?;
              Timestamp? tanggalPengembalian =
                  data['tanggalPengembalian'] as Timestamp?;

              DateTime dipinjam = tanggalPeminjaman?.toDate() ?? DateTime.now();
              DateTime dikembalikan =
                  tanggalPengembalian?.toDate() ?? DateTime.now();

              return Card(
                child: ListTile(
                  title: Text(
                    "Judul: ${data['judul'] ?? 'Tidak ditemukan'}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Dipinjam: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(dipinjam)}\n"
                    "Dikembalikan: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(dikembalikan)}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
