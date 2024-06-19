import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get user email from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? '';

      final response = await http.post(
        Uri.http('192.168.100.31', '/surya4/lib/API/APIriwayat.php'),
        body: {'email': userEmail},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          setState(() {
            transactions = jsonData.map<Map<String, dynamic>>((item) {
              final parsedItem = Map<String, dynamic>.from(item);
              parsedItem['harga'] = int.tryParse(parsedItem['harga'].toString()) ?? 0;
              return parsedItem;
            }).toList();
            errorMessage = '';
          });
        } else if (jsonData['message'] != null) {
          // Handle error message from API
          setState(() {
            errorMessage = jsonData['message'];
          });
        }
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    fetchTransactions(); // Panggil fungsi fetchTransactions saat initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)))
              : transactions.isEmpty
                  ? const Center(child: Text('No transactions found.'))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: Colors.white,
                          shadowColor: Colors.grey,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.shopping_cart, color: Colors.lightBlueAccent),
                            title: Text(
                              transaction['paket'],
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Rp ${transaction['harga']}',
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            ),
                            trailing: Text(
                              transaction['tanggalBeli'],
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Transaction History',
    theme: ThemeData(
      primarySwatch: Colors.lightBlue,
      scaffoldBackgroundColor: Colors.grey[100],
      textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.black),
        bodyText2: TextStyle(color: Colors.black54),
      ),
    ),
    home: TransactionHistoryPage(),
  ));
}
