import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_kost.dart';
import 'package:kost_hunter/services/kost_service.dart';
import 'package:kost_hunter/main.dart'; // akses AuthWrapper

class Pemilikkost extends StatefulWidget {
  const Pemilikkost({super.key});

  @override
  State<Pemilikkost> createState() => _PemilikKostState();
}

class _PemilikKostState extends State<Pemilikkost> {
  final KostService kostService = KostService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Kost"),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthWrapper()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[900],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddKostPage()),
          );
        },
        child: const Icon(Icons.add),
      ),

      // ✅ StreamBuilder hanya menampilkan kost milik user login
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kosts')
            .where('owner_uid', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text("Belum ada kost yang kamu tambahkan."),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: data['image_url'] != null && data['image_url'] != ''
                      ? Image.network(
                          data['image_url'],
                          width: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.home, size: 40),
                  title: Text(data['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${data['address']} - ${data['gender']} - Rp${data['price_per_month']}",
                      ),
                      if (data['facilities'] != null)
                        Text(
                          "Fasilitas: ${(data['facilities'] as List).join(', ')}",
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddKostPage(
                                docId: docs[index].id,
                                data: data,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          kostService.deleteKost(docs[index].id);
                        },
                      ),
                    ],
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
