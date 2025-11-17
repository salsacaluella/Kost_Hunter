import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kost_hunter/services/kost_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddKostPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const AddKostPage({super.key, this.docId, this.data});

  @override
  State<AddKostPage> createState() => _AddKostPageState();
}

class _AddKostPageState extends State<AddKostPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController facilityInputCtrl = TextEditingController();
  String gender = "Campur";
  final KostService kostService = KostService();

  File? selectedImage;
  List<String> facilities = [];

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      nameCtrl.text = widget.data!['name'] ?? '';
      addressCtrl.text = widget.data!['address'] ?? '';
      priceCtrl.text = widget.data!['price_per_month'].toString();
      gender = widget.data!['gender'] ?? 'Campur';
      facilities = List<String>.from(widget.data!['facilities'] ?? []);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? "Tambah Kost" : "Edit Kost"),
        backgroundColor: Colors.orange[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Nama Kost"),
              ),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: "Alamat Kost"),
              ),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga / Bulan"),
              ),
              DropdownButton<String>(
                value: gender,
                items: ["Pria", "Wanita", "Campur"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => gender = v!),
              ),
              const SizedBox(height: 10),

              // ✅ Bagian baru: List fasilitas dengan tombol tambah
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: facilityInputCtrl,
                      decoration: const InputDecoration(
                        labelText: "Tambah fasilitas",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.orange),
                    onPressed: () {
                      final text = facilityInputCtrl.text.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          facilities.add(text);
                          facilityInputCtrl.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (facilities.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: facilities
                      .asMap()
                      .entries
                      .map(
                        (e) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(e.value),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                facilities.removeAt(e.key);
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),

              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[900],
                    ),
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Pilih Gambar"),
                  ),
                  const SizedBox(width: 10),
                  if (selectedImage != null)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[900],
                ),
                onPressed: () async {
                  if (widget.docId == null) {
                    await kostService.addKost(
                      name: nameCtrl.text,
                      address: addressCtrl.text,
                      pricePerMonth: int.parse(priceCtrl.text),
                      gender: gender,
                      facilities: facilities,
                      imageFile: selectedImage,
                      ownerUid: user!.uid,
                    );
                  } else {
                    await kostService.updateKost(widget.docId!, {
                      'name': nameCtrl.text,
                      'address': addressCtrl.text,
                      'price_per_month': int.parse(priceCtrl.text),
                      'gender': gender,
                      'facilities': facilities,
                    });
                  }

                  if (mounted) Navigator.pop(context);
                },
                child: Text(widget.docId == null ? "Simpan" : "Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
