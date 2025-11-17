// Fixed version that only shows comments for kost owned by the logged-in owner.
// Functions remain unchanged. Only query and filter logic updated.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KomentarOwnerPage extends StatefulWidget {
  const KomentarOwnerPage({super.key});

  @override
  State<KomentarOwnerPage> createState() => _KomentarOwnerPageState();
}

class _KomentarOwnerPageState extends State<KomentarOwnerPage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> _getKostData(String kostId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('kosts')
          .doc(kostId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error fetching kost data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komentar Kost'),
        backgroundColor: Colors.orange[900],
      ),

      // 🔥 FIX UTAMA: hanya ambil komentar yang kost_id-nya milik owner
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('komentar_kost')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, komentarSnapshot) {
          if (!komentarSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allKomentar = komentarSnapshot.data!.docs;

          // 🔥 Filter komentar: hanya komentar untuk kost yang owner_uid == user.uid
          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('kosts')
                .where('owner_uid', isEqualTo: user!.uid)
                .get(),
            builder: (context, kostSnapshot) {
              if (!kostSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Ambil semua kostId milik owner
              final ownerKostIds = kostSnapshot.data!.docs
                  .map((e) => e.id)
                  .toList();

              // Filter komentar di mana kost_id termasuk kost milik owner
              final filteredKomentar = allKomentar.where((komentarDoc) {
                final data = komentarDoc.data() as Map<String, dynamic>;
                return ownerKostIds.contains(data['kost_id']);
              }).toList();

              if (filteredKomentar.isEmpty) {
                return const Center(
                  child: Text('Belum ada komentar untuk kost Anda.'),
                );
              }

              return ListView.builder(
                itemCount: filteredKomentar.length,
                itemBuilder: (context, index) {
                  final komentarDoc = filteredKomentar[index];
                  final komentarData =
                      komentarDoc.data() as Map<String, dynamic>;
                  final komentarId = komentarDoc.id;
                  final kostId = komentarData['kost_id'];
                  final userId = komentarData['user_id'];

                  return FutureBuilder(
                    future: Future.wait([
                      _getKostData(kostId),
                      _getUserData(userId),
                    ]),
                    builder:
                        (
                          context,
                          AsyncSnapshot<List<Map<String, dynamic>?>> snap,
                        ) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const LinearProgressIndicator();
                          }

                          final kostData = snap.data?[0];
                          final userData = snap.data?[1];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            child: ListTile(
                              title: Text(komentarData['komentar'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kost: ${kostData?['name'] ?? 'Tidak ditemukan'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Alamat: ${kostData?['address'] ?? '-'}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'User: ${userData?['name'] ?? 'Anonim'}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (komentarData['balasan'] != null)
                                    Text(
                                      'Balasan: ${komentarData['balasan']}',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.reply,
                                  color: Colors.orange,
                                ),
                                onPressed: () async {
                                  final TextEditingController replyController =
                                      TextEditingController();
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Balas Komentar'),
                                      content: TextField(
                                        controller: replyController,
                                        decoration: const InputDecoration(
                                          hintText: 'Tulis balasan...',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange[900],
                                          ),
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('komentar_kost')
                                                .doc(komentarId)
                                                .update({
                                                  'balasan':
                                                      replyController.text,
                                                });
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Kirim'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
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
