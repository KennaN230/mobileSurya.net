import 'package:flutter/material.dart';
import 'package:surya4/pages/myBag.dart';
import 'package:surya4/pages/person.dart';
import 'package:surya4/pages/produk.dart';

class LandingPage1 extends StatefulWidget {
  const LandingPage1({Key? key}) : super(key: key);

  @override
  State<LandingPage1> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage1> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    DB(),
    TransactionHistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Produk',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Riwayat Transaksi',
            icon: Icon(Icons.list),
          ),
          BottomNavigationBarItem(
            label: 'Profil',
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}

class Riwayat extends StatelessWidget {
  const Riwayat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Another Screen'),
    );
  }
}
