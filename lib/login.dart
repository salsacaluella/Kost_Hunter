import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kost_hunter/owner/home_owner.dart';
import 'package:kost_hunter/society/home.dart';
import 'package:kost_hunter/society/pencarikost.dart';
import 'package:kost_hunter/owner/pemilikkost.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded, size: 90, color: Colors.orange[900]),
              const SizedBox(height: 16),

              Text(
                "Masuk ke KostApp",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.orange[900],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Login untuk mencari atau mengelola kost",
                style: TextStyle(color: Colors.grey[700], fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Email Field
              _buildTextField(
                controller: emailController,
                hint: "Email",
                icon: Icons.email_outlined,
                validator: (value) {
                  if (value!.isEmpty) return "Email tidak boleh kosong";
                  if (!RegExp(
                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]",
                  ).hasMatch(value)) {
                    return "Masukkan email valid";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              

              // Password Field
              _buildTextField(
                controller: passwordController,
                hint: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
                obscure: _isObscure3,
                toggle: () {
                  setState(() {
                    _isObscure3 = !_isObscure3;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) return "Password tidak boleh kosong";
                  if (value.length < 6) return "Minimal 6 karakter";
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Tombol Login
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[900],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    visible = true;
                  });
                  await signIn(emailController.text, passwordController.text);
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),

              const SizedBox(height: 15),

              if (visible) CircularProgressIndicator(color: Colors.orange[900]),

              const SizedBox(height: 30),

              // Link ke Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Belum punya akun? ",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    child: Text(
                      "Daftar",
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              Text(
                "© KostApp 2025",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.orange[800]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.orange[800],
                ),
                onPressed: toggle,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((
      DocumentSnapshot documentSnapshot,
    ) {
      if (documentSnapshot.exists) {
        String role = documentSnapshot
            .get('role')
            .toString()
            .toLowerCase()
            .trim();

        if (role.contains("owner") || role.contains("Owner") || role.contains("pemilik kost")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeOwner()),
          );
        } else if (role.contains("society") || role.contains("user") || role.contains("pencari kost")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeUser()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Role tidak dikenali.")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Akun tidak ditemukan di database.")),
        );
      }
    });
  }


  Future<void> signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        setState(() {
          visible = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login berhasil!"),
            backgroundColor: Colors.green,
          ),
        );

        route();
      } on FirebaseAuthException catch (e) {
        setState(() {
          visible = false;
        });

        String message = "";
        if (e.code == 'user-not-found') {
          message = "Email belum terdaftar.";
        } else if (e.code == 'wrong-password') {
          message = "Password salah.";
        } else if (e.code == 'invalid-email') {
          message = "Format email tidak valid.";
        } else {
          message = "Terjadi kesalahan. Coba lagi.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}
