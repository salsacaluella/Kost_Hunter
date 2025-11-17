import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kost_hunter/society/detail_kost.dart';

class Pencarikost extends StatefulWidget {
  const Pencarikost({super.key});

  @override
  State<Pencarikost> createState() => _PencarikostState();
}

class _PencarikostState extends State<Pencarikost> {
  String? filterGender;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final kostRef = FirebaseFirestore.instance.collection('kosts');

    return SafeArea(
      child: Container(
        color: const Color(0xFFF7F7F7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HEADER ====================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                "Cari Kost",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[900],
                ),
              ),
            ),

            // ==================== SEARCH & FILTER ====================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (v) =>
                          setState(() => searchQuery = v.toLowerCase()),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: "Cari berdasarkan nama atau alamat",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Filter Gender
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      value: filterGender,
                      hint: const Text("Filter gender"),
                      items: const ["Semua", "Pria", "Wanita", "Campur"]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => filterGender = v),
                    ),
                  ),
                ],
              ),
            ),

            // ==================== LIST KOST ====================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: (filterGender == null || filterGender == "Semua")
                    ? kostRef.snapshots()
                    : kostRef
                          .where('gender', isEqualTo: filterGender)
                          .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final address = (data['address'] ?? '')
                        .toString()
                        .toLowerCase();

                    return name.contains(searchQuery) ||
                        address.contains(searchQuery);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Tidak ada kost ditemukan",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailKostPage(kostId: docs[i].id),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child:
                                      data['image_url'] != null &&
                                          data['image_url'] != ''
                                      ? Image.network(
                                          data['image_url'],
                                          width: 95,
                                          height: 95,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 95,
                                          height: 95,
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.home,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),

                                const SizedBox(width: 14),

                                // Text Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? "",
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        data['address'] ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${data['gender']} • Rp${data['price_per_month']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange[900],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Button Pesan
                                ElevatedButton(
                                  onPressed: () async {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user == null) return;

                                    final existingOrder =
                                        await FirebaseFirestore.instance
                                            .collection('pesanan_kost')
                                            .where(
                                              'user_id',
                                              isEqualTo: user.uid,
                                            )
                                            .where(
                                              'kost_id',
                                              isEqualTo: docs[i].id,
                                            )
                                            .get();

                                    if (existingOrder.docs.isNotEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Kamu sudah memesan kost ini sebelumnya.",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    await FirebaseFirestore.instance
                                        .collection('pesanan_kost')
                                        .add({
                                          'user_id': user.uid,
                                          'kost_id': docs[i].id,
                                          'owner_uid': data['owner_uid'],
                                          'status': 'Menunggu Konfirmasi',
                                          'createdAt':
                                              FieldValue.serverTimestamp(),
                                        });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Pemesanan dikirim ke pemilik kost.",
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange[900],
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Pesan"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
