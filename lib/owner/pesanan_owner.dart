import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PesananMasukPage extends StatefulWidget {
  const PesananMasukPage({super.key});

  @override
  State<PesananMasukPage> createState() => _PesananMasukPageState();
}

class _PesananMasukPageState extends State<PesananMasukPage> {
  final user = FirebaseAuth.instance.currentUser;
  DateTime? startDate;
  DateTime? endDate;

  Future<void> updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('pesanan_kost')
        .doc(docId)
        .update({'status': newStatus});
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      helpText: 'Pilih Rentang Tanggal',
      cancelText: 'Batal',
      confirmText: 'Terapkan',
      saveText: 'Terapkan',
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Masuk"),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _selectDateRange(context),
          ),
          if (startDate != null && endDate != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  startDate = null;
                  endDate = null;
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pesanan_kost')
            .where('owner_uid', isEqualTo: user!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

          // 🔹 Filter berdasarkan tanggal jika dipilih
          if (startDate != null && endDate != null) {
            docs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final waktu = (data['createdAt'] as Timestamp?)?.toDate();
              if (waktu == null) return false;
              return waktu.isAfter(
                    startDate!.subtract(const Duration(days: 1)),
                  ) &&
                  waktu.isBefore(endDate!.add(const Duration(days: 1)));
            }).toList();
          }

          if (docs.isEmpty) {
            return const Center(
              child: Text("Tidak ada pesanan pada rentang ini."),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'Menunggu Konfirmasi';
              final waktu = (data['createdAt'] as Timestamp?)?.toDate();
              final formattedTime = waktu != null
                  ? DateFormat('dd MMM yyyy, HH:mm').format(waktu)
                  : '-';

              final kostId = data['kost_id'];
              final userId = data['user_id'];

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

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text("Memuat data penyewa..."),
                        );
                      }

                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>? ??
                          {};

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kostData['name'] ?? 'Nama Kost Tidak Ditemukan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Alamat: ${kostData['address'] ?? 'Tidak diketahui'}",
                              ),
                              Text(
                                "Harga: Rp${kostData['price_per_month'] ?? '-'}",
                              ),
                              Text(
                                "Penyewa: ${userData['name'] ?? 'Tidak diketahui'}",
                              ),
                              Text("Status: $status"),
                              Text("Waktu: $formattedTime"),
                              const SizedBox(height: 8),

                              if (status == 'Menunggu Konfirmasi')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        await updateStatus(
                                          docs[index].id,
                                          'Disetujui',
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text("Setujui"),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await updateStatus(
                                          docs[index].id,
                                          'Ditolak',
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text("Tolak"),
                                    ),
                                  ],
                                ),
                              if (status != 'Menunggu Konfirmasi')
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    status == 'Disetujui'
                                        ? "✅ Telah disetujui"
                                        : "❌ Telah ditolak",
                                    style: TextStyle(
                                      color: status == 'Disetujui'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
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
          );
        },
      ),
    );
  }
}
