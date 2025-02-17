import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:perpus_isni2/page/detail_buku_page.dart';

class DaftarBukuPage extends StatefulWidget {
  const DaftarBukuPage({super.key});

  @override
  State<DaftarBukuPage> createState() => _DaftarBukuPageState();
}

class _DaftarBukuPageState extends State<DaftarBukuPage> {
  GetStorage box = GetStorage();
  List<Map<String, dynamic>> dataBuku = [];
  List<Map<String, dynamic>> filteredBuku = [];
  String? userEmail;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userEmail = box.read('email');
    loadData();
  }

  void loadData() async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('buku').get();

    setState(() {
      dataBuku = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      filteredBuku = List.from(dataBuku); // Salin data untuk pencarian
    });
  }

  void deleteBuku(String idFirebase) {
    FirebaseFirestore.instance.collection('buku').doc(idFirebase).delete();
    loadData();
  }

  void editBuku(Map<String, dynamic> data) {
    TextEditingController judulCtrl = TextEditingController(text: data['judul']);
    TextEditingController penulisCtrl = TextEditingController(text: data['penulis']);
    TextEditingController penerbitCtrl = TextEditingController(text: data['penerbit']);
    TextEditingController tahunCtrl = TextEditingController(text: data['tahunterbit']);
    TextEditingController deskripsiCtrl = TextEditingController(text: data['deskripsi']);
    TextEditingController stokCtrl = TextEditingController(text: data['stok'].toString());

    Get.dialog(
      AlertDialog(
        title: Text('Edit Buku'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: judulCtrl, decoration: InputDecoration(labelText: 'Judul')),
              TextField(controller: penulisCtrl, decoration: InputDecoration(labelText: 'Penulis')),
              TextField(controller: penerbitCtrl, decoration: InputDecoration(labelText: 'Penerbit')),
              TextField(controller: tahunCtrl, decoration: InputDecoration(labelText: 'Tahun Terbit')),
              TextField(controller: deskripsiCtrl, decoration: InputDecoration(labelText: 'Deskripsi')),
              TextField(controller: stokCtrl, decoration: InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('Batal')),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('buku').doc(data['id']).update({
                'judul': judulCtrl.text,
                'penulis': penulisCtrl.text,
                'penerbit': penerbitCtrl.text,
                'tahunterbit': tahunCtrl.text,
                'deskripsi': deskripsiCtrl.text,
                'stok': int.parse(stokCtrl.text),
              });
              loadData();
              Get.back();
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBuku = List.from(dataBuku);
      } else {
        filteredBuku = dataBuku.where((buku) {
          String judul = buku['judul'].toString().toLowerCase();
          String penulis = buku['penulis'].toString().toLowerCase();
          return judul.contains(query.toLowerCase()) || penulis.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        backgroundColor: Colors.blue,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Cari berdasarkan judul atau penulis...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: filterSearch,
            ),
          ),
        ),
      ),
      body: filteredBuku.isEmpty
          ? const Center(child: Text("Buku tidak ditemukan"))
          : ListView.builder(
              itemCount: filteredBuku.length,
              itemBuilder: (_, index) {
                Map<String, dynamic> data = filteredBuku[index];

                return Card(
                  child: ListTile(
                    title: Text(data['judul'] ?? 'Tanpa Judul'),
                    subtitle: Text("Penulis: ${data['penulis'] ?? '-'}"),
                    onTap: () {
                      Get.to(DetailBukuPage(data: data, bukuID: '', emailUser: ''));
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (userEmail == "admin01@gmail.com" || userEmail == "petugas01@gmail.com") ...[
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => editBuku(data),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Hapus Buku",
                                middleText: "Apakah Anda yakin ingin menghapus buku ini?",
                                textConfirm: "Hapus",
                                textCancel: "Batal",
                                confirmTextColor: Colors.white,
                                onConfirm: () {
                                  deleteBuku(data['id']);
                                  Get.back();
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
