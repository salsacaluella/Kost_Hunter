import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kost_hunter/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  String? name;
  String? phone;

  Future<Map<String, dynamic>> getUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return snapshot.data() as Map<String, dynamic>;
  }

  Future<void> updateProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': name,
      'phone': phone,
    });
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text(
          "Profil Pengguna",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          name ??= data['name'];
          phone ??= data['phone'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.orange[900],
                  child: const Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            enabled: _isEditing,
                            initialValue: name,
                            decoration: const InputDecoration(
                              labelText: "Nama",
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => name = val,
                            validator: (val) =>
                                val!.isEmpty ? "Nama tidak boleh kosong" : null,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            enabled: _isEditing,
                            initialValue: phone,
                            decoration: const InputDecoration(
                              labelText: "Nomor Telepon",
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => phone = val,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            enabled: false,
                            initialValue: data['email'],
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            enabled: false,
                            initialValue: data['role'],
                            decoration: const InputDecoration(
                              labelText: "Role",
                              prefixIcon: Icon(Icons.verified_user),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Center(
                            child: _isEditing
                                ? ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange[900],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        updateProfile();
                                      }
                                    },
                                    icon: const Icon(Icons.save),
                                    label: const Text(
                                      "Simpan Perubahan",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange[900],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = true;
                                      });
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text(
                                      "Edit Profil",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
