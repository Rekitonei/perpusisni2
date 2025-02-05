import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UlasanBukuPage extends StatelessWidget {
  final String bukuID;

  UlasanBukuPage({super.key, required this.bukuID});
  GetStorage box = GetStorage();

  TextEditingController ulasanController = TextEditingController(),
      ratingController = TextEditingController();

  void tambahUlasan() async {
    String? email = box.read('email'), username = box.read('username');

    if (email == null || email.isEmpty) {
      Get.snackbar('Error', 'Anda belum login');
      return;
    }

    if (ulasanController.text.isNotEmpty && ratingController.text.isNotEmpty) {
      int rating = int.tryParse(ratingController.text) ?? 0;
      if (rating >= 1 && rating <= 5) {
        await FirebaseFirestore.instance.collection('ulasanbuku').add({
          'idbuku': bukuID,
          'UserID': email,
          'username': username,
          'Ulasan': ulasanController.text,
          'Rating': rating,
        });
        ulasanController.clear();
        ratingController.clear();
      } else {
        Get.snackbar('Error', 'Rating harus antara 1 - 5');
      }
    }
  }

  void hapusUlasan(String id, String userID) async {
    String? email = box.read('email');

  
    if (email == userID) {
      await FirebaseFirestore.instance
          .collection('ulasanbuku')
          .doc(id)
          .delete();
    } else {
      Get.snackbar('Error', 'Hanya pemilik ulasan yang dapat menghapusnya');
    }
  }

  void editUlasan(String id, String ulasan, int rating, String userID) {
    String? email = box.read('email');

    
    if (email == userID) {
      ulasanController.text = ulasan;
      ratingController.text = rating.toString();
      Get.defaultDialog(
        title: 'Edit Ulasan',
        content: Column(
          children: [
            TextField(
              controller: ulasanController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 8),
            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        textConfirm: 'Update',
        onConfirm: () async {
          int newRating = int.tryParse(ratingController.text) ?? 0;
          if (newRating >= 1 && newRating <= 5) {
            await FirebaseFirestore.instance
                .collection('ulasanbuku')
                .doc(id)
                .update({
              'Ulasan': ulasanController.text,
              'Rating': newRating,
            });
            Get.back();
          } else {
            Get.snackbar('Error', 'Rating harus antara 1 - 5');
          }
        },
      );
    } else {
      Get.snackbar('Error', 'Hanya pemilik ulasan yang dapat mengeditnya');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ulasan Buku')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('ulasanbuku')
                  .where('idbuku', isEqualTo: bukuID)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Belum ada ulasan'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 2),
                      child: ListTile(
                        leading: Icon(Icons.comment),
                        title: Text(doc['Ulasan']),
                        subtitle: Text(
                            'Rating: ${doc['Rating']} - Oleh: ${doc['UserID']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            
                            if (doc['UserID'] == box.read('email')) ...[
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => editUlasan(
                                    doc.id,
                                    doc['Ulasan'],
                                    doc['Rating'],
                                    doc['UserID']),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    hapusUlasan(doc.id, doc['UserID']),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Form untuk menulis ulasan
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: ulasanController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Tulis ulasan',
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: ratingController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Berikan rating (1-5)',
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: tambahUlasan,
                  child: Text('Kirim Ulasan'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
