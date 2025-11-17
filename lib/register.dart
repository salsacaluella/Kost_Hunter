import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;
  bool showProgress = false;

  var options = ['Pencari Kost', 'Pemilik Kost'];
  var _currentItemSelected = "Pencari Kost";
  var role = "Pencari Kost";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 50),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔶 Icon Header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_work_rounded,
                  size: 60,
                  color: Colors.orange[900],
                ),
              ),
              const SizedBox(height: 16),

              // 🔶 Title
              Text(
                "Register KostApp",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: Colors.orange[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Buat akunmu untuk mulai mencari atau mengelola kost",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 30),

              // 🔶 Input Fields
              _buildTextField(nameController, "Nama Lengkap", Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(phoneController, "Nomor Telepon", Icons.phone),
              const SizedBox(height: 16),
              _buildTextField(emailController, "Email", Icons.email_outlined),
              const SizedBox(height: 16),
              _buildPasswordField(
                passwordController,
                "Kata Sandi",
                _isObscure,
                () => setState(() => _isObscure = !_isObscure),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                confirmpassController,
                "Konfirmasi Kata Sandi",
                _isObscure2,
                () => setState(() => _isObscure2 = !_isObscure2),
                isConfirm: true,
              ),

              const SizedBox(height: 20),

              // 🔶 Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  value: _currentItemSelected,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: options.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _currentItemSelected = newValue!;
                      role = newValue;
                    });
                  },
                ),
              ),

              const SizedBox(height: 32),

              // 🔶 Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[900],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    signUp();
                  },
                  child: const Text(
                    "Daftar Sekarang",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔶 Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun? ",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.orange[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧩 Text Field
  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.orange[800]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.orange.shade800, width: 1.3),
        ),
      ),
      validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
    );
  }

  // 🧩 Password Field
  Widget _buildPasswordField(
    TextEditingController controller,
    String hint,
    bool obscure,
    VoidCallback toggle, {
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.orange[800],
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.orange.shade800, width: 1.3),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) return "Wajib diisi";
        if (isConfirm && value != passwordController.text) {
          return "Konfirmasi password tidak sama!";
        }
        return null;
      },
    );
  }

  // 🧩 Function Register (tetap)
  void signUp() async {
    if (_formkey.currentState!.validate()) {
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'id': credential.user!.uid,
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'role': role,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi berhasil! Silakan login.")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
