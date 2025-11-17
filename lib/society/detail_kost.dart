import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailKostPage extends StatefulWidget {
  final String kostId;
  const DetailKostPage({super.key, required this.kostId});

  @override
  State<DetailKostPage> createState() => _DetailKostPageState();
}

class _DetailKostPageState extends State<DetailKostPage> {
  final _commentController = TextEditingController();
  bool canComment = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserCanComment();
  }

  Future<void> _checkIfUserCanComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('pesanan_kost')
        .where('user_id', isEqualTo: user.uid)
        .where('kost_id', isEqualTo: widget.kostId)
        .where('status', isEqualTo: 'Disetujui')
        .get();

    setState(() {
      canComment = snapshot.docs.isNotEmpty;
    });
  }

  Future<void> _sendComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _commentController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('komentar_kost').add({
      'kost_id': widget.kostId,
      'user_id': user.uid,
      'komentar': _commentController.text,
      'createdAt': FieldValue.serverTimestamp(),
      'balasan': null,
    });

    _commentController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Komentar berhasil dikirim!')));
  }

  @override
  Widget build(BuildContext context) {
    final kostDoc = FirebaseFirestore.instance
        .collection('kosts')
        .doc(widget.kostId)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Detail Kost",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: kostDoc,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER GAMBAR PREMIUM
                if (data['image_url'] != null && data['image_url'] != '')
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    child: Image.network(
                      data['image_url'],
                      height: 230,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 18),

                // CARD DETAIL UTAMA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.09),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul premium
                        Text(
                          data['name'],
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Lokasi
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.orange[900],
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                data['address'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.3,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Harga premium
                        Text(
                          "Rp${data['price_per_month']} / bulan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          "Gender: ${data['gender']}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 8),

                        if (data['facilities'] != null)
                          Text(
                            "Fasilitas: ${(data['facilities'] as List).join(', ')}",
                            style: const TextStyle(fontSize: 15),
                          ),

                        const SizedBox(height: 22),

                        // Tombol pesan premium
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[900],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;

                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Silakan login terlebih dahulu.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              await FirebaseFirestore.instance
                                  .collection('pesanan_kost')
                                  .add({
                                    'user_id': user.uid,
                                    'kost_id': widget.kostId,
                                    'owner_uid': data['owner_uid'],
                                    'status': 'Menunggu Konfirmasi',
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Permintaan pemesanan dikirim ke pemilik kost.",
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Pesan Kost",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ========================= KOMENTAR ==========================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Komentar",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Input komentar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: canComment
                      ? Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _commentController,
                                  decoration: const InputDecoration(
                                    hintText: "Tulis komentar...",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.orange[900],
                              child: IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                onPressed: _sendComment,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          "Kamu hanya bisa berkomentar setelah menyewa kost ini.",
                          style: TextStyle(color: Colors.grey),
                        ),
                ),

                const SizedBox(height: 22),

                // List komentar premium
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('komentar_kost')
                        .where('kost_id', isEqualTo: widget.kostId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final comments = snapshot.data!.docs;

                      if (comments.isEmpty) {
                        return const Text("Belum ada komentar.");
                      }

                      return Column(
                        children: comments.map((doc) {
                          final c = doc.data() as Map<String, dynamic>;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.orange[900],
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        c['komentar'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Balasan pemilik
                                if (c['balasan'] != null)
                                  Container(
                                    margin: const EdgeInsets.only(
                                      top: 14,
                                      left: 12,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.orange[900],
                                          child: const Icon(
                                            Icons.store,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            "Balasan pemilik: ${c['balasan']}",
                                            style: TextStyle(
                                              color: Colors.orange[900],
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
