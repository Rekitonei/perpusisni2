import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoriPenggunaPage extends StatefulWidget {
  const HistoriPenggunaPage({super.key});

  @override
  State<HistoriPenggunaPage> createState() => _HistoriPenggunaPageState();
}

class _HistoriPenggunaPageState extends State<HistoriPenggunaPage> {
  List<Map<String, dynamic>> pengguna = [];

  @override
  void initState() {
    super.initState();
    getDataPengguna();
  }

  void getDataPengguna() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('user').get();

      pengguna = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'nama_lengkap': doc['nama_lengkap'],
                'email': doc['email']
              })
          .toList();

      setState(() {});
    } catch (e) {
      log("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histori Pengguna')),
      body: ListView.builder(
        itemCount: pengguna.length,
        itemBuilder: (context, index) {
          final user = pengguna[index];
          return ListTile(
            title: Text(user['nama_lengkap']),
            subtitle: Text(user['email']),
            onTap: () {
              // Navigasi ke halaman histori detail
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoriDetailPage(email: user['email']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Halaman Detail Histori Peminjaman
class HistoriDetailPage extends StatelessWidget {
  final String email;

  const HistoriDetailPage({super.key, required this.email});

  Future<String> getJudulBuku(String idBuku) async {
    try {
      DocumentSnapshot bukuDoc =
          await FirebaseFirestore.instance.collection('buku').doc(idBuku).get();
      if (bukuDoc.exists) {
        return bukuDoc['judul'];
      }
    } catch (e) {
      log("Error mengambil judul buku: $e");
    }
    return "Judul Tidak Ditemukan";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Histori - $email')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('histori')
            .where('email', isEqualTo: email)
            .orderBy('tanggalPengembalian', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tidak ada histori peminjaman"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              Timestamp? tanggalPeminjaman = data['tanggalPeminjaman'] as Timestamp?;
              Timestamp? tanggalPengembalian = data['tanggalPengembalian'] as Timestamp?;

              return FutureBuilder<String>(
                future: getJudulBuku(data['idBuku']),
                builder: (context, bukuSnapshot) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        "Judul: ${bukuSnapshot.data ?? 'Tidak ditemukan'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Dipinjam: ${tanggalPeminjaman != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(tanggalPeminjaman.toDate()) : 'Belum ada data'}\n"
                        "Dikembalikan: ${tanggalPengembalian != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(tanggalPengembalian.toDate()) : 'Belum ada data'}",
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
