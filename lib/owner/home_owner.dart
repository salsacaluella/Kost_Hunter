import 'package:flutter/material.dart';
import 'package:kost_hunter/owner/pemilikkost.dart';
import 'package:kost_hunter/owner/pesanan_owner.dart';
import 'package:kost_hunter/owner/komentar_owner.dart';
import 'package:kost_hunter/owner/profile_owner.dart';

class HomeOwner extends StatefulWidget {
  const HomeOwner({super.key});

  @override
  State<HomeOwner> createState() => _HomeOwnerState();
}

class _HomeOwnerState extends State<HomeOwner> {
  int _index = 0;

  final _pages = const [
    Pemilikkost(),
    PesananMasukPage(),
    KomentarOwnerPage(),
    ProfileOwnerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.orange[900],
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Kost"),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Pesanan",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.comment), label: "Komentar"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
