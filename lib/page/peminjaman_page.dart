import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PeminjamanPage extends StatefulWidget {
  final String emailUser;

  const PeminjamanPage({Key? key, required this.emailUser}) : super(key: key);

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final CollectionReference peminjamanRef =
      FirebaseFirestore.instance.collection('peminjaman');
  final CollectionReference bukuRef =
      FirebaseFirestore.instance.collection('buku');

  // Fungsi mengembalikan buku
  Future<void> kembalikanBuku(String idPeminjaman) async {
    final DocumentReference peminjamanDoc = peminjamanRef.doc(idPeminjaman);

    try {
      await peminjamanDoc.update({'tanggalPengembalian': DateTime.now()});

      // Ambil data peminjaman untuk dipindahkan ke histori
      DocumentSnapshot snapshot = await peminjamanDoc.get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      // Pindahkan data ke histori
      await pindahkanKeHistori(idPeminjaman);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengembalikan buku: $e")),
      );
    }
  }

  // Fungsi mengambil judul buku berdasarkan idBuku
  Future<String> getJudulBuku(String idBuku) async {
    DocumentSnapshot bukuDoc = await bukuRef.doc(idBuku).get();
    if (bukuDoc.exists) {
      return bukuDoc['judul'];
    }
    return "Judul Tidak Ditemukan";
  }

  // Fungsi untuk memindahkan data peminjaman yang sudah dikembalikan ke histori
  Future<void> pindahkanKeHistori(String idPeminjaman) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference peminjamanDoc =
        firestore.collection('peminjaman').doc(idPeminjaman);
    final CollectionReference historiRef = firestore.collection('histori');

    try {
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(peminjamanDoc);

        if (!snapshot.exists) {
          throw Exception("Data peminjaman tidak ditemukan.");
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        if (data['tanggalPengembalian'] == null) {
          throw Exception("Buku belum dikembalikan.");
        }

        await historiRef.add({
          'idPeminjaman': idPeminjaman,
          'idBuku': data['idBuku'],
          'email': data['email'],
          'tanggalPeminjaman': data['tanggalPeminjaman'],
          'tanggalPengembalian': data['tanggalPengembalian'],
          'batasPengembalian': data['batasPengembalian'],
        });

        transaction.delete(peminjamanDoc);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Peminjaman dipindahkan ke histori.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memindahkan ke histori: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buku yang Dipinjam"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: peminjamanRef
            .where('email', isEqualTo: widget.emailUser)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Tidak ada buku yang dipinjam"));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return FutureBuilder<String>(
                future: getJudulBuku(data['idBuku']),
                builder: (context, bukuSnapshot) {
                  if (bukuSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      child: ListTile(
                        title: Text("Memuat judul..."),
                        subtitle: Text("Tunggu sebentar"),
                      ),
                    );
                  }

                  return Card(
                    child: ListTile(
                      title: Text("Judul: ${bukuSnapshot.data}"),
                      subtitle: Text(
                        "Pengembalian: ${DateFormat('yyyy-MM-dd').format(data['batasPengembalian'].toDate())}"
                        "Dipinjam: ${DateFormat('yyyy-MM-dd').format(data['tanggalPeminjaman'].toDate())}\n"
                        "Dikembalikan: ${data['tanggalPengembalian'] == null ? 'Belum dikembalikan' : DateFormat('yyyy-MM-dd').format(data['tanggalPengembalian'].toDate())}",
                      ),
                      trailing: data['tanggalPengembalian'] == null
                          ? IconButton(
                              icon: Icon(Icons.undo, color: Colors.red),
                              onPressed: () => kembalikanBuku(doc.id),
                            )
                          : Icon(Icons.check, color: Colors.green),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
