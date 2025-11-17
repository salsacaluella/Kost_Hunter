import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pesanan Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[900],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pesanan_kost')
            .where('user_id', isEqualTo: user!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada pesanan.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'Menunggu Konfirmasi';
              final kostId = data['kost_id'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('kosts')
                    .doc(kostId)
                    .get(),
                builder: (context, kostSnapshot) {
                  if (!kostSnapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text("Memuat detail kost..."),
                    );
                  }

                  final kostData =
                      kostSnapshot.data!.data() as Map<String, dynamic>? ?? {};

                  Color statusColor = Colors.orange;
                  if (status == "Disetujui") statusColor = Colors.green;
                  if (status == "Ditolak") statusColor = Colors.red;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NAMA KOST
                          Text(
                            kostData['name'] ?? 'Nama Kost Tidak Ditemukan',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // ALAMAT
                          Text(
                            "📍 ${kostData['address'] ?? '-'}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // HARGA
                          Text(
                            "💵 Harga: Rp${kostData['price_per_month'] ?? '-'} / bulan",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // STATUS
                          Row(
                            children: [
                              const Icon(Icons.info, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "Status: $status",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // BUTTON NOTA
                          if (status == 'Disetujui')
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.receipt_long),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                                label: const Text(
                                  "Lihat Nota",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      title: const Text(
                                        "Nota Pesanan",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Nama Kost: ${kostData['name'] ?? '-'}",
                                          ),
                                          Text(
                                            "Alamat: ${kostData['address'] ?? '-'}",
                                          ),
                                          Text(
                                            "Harga: Rp${kostData['price_per_month'] ?? '-'}",
                                          ),
                                          Text("Status: $status"),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text(
                                            "Tutup",
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
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
