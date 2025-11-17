import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kost_hunter/login.dart';
import 'package:kost_hunter/society/home.dart';
import 'package:kost_hunter/owner/home_owner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.orange[900]),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> _getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final role = data['role'];
        if (role != null && role.toString().trim().isNotEmpty) {
          return role.toString().trim().toLowerCase();
        }
      }
    } catch (e) {
      debugPrint("Error ambil role: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Kalau belum login → ke halaman login
        if (!snapshot.hasData || snapshot.data == null) {
          return LoginPage();
        }

        final user = snapshot.data!;

        return FutureBuilder<String?>(
          future: _getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;

            // Jika role tidak ditemukan, tampilkan login lagi biar bisa re-login
            if (role == null) {
              return const Scaffold(
                body: Center(child: Text("Role belum diatur di database.")),
              );
            }

            // Normalisasi role
            if (role.contains("owner")) {
              return const HomeOwner(); // halaman untuk Owner
            } else if (role.contains("user") || role.contains("society")) {
              return const HomeUser(); // halaman untuk User
            } else {
              // fallback default agar tidak muncul error
              return const HomeUser();
            }
          },
        );
      },
    );
  }
}
