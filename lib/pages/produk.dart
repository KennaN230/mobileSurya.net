import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Surya Abadi Net',
    home: DB(),
  ));
}

class DB extends StatefulWidget {
  const DB({Key? key}) : super(key: key);

  @override
  State<DB> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DB> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.100.31/surya4/lib/API/APIproduk.php'),
      );

      if (response.statusCode == 200) {
        dynamic jsonResponse = json.decode(response.body);
        if (jsonResponse != null && jsonResponse is List && jsonResponse.isNotEmpty) {
          setState(() {
            _products = jsonResponse.map((data) => Product.fromJson(data)).toList();
            _isLoading = false;
            _errorMessage = ''; // Clear error message if successful
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Invalid response or empty data';
          });
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load products: $error';
        _isLoading = false;
      });
    }
  }

  void _navigateToTransaksiPage(String productName, int productPrice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransaksiPage(
          wifiName: productName,
          wifiPrice: productPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surya Abadi Net', style: TextStyle(fontFamily: 'Playball', color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.lightBlue[100],
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                ),
                child: Text(
                  'Surya Abadi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              _buildDrawerItem(Icons.dashboard, 'Dashboard'),
              _buildDrawerItem(Icons.monetization_on, 'Transaksi'),
              _buildDrawerItem(Icons.shopping_cart, 'Pesanan'),
              _buildDrawerItem(Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage.isNotEmpty
                ? Text(_errorMessage)
                : _products.isEmpty
                    ? const Text('No products found.')
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          children: _products.map((product) {
                            return GridTile(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/${product.imageUrl}',
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          return Image.asset(
                                            _getFallbackImage(product.name),
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        product.name ?? 'Unknown Product',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Rp ${product.price ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          _navigateToTransaksiPage(
                                            product.name ?? 'Unknown Product',
                                            product.price ?? 0,
                                          );
                                        },
                                        child: const Text('Pesan Sekarang'),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.lightBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlue),
      title: Text(title, style: TextStyle(color: Colors.black54)),
      onTap: () {
        Navigator.pop(context);
      },
      minLeadingWidth: 20,
    );
  }

  String _getFallbackImage(String? productName) {
    switch (productName) {
      case 'Paket 1':
        return 'assets/images/wifi1.jpeg';
      case 'Paket 2':
        return 'assets/images/wifi2.jpeg';
      case 'Paket 3':
        return 'assets/images/wifi3.jpeg';
      default:
        return 'assets/images/wifi.jpeg';
    }
  }
}

class Product {
  final String? name;
  final int? price;
  final String? imageUrl;

  Product({this.name, this.price, this.imageUrl});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['nama_produk'] as String?,
      price: json['harga'] as int?,
      imageUrl: json['gambar'] as String?,
    );
  }
}

class TransaksiPage extends StatefulWidget {
  final String wifiName;
  final int wifiPrice;

  const TransaksiPage({Key? key, required this.wifiName, required this.wifiPrice}) : super(key: key);

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  String _selectedPaymentMethod = '';

  Future<void> _saveTransaction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');

    if (email != null) {
      final response = await http.post(
        Uri.parse('http://192.168.100.31/surya4/lib/API/APItransaksi.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'paket': widget.wifiName,
          'harga': widget.wifiPrice,
          'tanggalBeli': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil disimpan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan transaksi')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email tidak ditemukan. Harap login kembali.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Transaksi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WiFi yang dipesan: ${widget.wifiName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod.isEmpty ? null : _selectedPaymentMethod,
              onChanged: (newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              items: <String>[
                'Bank BCA - No Rekening 125478 5874',
                'Dana - Fairozi Rohainun Najih 021478541365',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Metode Pembayaran',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran: Rp ${widget.wifiPrice}',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: _saveTransaction,
                  child: const Text('Pesan Sekarang'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
