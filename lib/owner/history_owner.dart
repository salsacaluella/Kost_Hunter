import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // untuk format tanggal

class HistoryOwnerPage extends StatefulWidget {
  const HistoryOwnerPage({super.key});

  @override
  State<HistoryOwnerPage> createState() => _HistoryOwnerPageState();
}

class _HistoryOwnerPageState extends State<HistoryOwnerPage> {
  DateTime? selectedDate; // filter tanggal
  int? selectedMonth; // filter bulan

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Histori Transaksi"),
        backgroundColor: Colors.orange[900],
      ),
      body: Column(
        children: [
          // 🔸 Filter tanggal & bulan
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate == null
                        ? "Pilih Tanggal"
                        : DateFormat('dd MMM yyyy').format(selectedDate!),
                  ),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        selectedMonth = null; // reset filter bulan
                      });
                    }
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    selectedMonth == null
                        ? "Pilih Bulan"
                        : "Bulan ${selectedMonth!}",
                  ),
                  onPressed: () async {
                    // pilih bulan (pakai simple dialog)
                    final pickedMonth = await showDialog<int>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text("Pilih Bulan"),
                        children: List.generate(
                          12,
                          (index) => SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, index + 1),
                            child: Text("Bulan ${index + 1}"),
                          ),
                        ),
                      ),
                    );
                    if (pickedMonth != null) {
                      setState(() {
                        selectedMonth = pickedMonth;
                        selectedDate = null; // reset filter tanggal
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // 🔸 Stream data histori transaksi
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('pesanan_kost')
                  .where('owner_uid', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Terjadi kesalahan: ${snapshot.error}"),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Belum ada histori transaksi."),
                  );
                }

                // Filter data sesuai tanggal/bulan
                final transaksiList = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final Timestamp? ts = data['createdAt'];
                  if (ts == null) return false;
                  final date = ts.toDate();

                  if (selectedDate != null) {
                    return DateFormat('yyyy-MM-dd').format(date) ==
                        DateFormat('yyyy-MM-dd').format(selectedDate!);
                  } else if (selectedMonth != null) {
                    return date.month == selectedMonth;
                  }
                  return true; // tanpa filter
                }).toList();

                if (transaksiList.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada transaksi untuk filter ini."),
                  );
                }

                return ListView.builder(
                  itemCount: transaksiList.length,
                  itemBuilder: (context, index) {
                    final data = transaksiList[index].data();
                    final tanggal = (data['createdAt'] as Timestamp?)?.toDate();
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.receipt_long,
                          color: Colors.orange,
                        ),
                        title: Text(data['kost_name'] ?? "Nama Kost Tidak Ada"),
                        subtitle: Text(
                          "Penyewa: ${data['user_name'] ?? '-'}\n"
                          "Tanggal: ${tanggal != null ? DateFormat('dd MMM yyyy').format(tanggal) : '-'}\n"
                          "Status: ${data['status'] ?? '-'}",
                        ),
                        trailing: Text(
                          "Rp${data['harga'] ?? 0}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
