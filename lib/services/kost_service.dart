import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KostService {
  final _firestore = FirebaseFirestore.instance;

  // 🔸 Tambah kost baru
  Future<void> addKost({
    required String name,
    required String address,
    required int pricePerMonth,
    required String gender,
    required List<String> facilities,
    required String ownerUid,
    File? imageFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    String imageUrl = '';

    try {
      // 🔹 Upload gambar ke Cloudinary
      if (imageFile != null) {
        final uploadUrl = Uri.parse(
          "https://api.cloudinary.com/v1_1/dfriig5yd/image/upload",
        );

        final uploadRequest = http.MultipartRequest("POST", uploadUrl)
          ..fields['upload_preset'] =
              'unsigned_kost_upload' // preset dari Cloudinary
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

        final uploadResponse = await uploadRequest.send();

        // 🧩 Debug log Cloudinary
        final responseString = await uploadResponse.stream.bytesToString();
        print("Cloudinary response code: ${uploadResponse.statusCode}");
        print("Cloudinary response body: $responseString");

        if (uploadResponse.statusCode == 200) {
          final resData = jsonDecode(responseString);
          imageUrl = resData['secure_url'];
        } else {
          throw Exception("Upload gagal ke Cloudinary: $responseString");
        }
      }

      // 🔹 Simpan data ke Firestore
      await _firestore.collection('kosts').add({
        'owner_uid': ownerUid, // ✅ simpan UID pemilik kost
        'name': name,
        'address': address,
        'price_per_month': pricePerMonth,
        'gender': gender,
        'facilities': facilities,
        'image_url': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error add kost: $e");
      rethrow;
    }
  }

  //pesan kost
  Future<void> buatPesanan(String kostId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final firestore = FirebaseFirestore.instance;

    try {
      // 🔹 Ambil data kost berdasarkan ID
      final kostDoc = await firestore.collection('kosts').doc(kostId).get();
      if (!kostDoc.exists) throw Exception("Data kost tidak ditemukan");

      final kostData = kostDoc.data()!;
      final ownerUid = kostData['owner_uid'] ?? '';

      // 🔹 Ambil data user (penyewa)
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // 🔹 Simpan pesanan ke Firestore dengan data lengkap
      await firestore.collection('pesanan_kost').add({
        'kost_id': kostId,
        'kost_name': kostData['name'],
        'kost_address': kostData['address'],
        'harga': kostData['price_per_month'],
        'owner_uid': ownerUid,
        'user_id': user.uid,
        'user_name': userData['name'] ?? user.email,
        'status': 'Menunggu Konfirmasi',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("❌ Error saat membuat pesanan: $e");
      rethrow;
    }
  }


  // 🔸 Update data kost
  Future<void> updateKost(String id, Map<String, dynamic> data) async {
    await _firestore.collection('kosts').doc(id).update(data);
  }

  // 🔸 Hapus kost
  Future<void> deleteKost(String id) async {
    await _firestore.collection('kosts').doc(id).delete();
  }

  // 🔸 Ambil semua data kost (umum)
  Stream<QuerySnapshot> getKosts() {
    return _firestore
        .collection('kosts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🔸 ✅ Ambil hanya kost milik user login
  Stream<QuerySnapshot> getMyKosts() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Jika belum login, kembalikan stream kosong
      return const Stream.empty();
    }

    return _firestore
        .collection('kosts')
        .where('user_id', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
