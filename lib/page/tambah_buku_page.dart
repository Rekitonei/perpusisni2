import 'dart:convert';
// ignore: unused_import
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class TambahBukuPage extends StatefulWidget {
  const TambahBukuPage({super.key});

  @override
  State<TambahBukuPage> createState() => _TambahBukuPageState();
}

class _TambahBukuPageState extends State<TambahBukuPage> {
  TextEditingController judul = TextEditingController(),
      penulis = TextEditingController(),
      penerbit = TextEditingController(),
      tahunterbit = TextEditingController(),
      deskripsi =TextEditingController(),
      stok = TextEditingController();

  String imageBase64 = '';

  @override
  void initState() {
    permission();
    super.initState();
  }

  void permission() async {
    PermissionStatus status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
  }

  Future<String> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      List<int> imageBytes = await image.readAsBytes();
      String base64String = base64Encode(imageBytes);

      return base64String;
    } else {
      return '';
    }
  }

  String idBuku() {
    return DateFormat('yyyyMMddhhmmss').format(DateTime.now());
  }

  void pick() async {
    String img = imageBase64 = await pickImage();
    setState(() {
      imageBase64 = img;
    });
  }

  void createData() async {
    CollectionReference Tambahbuku = FirebaseFirestore.instance.collection('buku');
    await Tambahbuku.add({
      'idbuku': idBuku(),
      'judul': judul.text,
      'penulis': penulis.text,
      'penerbit': penerbit.text,
      'tahunterbit': tahunterbit.text,
      'deskripsi': deskripsi.text,
      'gambar': imageBase64,
      'stok': int.tryParse(stok.text) ?? 0,
    });

    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
        title: Text('Tambah Buku'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: pick,
              child: Container(
                height: 330,
                width: Get.width,
                color: Colors.grey,
                child: imageBase64.isEmpty
                    ? Center(
                        child: Icon(Icons.add_a_photo),
                      )
                    : Image.memory(
                        base64Decode(imageBase64),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            TextFormField(
              controller: stok, // Input stok
              decoration: InputDecoration(hintText: 'Stok Buku'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: judul,
              decoration: InputDecoration(
                hintText: 'Judul',
              ),
            ),
            TextFormField(
              controller: penulis,
              decoration: InputDecoration(
                hintText: 'Penulis',
              ),
            ),
            TextFormField(
              controller: penerbit,
              decoration: InputDecoration(
                hintText: 'Penerbit',
              ),
            ),
            TextFormField(
              controller: tahunterbit,
              decoration: InputDecoration(
                hintText: 'Tahun terbit',
              ),
            ),
            TextFormField(
              controller: deskripsi,
              decoration: InputDecoration(
                hintText: 'Deskripsi',
              ),
            ),
            ElevatedButton(
              onPressed: () => createData(),
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

/*
bukuid
judul
penulis
penerbit
tahunterbit
gambar
*/
